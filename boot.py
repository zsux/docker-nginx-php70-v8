#!/usr/bin/env python
import argparse
import os
import sys
import logging

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG,format='%(asctime)s : %(message)s')

parser = argparse.ArgumentParser(description='DOCKER BOOT')
parser.add_argument('--start', help='start', default="1")
parser.add_argument('--boot', help='boot', default="")
parser.add_argument('--pre_init', help='pre init', default="")
parser.add_argument('--after_init', help='after init', default="")
parser.add_argument('--vh', help='vhost', default="")
parser.add_argument('--au', help='auth', default="")
parser.add_argument('--init', help='init', default="")
parser.add_argument('--init_user', help='init_user', default="")
parser.add_argument('--web', help='www root dir', default="")
parser.add_argument('--run', help='run', default="")
parser.add_argument('--config', help='confg path', default="")

args = parser.parse_args()
start = args.start
boot = args.boot
config = args.config
pre_init = args.pre_init
after_init = args.after_init
init = args.init
init_user = args.init_user
vh = args.vh
au = args.au
web = args.web
run = args.run

logging.info("booting...,%s",args)

def os_system(cmd,info = 1):
    cmd = cmd.strip('"').strip(",")
    msg = "> exec: {}".format(cmd)
    if info == 1:
        logging.info(msg)
    error = os.system(cmd)
    logging.info("run result: {}".format(error))
    if error > 0:
        sys.exit(1)

os_system("id")
os_system("pwd")

def do_init_user():
    id = 1201
    for env_key in os.environ:
        if env_key.startswith("PK_"):
            key = env_key.replace("PK_", "")
            t = key.split("_")
            username = t[0]
            public_key = os.getenv(env_key,None)
            logging.info( ">> do_init_user: {0}@{1}".format(username,public_key))
            if public_key is None:
                continue
            if username == "root":
                logging.info("ignore root")
            elif username == "www":
                os_system("sudo echo {0} >> /home/www/.ssh/authorized_keys".format(public_key))
            else:
                id += 1
                os_system("sudo useradd --uid {0} --gid www --shell /bin/bash --create-home {1}".format(id,username))
                os_system("echo '{0}:{0}_2018' | sudo chpasswd".format(username))
                os_system("sudo su - {} -c 'id'".format(username))
                os_system("sudo su - {} -c 'mkdir -p ~/.ssh'".format(username))
                os_system("sudo su - {0} -c 'echo {1} >> ~/.ssh/authorized_keys'".format(username,public_key))
                os_system("sudo su - {0} -c 'chmod 600 ~/.ssh/authorized_keys'".format(username))

if len(web) > 0:
    cmd = "sudo sed -i 's/root \/code/root {}/g' /etc/nginx/sites-enabled/default.conf".format(web.replace("/",'\/'));
    os_system(cmd)

if len(run) > 0 and os.getenv(run,None) is not None:
    os_system("echo ${0} | base64 --decode > {1} && cat {1} && echo && sh {1}".format(run,'/tmp/run.sh'))

if len(pre_init) > 0:
    os_system(pre_init)

if len(init) > 0:
    print(init)
    os_system(init)

if len(after_init) > 0:
    os_system(after_init)

cmds = []
for env_key in os.environ:
    if env_key.startswith("CMD_"):
        index = env_key.replace("CMD_", "")
        cmd = os.getenv(env_key,None)
        logging.info(env_key,cmd)
        cmds.append((int(index),cmd))

logging.info(cmds)
cmds.sort(key=lambda k: k[0])
logging.info(cmds)
for (index,cmd) in cmds:
    logging.info("{0} > {1}".format(index,cmd))
    os_system(cmd)


curls = []
for env_key in os.environ:
    if env_key.startswith("CURLS_"):
        index = env_key.replace("CURLS_", "")
        curl = os.getenv(env_key,None)
        logging.info(env_key,curl)
        curls.append((int(index),curl))

logging.info(curls)
curls.sort(key=lambda k: k[0])
logging.info(curls)
curl_auth = os.getenv(env_key,None)
for (index,curl) in curls:
    logging.info("{0} > {1}".format(index,curl))
    t = curl.strip().split(" ")
    if curl_auth is not None:
        curl_auth = "-u {}".format(curl_auth)
    else:
        curl_auth = ""
    os_system("curl {} {} -o {}".format(curl_auth,t[0],t[1]))

BOOTS = os.getenv("BOOTS",None)
if BOOTS is not None:
    for item in BOOTS.split(","):
        if len(item) == 0:
            continue
        os_system("sudo cp /etc/supervisor/conf_d/{0}.conf /etc/supervisor/conf.d/{0}.conf".format(item))

if len(vh) > 0 and os.getenv(vh,None) is not None:
    os_system("sudo chmod 777 {1} && echo ${0} | base64 --decode > {1}".format(vh,"/etc/nginx/nginx.conf"))

if len(config) > 0 and os.getenv("CONFIG_SERVER",None) is not None and os.getenv("CONFIG_USER",None) is not None and os.getenv("CONFIG_PWD",None) is not None:
    os_system("sudo curl -k -u {0}:{1} {2} -o {3}".format(
        os.getenv("CONFIG_USER",None),
        os.getenv("CONFIG_PWD",None),
        os.getenv("CONFIG_SERVER",None),
        config
    ))

if len(au) > 0 and os.getenv(au,None) is not None:
    logging.info("au")
    os_system("sudo touch {1} && sudo chmod 777 {1} && echo ${0} > {1}".format(au,"/etc/nginx/.htpasswd"))


for env_key in os.environ:
    if env_key.startswith("PWD_WWW"):
        password = os.getenv(env_key,None)
        logging.info( ">> SET www user pwd")
        os_system("echo 'www:{0}' | sudo chpasswd".format(password))
    if env_key.startswith("AU_"):
        key = env_key.replace("AU_", "")
        t = key.split("_")
        username = t[0]
        password = os.getenv(env_key,None)
        logging.info( ">> htpasswd: {0}@{1}".format(username,password))
        if password is not None:
            os_system("sudo touch {2} && sudo chmod 777 {2} && echo {0}:{1} >> {2}".format(username,password,"/etc/nginx/.htpasswd"))
            
do_init_user()

if start == '1':
    logging.info("starting")
    os_system("sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf")
else:
    os_system("bash")

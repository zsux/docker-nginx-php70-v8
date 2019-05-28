#!/usr/bin/env sh
cron_file_path=/tmp/crontab.cron
cp ${cron_file_path} /tmp/crontab.tmp
find /tmp/crontab.tmp -type f | xargs md5sum > /tmp/crontab_2.log
crontab -l > /tmp/crontab.tmp
find /tmp/crontab.tmp -type f | xargs md5sum > /tmp/crontab_1.log
diff /tmp/crontab_1.log /tmp/crontab_2.log > /tmp/crontab_3.log
Status=$?
if [ $Status = 0 ];then
    echo $(date)," ${cron_file_path} no change !"
    exit
else
    cat ${cron_file_path}
    echo $(date)," ${cron_file_path} update crontab !"
    crontab ${cron_file_path}
fi
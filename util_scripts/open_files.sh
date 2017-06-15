echo "OPEN"
cat /proc/sys/fs/file-nr;
echo "PIDs";
for i in /proc/*/fdinfo; do echo $i $(sudo ls $i | wc -l); done
sleep 1;
#!/usr/bin/env sh
systemctl start hdd-backup-prep.service

# wait till mounting drive successful
sleep 30 & PID=$!

# in meantime show loading slash
while kill -0 $PID 2>/dev/zero
do for i in '-' '\' '|' '/'
  do printf "\r$i"
   sleep 0.2
  done
done

# backup verification
IMAGES_PATH=/mnt/pve/backup/dump/

vma_list=$(find "$IMAGES_PATH" -name "*.vma" -exec vma list {} \;)
counter_vma_list=$(echo "$vma_list" | echo $(( $(wc -l) / 3 )))

dir_list=$(find "$IMAGES_PATH" -name "*.vma" -exec ls -l {} \;)
counter_dir_list=$(echo "$dir_list" | wc -l)

# visual confirmation or warning
if [ "$counter_vma_list" = "$counter_dir_list" ]; then
  printf "\n%b\n" "########################################"
  printf "\e[32m%s\e[0m%s\n" "🟢 Check went fine! " "Backups seem correct."
  printf "%b\n" "########################################"
else
  printf "\n%b\n" "##################################"
  printf "\e[31m%s\e[0m%s\n" "🔴 Error! " "Backups probably corrupt."
  printf "%b\n" "##################################"
fi

systemctl start hdd-backup-suspend.service
exit 0

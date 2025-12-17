#1/bin/bash
echo " disk utilization"

THRESHOLD=10

df -h | awk 'NR>1 {print $5 " " $6}' | while read usage mount
do
  percent=${usage%\%}

  if [ "$percent" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage on $mount is ${percent}%"
  fi
done






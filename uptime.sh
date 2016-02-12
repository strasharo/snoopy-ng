while true;
do
    let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
    let secs=$((${upSeconds}%60))
    let mins=$((${upSeconds}/60%60))
    let hours=$((${upSeconds}/3600%24))
    let days=$((${upSeconds}/86400))
    UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`


    echo "Battery: $1" > "$HOME/uptime.txt";
    echo "Uptime: $UPTIME" >> "$HOME/uptime.txt";
    # uptime -p >> "$HOME/uptime.txt";
    sleep 5m;
done
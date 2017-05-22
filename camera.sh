#!/bin/bash

keep_on_running=1
while [ $keep_on_running -eq 1 ]
do
    echo "Enter Lux level:"
    read lux_level

    echo "Enter Number of Pictures:"
    read pic_count

    adb shell rm -f /storage/self/primary/DCIM/Camera/*

    counter=0

    adb shell input keyevent KEYCODE_WAKEUP
    adb shell input keyevent KEYCODE_MENU
    sleep 1
    adb shell am start -a android.media.action.STILL_IMAGE_CAMERA
    sleep 1
    while [ $pic_count -gt $counter ]
    do
        adb shell "input keyevent KEYCODE_FOCUS"
        sleep 1
        adb shell "input keyevent KEYCODE_CAMERA"
        sleep 1
        counter=$((counter+1))
    done
    adb shell input keyevent KEYCODE_BACK

    current_date=$(date +--%Y-%m-%d--%H-%M-%S/)
    folder_name="./photos/lux_level"
    folder_name+=$lux_level
    folder_name+=$current_date
    echo $folder_name

    mkdir -p $folder_name

    adb pull /storage/self/primary/DCIM/Camera $folder_name

    echo "Press enter to run another batch of pictures. Press anyother key to quit"
    read -n 1 user_input
    echo
    if [ -z "$user_input" ]; then
        keep_on_running=1;
    else
        adb shell input keyevent KEYCODE_BACK
        exit 0
    fi
done

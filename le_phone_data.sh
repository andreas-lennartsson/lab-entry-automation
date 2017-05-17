#!/bin/bash

echo "Started"
csv_delim="|"

header="VID|UID|Order#|Operator|OEM|Model Name|Model#|MDN|Serial #|Hardware #|Android Ver.|Software Ver.|Build #|Fingerprint|IMEI|MEID|Build Type|Logging|Root|Appearance|Storage|CPU|RAM|Screen Size|Front Camera MP|Rear Camera MP|Battery mAh|Battery Wh|Manufacture Date|Tracking|Customer Box (Yes/No)|Accessories (Yes/No)|Tier|New 64 GB SD Card Added to Device (Yes/No)|Date/Time Completed|Authorized Personnel|Google Play Email|Google Play Password"

#VID
result=$csv_delim

#UID
result+=$csv_delim

#Order#
result+=$csv_delim

#Operator
operator=$(adb shell getprop gsm.sim.operator.alpha)
if [ -z "$operator" ]; then
  operator=$(adb shell getprop gsm.operator.alpha)
fi
operator=$(echo $operator|tr -d '\r')
result+=$operator
result+=$csv_delim

#OEM
#adb shell getprop ro.product.brand
oem=$(adb shell getprop ro.product.manufacturer)
result+=$(echo $oem|tr -d '\r')
result+=$csv_delim

#Model Name
model_name=$(adb shell getprop ro.product.name)
result+=$(echo $model_name|tr -d '\r')
result+=$csv_delim

#Model #
model_number=$(adb shell getprop ro.product.model)
result+=$(echo $model_number|tr -d '\r')
result+=$csv_delim

#MDN
result+=$csv_delim

#Serial Number
serial_number=$(adb shell getprop ro.serialno)
result+=$(echo $serial_number|tr -d '\r')
result+=$csv_delim

#Hardware #
hardware_rev=$(adb shell getprop ro.lge.hw.revision)
if [ -z "$hardware_rev" ]; then
  hardware_rev=$(adb shell getprop ro.hw.hwrev)
  if [ -z "$hardware_rev" ]; then
    hardware_rev=$(adb shell getprop ril.hw_ver)
    if [ -z "$hardware_rev" ]; then
      hardware_rev=$(adb shell getprop ro.hw_id)
    fi
  fi
fi
result+=$(echo $hardware_rev|tr -d '\r')
result+=$csv_delim

#Android Version
android_version=$(adb shell getprop ro.build.version.release)
result+=$(echo $android_version|tr -d '\r')
result+=$csv_delim
#adb shell getprop ro.build.version.sdk

#Software Version
software_rev=$(adb shell getprop ro.lge.hw.revision)
if [ -z "$software_rev" ]; then
  software_rev=$(adb shell getprop ro.mot.build.version.release)
  if [ -z "$software_rev" ]; then
    software_rev=$(adb shell getprop ro.build.sw_internal_version)
    if [ -z "$software_rev" ]; then
      software_rev=$(adb shell getprop ril.sw_ver)
      if [ -z "$software_rev" ]; then
        software_rev=$(adb shell getprop ro.aa.romver)
      fi
    fi
  fi
fi
result+=$(echo $software_rev|tr -d '\r')
result+=$csv_delim

#Build#
build_number+=$(adb shell getprop ro.build.id)
result+=$(echo $build_number|tr -d '\r')
result+=$csv_delim

#Finger print
finger_print=$(adb shell getprop ro.bootimage.build.fingerprint)
result+=$(echo $finger_print|tr -d '\r')
result+=$csv_delim
#adb shell getprop ro.build.fingerprint

#IMEI
imei=$(adb shell getprop gsm.baseband.imei)
result+=$(echo $imei|tr -d '\r')
result+=$csv_delim

#MEID
result+=$csv_delim

#Build Type
build_type=$(adb shell getprop ro.build.type)
result+=$(echo $build_type|tr -d '\r')
result+=$csv_delim

#Logging
result+=$csv_delim

#Root
root_result=$(adb root)
if echo "$root_result" | grep -q "adbd is already running as root"; then
  root_result="Yes"
else
  root_result="No"
fi
result+=$root_result
result+=$csv_delim

#Appearance
result+=$csv_delim

#STORAGE
storage=$(adb shell getprop persist.sys.emmc_size)
if [ -z "$storage" ]; then
  storage=$(adb shell getprop ro.hw.storage)
fi
result+=$(echo $storage|tr -d '\r')
result+=$csv_delim

#CPU
cpu=$(adb shell getprop ro.board.platform)
result+=$(echo $cpu|tr -d '\r')
result+=$csv_delim

#RAM
#[0-9]+,[0-9]+
#adb shell dumpsys meminfo | grep "Total RAM" 
#adb shell dumpsys meminfo | grep "Lost RAM"
total_ram=$(adb shell dumpsys meminfo | grep "Total RAM" | grep -o -E '[0-9]+(,[0-9]+)*' | tr -d ',')
lost_ram=$(adb shell dumpsys meminfo | grep "Lost RAM" | grep -o -E '[0-9]+(,[0-9]+)*' | tr -d ',')

echo $total_ram
echo $lost_ram

ram=$(((total_ram + lost_ram + 500000)/1000000))
result+=$ram
result+="GB"
result+=$csv_delim

#Screen Size
vm_size=$(adb shell wm size)
dens=$(adb shell wm density)
#echo $vm_size
#echo $dens

result+=$csv_delim

#Front Camera MP
result+=$csv_delim

#Rear Camera MP
result+=$csv_delim

#Battery mAh
battery_mah=$(adb shell dumpsys batterystats | grep "Estimated battery capacity:" | grep -o -E '[0-9]+(,[0-9]+)*')
result+=$(echo $battery_mah|tr -d '\r')
result+=$csv_delim

#Battery Wh
result+=$csv_delim

#Manufacture Date
manuf_date+=$(adb shell getprop ro.manufacturedate)
result+=$(echo $manuf_date|tr -d '\r')
result+=$csv_delim

#Tracking
result+=$csv_delim

#Customer Box (Yes/No)
result+=$csv_delim

#Accessories (Yes/No)
result+=$csv_delim

#Tier
result+=$csv_delim

#New 64 GB SD Card Added to Device (Yes/No)
result+=$csv_delim

#Date/Time Completed
result+=$csv_delim

#Authorized Personnel
result+=$csv_delim

#Google Play Email
result+=$csv_delim

#Google Play Password

echo $result

#echo "$header" > "$PWD/test.csv"
echo "$result" > "$PWD/test.csv"

echo "Done"
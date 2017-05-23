#!/bin/bash
#
Version="0.0.4"
#
# Author: Andreas Lennartsson
#

display_help() {
    echo
    echo "Version:$Version"
    echo
    echo "Description:"
    echo "   Reads specific values over the adb bridge and puts them into a csv file called le_data.csv"
    echo "   The phone must be connected in developer mode (adb supported)"
    echo
    echo "Running the script:"
    echo "   1. The phone must be connected in developer mode (adb supported)"
    echo "   2. Run the script from the same folder where it is located."
    echo "   3. When the script is finished with a phone it will ask" 
    echo "      \"Insert a new device and press enter or press 'q' to quit this program\""
    echo "      To gather data from another phone, please disconnect the current phone and"
    echo "      connect the new phone and press enter. The values for the new phone will be"
    echo "      appended to the le_data.csv file. If you do not have any more phones"
    echo "      please press q at the prompt to end the script."
    echo
    echo "Using the data:"
    echo "   After running the script the le_data.csv can be imported into the ccea Google Docs spreadsheet by:"
    echo "      1. File->Import"
    echo "      2. Upload (le_data.csv)"
    echo "      3. Under Import actions: Select \"Append rows to current sheet\""
    echo "      4. Under Separator character: Select \"Custom\" and enter the pipe character: |"
    echo
    echo "Usage:"
    echo "  \$ $0 [option...] {-h}"
    echo
    echo "        -h, Displays this help message"
    echo
    echo "Note:"
    echo "   1. Run the script from its own directory (./le_phone_data.sh)"
    echo "   2. There is a cpu_mapping.json file that needs to be in the same directory as the script file"
    echo
    exit 1
}

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}

out_file_name="le_data.csv"
cpu_mapping_file_name="cpu_mapping.json"
csv_delim="|"
result=""

header="VID|UID|Order#|Operator|OEM|Model Name|Model#|MDN|Serial #|Hardware #|Android Ver.|Software Ver.|Build #|Fingerprint|IMEI|MEID|Build Type|Logging|Root|Appearance|Storage|CPU|RAM|Screen Size|Front Camera MP|Rear Camera MP|Battery mAh|Battery Wh|Manufacture Date|Tracking|Customer Box (Yes/No)|Accessories (Yes/No)|Tier|New 64 GB SD Card Added to Device (Yes/No)|Date/Time Completed|Authorized Personnel|Google Play Email|Google Play Password"

#VID
get_vid()
{
    result=$csv_delim
}

#UID
get_uid()
{
    result+=$csv_delim
}

#Order#
get_order_number()
{
    result+=$csv_delim
}

#Operator
get_operator()
{
    operator=$(echo $(adb shell getprop gsm.sim.operator.alpha)|tr -d '\r')
    if [ -z "$operator" ]; then
      operator=$(echo $(adb shell getprop gsm.operator.alpha)|tr -d '\r')
    fi
    operator=$(echo $operator|tr -d '\r')
    result+=$operator
    result+=$csv_delim
}

#OEM
get_oem()
{
    #adb shell getprop ro.product.brand
    oem=$(adb shell getprop ro.product.manufacturer)
    result+=$(echo $oem|tr -d '\r')
    result+=$csv_delim
}

#Model Name
get_model_name()
{
    model_name=$(adb shell getprop ro.product.name)
    result+=$(echo $model_name|tr -d '\r')
    result+=$csv_delim
}

#Model #
get_model_number()
{
    model_number=$(adb shell getprop ro.product.model)
    result+=$(echo $model_number|tr -d '\r')
    result+=$csv_delim
}

#MDN
get_mdn()
{
    result+=$csv_delim
}

#MDN
get_in_dmd()
{
    result+=$csv_delim
}

#Serial Number
get_serial_number()
{
    serial_number=$(adb shell getprop ro.serialno)
    result+=$(echo $serial_number|tr -d '\r')
    result+=$csv_delim
}

#Hardware #
get_hardware_number()
{
    hardware_rev=$(echo $(adb shell getprop ro.lge.hw.revision)|tr -d '\r')
    if [ -z "$hardware_rev" ]; then
      hardware_rev=$(echo $(adb shell getprop ro.hw.hwrev)|tr -d '\r')
      if [ -z "$hardware_rev" ]; then
        hardware_rev=$(echo $(adb shell getprop ril.hw_ver)|tr -d '\r')
        if [ -z "$hardware_rev" ]; then
          hardware_rev=$(echo $(adb shell getprop ro.hw_id)|tr -d '\r')
          if [ -z "$hardware_rev" ]; then
            hardware_rev=$(echo $(adb shell getprop ro.boot.hw_ver)|tr -d '\r')
            if [ -z "$hardware_rev" ]; then
              hardware_rev=$(echo $(adb shell getprop ro.build.hardware_version)|tr -d '\r')
            fi
          fi
        fi
      fi
    fi
    result+=$(echo $hardware_rev|tr -d '\r')
    result+=$csv_delim
}

#Android Version
get_android_version()
{
    android_version=$(adb shell getprop ro.build.version.release)
    result+=$(echo $android_version|tr -d '\r')
    result+=$csv_delim
    #adb shell getprop ro.build.version.sdk
}

#Software Version
get_software_version()
{
    software_rev=$(echo $(adb shell getprop ro.lge.hw.revision)|tr -d '\r')
    if [ -z "$software_rev" ]; then
      software_rev=$(echo $(adb shell getprop ro.mot.build.version.release)|tr -d '\r')
      if [ -z "$software_rev" ]; then
        software_rev=$(echo $(adb shell getprop ro.build.sw_internal_version)|tr -d '\r')
        if [ -z "$software_rev" ]; then
          software_rev=$(echo $(adb shell getprop ril.sw_ver)|tr -d '\r')
          if [ -z "$software_rev" ]; then
            software_rev=$(echo $(adb shell getprop ro.aa.romver)|tr -d '\r')
            if [ -z "$software_rev" ]; then
              software_rev=$(echo $(adb shell getprop ro.build.display.id)|tr -d '\r')
            fi
          fi
        fi
      fi
    fi
    result+=$(echo $software_rev|tr -d '\r')
    result+=$csv_delim
}

#Build#
get_build_number()
{
    build_number=$(adb shell getprop ro.build.id)
    result+=$(echo $build_number|tr -d '\r')
    result+=$csv_delim
}

#Finger print
get_finger_print()
{
    finger_print=$(adb shell getprop ro.bootimage.build.fingerprint)
    result+=$(echo $finger_print|tr -d '\r')
    result+=$csv_delim
    #adb shell getprop ro.build.fingerprint
}

#IMEI
get_imei()
{
    imei=$(adb shell getprop gsm.baseband.imei)
    result+=$(echo $imei|tr -d '\r')
    result+=$csv_delim
}

#MEID
get_meid()
{
    result+=$csv_delim
}

#Build Type
get_build_type()
{
    build_type=$(adb shell getprop ro.build.type)
    result+=$(echo $build_type|tr -d '\r')
    result+=$csv_delim
}

#Logging
get_logging()
{
    result+=$csv_delim
}

#Root
get_root()
{
    root_result=$(adb root)
    if echo "$root_result" | grep -q "adbd is already running as root"; then
      root_result="Yes"
    else
      root_result="No"
    fi
    result+=$root_result
    result+=$csv_delim
}

#Appearance
get_appearance()
{
    result+=$csv_delim
}

#STORAGE
get_storage()
{
    storage=$(echo $(adb shell getprop persist.sys.emmc_size)|tr -d '\r')
    if [ -z "$storage" ]; then
      storage=$(echo $(adb shell getprop ro.hw.storage)|tr -d '\r')
    fi
    result+=$(echo $storage|tr -d '\r')
    result+=$csv_delim
}

#Available Storage
get_available_storage()
{
    result+=$csv_delim
}

#CPU
get_cpu()
{
    cpu=""
    cpu_read=$(echo $(adb shell getprop ro.board.platform)|tr -d '\r')
    if [ -n "$cpu_read" ]; then
      #json='curl -s -X GET http://twitter.com/users/show/$1.json'
      json=$(cat $PWD/$cpu_mapping_file_name)
      prop=$cpu_read
      cpu=`jsonval`
    fi
    if [ -n "$cpu" ]; then
      result+=$cpu
    else
      result+=$cpu_read
    fi
    result+=$csv_delim
}
#RAM
get_ram()
{
    total_ram=$(adb shell dumpsys meminfo | grep "Total RAM" | grep -o -E '[0-9]+(,[0-9]+)*' | tr -d ',')
    lost_ram=$(adb shell dumpsys meminfo | grep "Lost RAM" | grep -o -E '[0-9]+(,[0-9]+)*' | tr -d ',')
    ram=$(((total_ram + lost_ram + 500000)/1000000))
    result+=$ram
    result+="GB"
    result+=$csv_delim
}

#Screen Size
get_screen_size()
{
    result+=$csv_delim
}
#Camera second try
get_camera_mp_second_try()
{
    seach_value="picture-size-values:"
    value=$(adb shell dumpsys media.camera | grep "$seach_value")
    value_location=$(adb shell dumpsys media.camera | grep "Facing:")
    IFS=$'\n\r' array=($value)
    IFS=$'\n\r' array_location=($value_location)

    index_counter=0

    front_camera_count=0
    back_camera_count=0

    for i in "${array[@]}"
    do
        values=$(echo "$i" | sed 's#\picture-size-values:##g' | tr -d ' \t\r')
        IFS=$',' values_array=($values)
        IFS=$'x' size_array=(${values_array[0]})

        mega_pixels=$(((size_array[0] * size_array[1])/1000000))

        if echo "${array_location[$index_counter]}"| grep -q "BACK"; then
          back_camera_array[$back_camera_count]=$mega_pixels;
          back_camera_count=$(($back_camera_count+1))
        elif echo "${array_location[$index_counter]}" | grep -q "FRONT"; then
          front_camera_array[$front_camera_count]=$mega_pixels;
          front_camera_count=$(($front_camera_count+1))
        else
          echo "Error camera found that is not front or back";
        fi
        index_counter=$((index_counter+1))
    done

    #Front Camera MP
    result+="${front_camera_array[0]}"
    result+=$csv_delim

    #Rear Camera MP
    result+="${back_camera_array[0]}"
    result+=$csv_delim
}
#Camera MP
get_camera_mp()
{
    value=$(adb shell dumpsys media.camera | grep android.scaler.availableRawSizes -A1 | grep -v android.scaler.availableRawSizes | grep "\[")
    value_location=$(adb shell dumpsys media.camera | grep "Facing:")
    IFS=$'\n\r' array=($value)
    IFS=$'\n\r' array_location=($value_location)

    index_counter=0
    front_camera_count=0
    back_camera_count=0

    for i in "${array[@]}"
    do
        values=$(echo "$i" | sed -e 's/^[ \t]*//' | tr -d '[]')
        IFS=$' ' values_array=($values)
        mega_pixels=$(((values_array[0] * values_array[1] + 500000)/1000000))
        if echo "${array_location[$index_counter]}"| grep -q "BACK"; then
          back_camera_array[$back_camera_count]=$mega_pixels;
          back_camera_count=$(($back_camera_count+1))
        elif echo "${array_location[$index_counter]}" | grep -q "FRONT"; then
          front_camera_array[$front_camera_count]=$mega_pixels;
          front_camera_count=$(($front_camera_count+1))
        else
          echo "Error camera found that is not front or back";
        fi
        index_counter=$((index_counter+1))
    done


    if [ -n "${front_camera_array[0]}" ] || [ -n "${back_camera_array[0]}" ]; then
        #Front Camera MP
        result+="${front_camera_array[0]}"
        result+=$csv_delim

        #Rear Camera MP
        result+="${back_camera_array[0]}"
        result+=$csv_delim
    else
        get_camera_mp_second_try
    fi
}

#Battery mAh
get_battery_mAv()
{
    battery_mah=$(adb shell dumpsys batterystats | grep "Estimated battery capacity:" | grep -o -E '[0-9]+(,[0-9]+)*')
    result+=$(echo $battery_mah|tr -d '\r')
    result+=$csv_delim
}

#Battery Wh
get_battery_wh()
{
    result+=$csv_delim
}

#Manufacture Date
get_manufacture_date()
{
    manuf_date=$(adb shell getprop ro.manufacturedate)
    result+=$(echo $manuf_date|tr -d '\r')
    result+=$csv_delim
}

#Tracking
get_tracking()
{
    result+=$csv_delim
}

#Customer Box (Yes/No)
get_customer_box()
{
    result+=$csv_delim
}

#Accessories (Yes/No)
get_accessories()
{
    result+=$csv_delim
}

#Tier
get_tire()
{
    trie_value=""
    if [ -n "$cpu" ]; then
      tire_number=$(echo $cpu | grep -o -E '[0-9]+(,[0-9]+)*' | tr -d ',')
      if [ -n "$tire_number" ]; then
        if [ $tire_number -ge 800 ]; then
          trie_value="Super"
        elif [ $tire_number -ge 400 ]; then
          trie_value="Mid"
        else
          trie_value="Low"
        fi
      fi
    fi
    result+=$trie_value
    result+=$csv_delim
}

#New 64 GB SD Card Added to Device (Yes/No)
get_sd_card()
{
    result+=$csv_delim
}
#Date/Time Completed
get_time_completed()
{
    result+=$csv_delim
}

#Authorized Personnel
get_authorized_personnel()
{
    result+=$csv_delim
}

#Google Play Email
get_google_email()
{
    result+=$csv_delim
}

#Google Play Password
get_google_password()
{
    nope="nome"
}

case $1 in 
 -h) display_help ;; 
  h) display_help ;;
  ?) display_help ;;
  -?) display_help ;;
help) display_help ;;
esac

device_count=0
more_devices=1
while [ $more_devices -eq 1 ]
do
    echo "#######################  Started  #######################"
    get_vid
    get_uid
    get_order_number
    get_operator
    get_oem
    get_model_name
    get_model_number
    get_mdn
    get_in_dmd
    get_serial_number
    get_hardware_number
    get_android_version
    get_software_version
    get_build_number
    get_finger_print
    get_imei
    get_meid
    get_build_type
    get_logging
    get_root
    get_appearance
    get_cpu
    get_ram
    get_storage
    get_available_storage
    get_screen_size
    get_camera_mp
    get_battery_mAv
    get_battery_wh
    get_manufacture_date
    get_tracking
    get_customer_box
    get_accessories
    get_tire
    get_sd_card
    get_time_completed
    get_authorized_personnel
    get_google_email
    get_google_password

    echo $result
    
    if [ $device_count -eq 0 ]; then
        echo "$result" > "$PWD/$out_file_name"
    else
        echo "$result" >> "$PWD/$out_file_name"
    fi

    device_count=$((device_count+1))
    ask_user=1
    echo "#######################  Done  #######################"
    echo
    while [ $ask_user -eq 1 ]
    do

        echo "Insert a new device and press enter or press 'q' to quit this program"
        read -n 1 user_input

        if [ "$user_input" == "q" ]; then
            echo
            echo
            echo "#######################  Finished  #######################"
            echo
            exit 0
        elif [ -z "$user_input" ]; then
            more_devices=1
            ask_user=0
        else
            echo
            echo "Error '$user_input' is not a supported option."
            ask_user=1
        fi
        echo
        echo
    done
done

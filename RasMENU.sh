#!/bin/bash
# RasMENU Ver.0.1a
#   RaSCSI Image Mount Support Tool
#     Copyright (C) 2020 @taneken2000

#無限ループ
while true
do

IMAGE_PATH="/home/pi/hdd/"      # 各々の保存場所を指定

SCSI_ID=(0 1 2 3 4 5 6)
SCSI_HDD=("none" "none" "none" "none" "none" "none" "bridge")
files=()
IMAGE=()

#############
# SCSI list
#############
IFS=$'\n'
for r  in `rasctl -l`
do
    if [ ${r:0:1}  == "+" ]; then
        :   #破棄
    elif [ ${r:0:4}  == "| ID" ]; then
        :   #破棄
    else
        SCSI_HDD[${r:3:1}]="${r:19:30}"
    fi
done

i=0
s=0
for r in ${SCSI_ID[@]}
do
    files[i]="$r"
    ((i++))
    files[i]=${SCSI_HDD[s]}
    ((s++))
    ((i++))
done

RESID=$(whiptail --title "RaSCSI MOUNT MENU" --menu "`rasctl -l`" 0 0 0 ${files[@]} 3>&2 2>&1 1>&3-)
RET=$?
#echo $RET

if [ $RET -eq 255 ]; then
    break;
fi
#############
# image list
#############
i=0
for f in `find ${IMAGE_PATH} -iname "*.HDS" | sort`
do
    IMAGE[i]="${f}"
    ((i++))
    IMAGE[i]="${f}"
    ((i++))
done

if [ ${SCSI_HDD[$RESID]} == "none" ]; then
    :
else
    IMAGE=("<EJECT>" "<EJECT>" ${IMAGE[@]})
fi

RESFILE=$(whiptail --notags --title "Select IMAGE FILE" --menu "`rasctl -l`" 36 72 15 ${IMAGE[@]} 3>&2 2>&1 1>&3-)
RET=$?
#echo $RET
#echo "ID:"$RESID "FILE:"$RESFILE
if [ $RET -eq 255 ]; then
    :
else
    if [ $RESFILE == "<EJECT>" ]; then
        rasctl -i "$RESID" -c detach
    else
        rasctl -i "$RESID" -c attach -f "$RESFILE"
    fi
fi

done

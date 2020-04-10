#!/bin/bash
# RaMENU Ver.0.1e
#   RaSCSI Image Mount Support Tool
#     Copyright (C) 2020 @taneken2000

#引数からパスを取得
if [ $1 ]; then
    IMAGE_PATH="$1"
else
    IMAGE_PATH="/home/pi/hdd/"      # デフォルトのイメージファイル保存場所を指定
fi

#バージョン情報取得
TTL="`rascsi -h|head -1`"

#無限ループ
while true
do

#配列初期化
SCSI_ID=(0 1 2 3 4 5 6)
SCSI_HDD=("none" "none" "none" "none" "none" "none" "none")
files=()
IMAGE=()

#############
# SCSI list
#############
IFS=$'\n'
for r  in `rasctl -l 2>&1`
do
    if [ ${r:0:5} == "Error" ]; then        # rascsiが起動していないとき
        whiptail --msgbox "${r}" 0 0 3>&2 2>&1 1>&3-
        exit 0
    fi
    if [ "${r:0:2}" == "No" ]; then # ひとつもマウントされてないとき
        break;
    fi
    if [ ${r:0:1} == "+" ]; then
        :   #破棄
    elif [ ${r:0:4} == "| ID" ]; then
        :   #破棄
    else
        SCSI_HDD[${r:3:1}]="${r:19}"
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


#SCSI選択画面表示
RESID=$(whiptail --title "RaSCSI MOUNT MENU" --backtitle "$TTL" --menu "`rasctl -l`" 0 0 0 ${files[@]} 3>&2 2>&1 1>&3-)
RET=$?
#echo $RET

if [ $RET -eq 255 ]; then
    break;
fi
#############
# image list
#############

#指定したSCSI-IDにすでにマウント済だったらイジェクトを一番上に表示する
if [ ${SCSI_HDD[$RESID]} = "none" ]; then
    i=0
    for f in `find ${IMAGE_PATH} \( -iname "*.HD[FSNAI]" -o -iname "*.NHD" -o -iname "*.MOS" -o -iname "*.ISO" \) | sort`
    do
        IMAGE[i]="${f}"
        ((i++))
        IMAGE[i]="${f}"
        ((i++))
    done
    IMAGE=(${IMAGE[@]} "<BRIDGE>" "<BRIDGE>")
elif [ ${SCSI_HDD[$RESID]} = "NO MEDIA" ]; then
    i=0
    for f in `find ${IMAGE_PATH} -iname "*.ISO" | sort`
    do
        IMAGE[i]="${f}"
        ((i++))
        IMAGE[i]="${f}"
        ((i++))
    done
    IMAGE=("<DETACH>" "<DETACH>" ${IMAGE[@]})
elif [ ${SCSI_HDD[$RESID]##*.} = "ISO(WRITEPROTECT)" ] || [ ${SCSI_HDD[$RESID]##*.} = "iso(WRITEPROTECT)" ]; then
    i=0
    for f in `find ${IMAGE_PATH} -iname "*.ISO" | sort`
    do
        IMAGE[i]="${f}"
        ((i++))
        IMAGE[i]="${f}"
        ((i++))
    done
    IMAGE=("<DETACH>" "<DETACH>" "<EJECT>" "<EJECT>" ${IMAGE[@]})
elif [ ${SCSI_HDD[$RESID]##*.} = "MOS(WRITEPROTECT)" ] || [ ${SCSI_HDD[$RESID]##*.} = "mos(WRITEPROTECT)" ] | [ ${SCSI_HDD[$RESID]##*.} = "MOS" ] || [ ${SCSI_HDD[$RESID]##*.} = "mos" ]; then
    i=0
    for f in `find ${IMAGE_PATH} -iname "*.MOS" | sort`
    do
        IMAGE[i]="${f}"
        ((i++))
        IMAGE[i]="${f}"
        ((i++))
    done
    IMAGE=("<DETACH>" "<DETACH>" "<EJECT>" "<EJECT>" "<PROTECT>" "<PROTECT>" ${IMAGE[@]})
else
    i=0
    for f in `find ${IMAGE_PATH} \( -iname "*.HD[FSNAI]" -o -iname "*.NHD" -o -iname "*.MOS" -o -iname "*.ISO" \) | sort`
    do
        IMAGE[i]="${f}"
        ((i++))
        IMAGE[i]="${f}"
        ((i++))
    done
    IMAGE=("<DETACH>" "<DETACH>" ${IMAGE[@]})
fi

#イメージ選択画面表示
RESFILE=$(whiptail --notags --title "Select IMAGE FILE" --backtitle -"$TTL" --menu "`rasctl -l`" 0 0 0 ${IMAGE[@]} 3>&2 2>&1 1>&3-)
RET=$?
#echo $RET
#echo "ID:"$RESID "FILE:"$RESFILE
if [ $RET -eq 255 ]; then
    :
else
    if [ $RESFILE == "<DETACH>" ]; then
        rasctl -i "$RESID" -c detach
    elif [ $RESFILE == "<EJECT>" ]; then        # .MOSのinsertの配慮
        rasctl -i "$RESID" -c eject
    elif [ $RESFILE == "<PROTECT>" ]; then
        rasctl -i "$RESID" -c protect
    elif [ $RESFILE == "<BRIDGE>" ]; then
        rasctl -i "$RESID" -c aetach -t bridge
    else
        rasctl -i "$RESID" -c attach -f "$RESFILE"
    fi
fi

done

FWCONFIG_FILE="/home2/jinhaijun/pwx/pc01-WLAN.HL.0.0-01144-QCAHLSW8998MTPL-1/wlan_proc/wlan/fw/target/mac_core/include/fwconfig_QCA61x0.h"
ORIG_STRING="#define WDIAG_MSG_LVL_LIMIT 0"
NEW_STRING_TEMP="#define WDIAG_MSG_LVL_LIMIT "
#./rebuild.sh 0

build_ver=1

while [ $build_ver -lt 9 ]; do
NEW_STRING=$NEW_STRING_TEMP$build_ver
sed  -i "s/$ORIG_STRING/$NEW_STRING/g" $FWCONFIG_FILE
./rebuild.sh $build_ver 
sed  -i "s/$NEW_STRING/$ORIG_STRING/g" $FWCONFIG_FILE
build_ver=$(($build_ver+1))

echo $build_ver
done

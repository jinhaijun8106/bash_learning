BUILD_PATH=.
TARGET_PATH=/share/jinhaijun/images_ihelium_copy
TARGET_PATH_2=/share/jinhaijun/images_ihelium_copy.bak
TARGET_NAME=$1

rm $TARGET_PATH -rf
mkdir $TARGET_PATH -p
rm $TARGET_PATH_2 -rf
mkdir $TARGET_PATH_2 -p

#hexagon-llvm-objdump -disassemble-all WLAN_MERGED.elf >WLAN_MERGED_objdump.txt
hexagon-nm -print-file-name -print-size --debug-syms --numeric-sort WLAN_MERGED.elf >WLAN_MERGED_nm.txt

cp $BUILD_PATH/bin/QCAHLAWPDL/signed/wlanmdsp.mbn $TARGET_PATH/

cp $BUILD_PATH/WLAN_MERGED.elf $TARGET_PATH/
cp $BUILD_PATH/*.map $TARGET_PATH/
cp $BUILD_PATH/*.txt $TARGET_PATH/
cp $BUILD_PATH/*.csv $TARGET_PATH/

#tbd, board data

cp $TARGET_PATH/* $TARGET_PATH_2/ -rf
if [ "$1" != "" ] ;
TARGET_NAME=$TARGET_PATH$1
then
rm -rf $TARGET_NAME
mkdir -p $TARGET_NAME/
cp $TARGET_PATH/* $TARGET_NAME/ -rf
fi

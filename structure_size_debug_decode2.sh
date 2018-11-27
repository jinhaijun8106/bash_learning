#!/bin/bash
elffile=CNSS_RAM_V1_TO_LINK_PATCHED_6390.wlanfw.eval_v1_TOQ_link1.elf
output=./output_struct_size
debugelf=$output/6390_dwarfdump.txt
debugelf_process=$output/6390_dwarfdump_processing.txt
output_file="$output/structure_listed.csv"
output_file_processed="$output/structure_listed_processed.csv"

if [ "x$1" != "x" ] ; then
elffile=$1
fi

if [ 0 == 1 ] ;then
rm -rf $output
mkdir -p $output
dwarfdump $elffile >$debugelf
#read 3 lines before, 2 lines after, and there are total 3 + 1 + 2 + 1 lines for each finding
grep -B 3 -A 3 DW_TAG_structure_type $debugelf >$debugelf_process
fi



# Set "," as the field separator using $IFS
# and read line by line using while read combo
#need at two parameters, source path and fwconfig head files path
#fwconfig head files should be moved to a seperate folder to process


echo "structure name, typedef name, #size, #file" > $output_file_processed

#xxx: abbrev Number: 47(DW_TAG_typedef)
# DW_AT_name:(indirecting string> : mlme_preauth_t
readlines=0
typedefname=""
structname=""
structdefpath=""
structsize="0"

while IFS=' ' read -r oneline
do
  if [ "x$oneline" == "x--" ] ;then
    #echo "$structname,$typedefname,$structsize" 
    if [ "x$structname" != "x" ] || [ "x$typedefname" != "x" ] ;then
        echo "$structname,$typedefname,$structsize,$structdefpath" >>$output_file
    fi
    readlines=0;
    typedefname=""
    structname=""
    structdefpath=""
    structsize="0"
  else
    readlines=$(($((readlines))+1))
  fi

  if [ $((readlines)) == 1 ] ;then
    if [ "x$(echo $oneline | grep "DW_AT_name")" != "x" ] ;then
        typedefname=$(echo $oneline | awk -F" " '{print $NF}')
    fi

  elif [ "x$(echo $oneline | grep "DW_AT_name")" != "x" ] ;then
        structname=$(echo $oneline | awk -F" " '{print $NF}')
  elif [ "x$(echo $oneline | grep "DW_AT_byte_size")" != "x" ] ;then
        structsize=$(echo $oneline | awk -F" " '{print $NF}')
  elif [ "x$(echo $oneline | grep "DW_AT_decl_file")" != "x" ] ;then
        structdefpath=$(echo $oneline | awk -F" " '{print $NF}')
  fi

done < $debugelf_process

cat $output_file | sort -u >>$output_file_processed
echo "result: $output_file_processed"


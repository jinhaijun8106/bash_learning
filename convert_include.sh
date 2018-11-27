#!/bin/bash
source_path="src"

# Set "," as the field separator using $IFS 
# and read line by line using while read combo 
#need at two parameters, source path and fwconfig head files path
#fwconfig head files should be moved to a seperate folder to process

if [ "$1" == "" ]; then
   echo "please input one paramters, source code path"
    exit
fi
source_path=$1

matched_files=$(find $source_path -name "*.c")
matched_files+=$(find $source_path -name "*.h")
temp_converted_file=/tmp/tmp_converted_file

#check
opened_files=$(p4 opened | xargs grep "edit")
if [ "$opened_files" != "" ] ;then
    echo "please close all opened files"
    exit
fi

for filename in $matched_files
do
    checked_out=0
    rm  -rf $temp_converted_file

    while IFS='' read -r line 
    do 
        #match #include ""
        matched=$(echo $line | grep "#include" | awk -F'"' '{print NF-1}')
        if [ "x$((matched))" != "x" ] && [ $((matched)) -gt 1 ] ;then
            if [ "$checked_out" == "0" ];then
                p4 edit $filename
                checked_out=1
            fi
            
            line=$(echo $line | sed "s/\"/</" | sed "s/\"/>/")
        fi
        echo "$line" >> $temp_converted_file
    done < "$filename"
    if [ "$checked_out" == "1" ];then
        cp $temp_converted_file $filename
    fi

done  #filename

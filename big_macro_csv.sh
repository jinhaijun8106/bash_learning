#!/bin/bash
source_code_path="src"
source_code_type="*.c"
source_code_type1="*.h"
output_path=".output_macro"
big_macro_find_tool="big_macro_defined.sh"

big_macros_file_found="result_big_macros_defined.txt"

output_file="big_macro_listed.csv"

# Set "," as the field separator using $IFS 
# and read line by line using while read combo 
#need at two parameters, source path and fwconfig head files path
#fwconfig head files should be moved to a seperate folder to process

if [ "$1" == "" ]; then
   echo "please input one paramters, source code path"
    exit
fi
source_code_path=$1

#./$big_macro_find_tool $source_code_path $big_macros_file_found

echo "MACRO name,#size (lines),#refer cnt in source,#refer cnt in head files, #refer in total" > $output_file


matched_files1=$(find $source_path -name $source_code_type)
matched_file2=$(find $source_path -name $source_code_type1)
matched_files="$matched_files1"
matched_files+="$matched_files2"

last_macro=""
last_macro_lines=0
while IFS=' ' read -r f1 f2 
do 
    if [ "$last_macro" == "$f1" ] ;then
        if [ $f2 > $last_macro_lines ] ;then
            last_macro_lines=$f2
        fi
    elif [ "$last_macro" != "$f1" ];then
        if [ "$last_macro" != "" ] ;then
            total_called1=$(find -name "*.c" | xargs grep "$last_macro(" | sed "#define/d" | wc -l)
            total_called2=$(find -name "*.h" | xargs grep "$last_macro(" | sed "#define/d" | wc -l)
            total_called=$(($total_called1 + $total_called2))
            echo $last_macro $last_macro_lines $total_called1 $total_called2 $total_called
            echo $last_macro,$last_macro_lines,$total_called1,$total_called2, $total_called >>$output_file
        fi
        last_macro="$f1"
        last_macro_lines=$f2
    fi
done < "$output_path/$big_macros_file_found"
total_called=$(find -name "*.c" | xargs grep "$last_macro" | sed "#define/d" | wc -l)
total_called2=$(find -name "*.h" | xargs grep "$last_macro" | sed "#define/d" | wc -l)
echo $last_macro $last_macro_lines $total_called $total_called2
echo $last_macro,$last_macro_lines,$total_called,$total_called2 >>$output_file

echo "result: $output_file"

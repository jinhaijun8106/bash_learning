#!/bin/bash

#used to find all the referenced MACRO in the source code
#usage source_code_macro_find.sh $source_path $output_result_file
#
source_path=./
output_path=".output_macro"
source_code_type="*.c"
source_code_type1="*.h"
macro_pattern="#define "
output_temp_defined_file="temp_big_macros_defined.txt"
output_result_defined_file="result_big_macros_defined.txt"


if [ "$1" == "" ]; then
    echo "please inputthe source code path"
    exit
fi
source_path=$1
if [ "$2" != "" ]; then
    output_result_defined_file=$2
fi

echo "source_path: $source_path" 
echo "output file defined: $output_path/$output_result_defined_file"

mkdir -p $output_path
rm -f $output_path/$output_result_defined_file
rm -f $output_path/$output_temp_defined_file
touch $output_path/$output_temp_defined_file

matched_files1=$(find $source_path -name $source_code_type)
matched_files2=$(find $source_path -name $source_code_type1)
matched_files="$matched_files1"
matched_files+="$matched_files2"

#0: search, 1: adding
found_stage=0
found_cnt=0
for filename in $matched_files
do
    while IFS=' ' read -r f1
    do
        if [ $found_stage == 0 ];then
            BIG_MACRO=$(echo $f1 | awk '{ if ( $1 == "#define" && $NF == "\\" ) print $2 }' | awk -F "(" '{print $1}')
            if [ "$BIG_MACRO" != "" ] ;then
                found_stage=1
                found_cnt=0;
            fi
        elif [ $found_stage == 1 ];then

            still_this_macro=$(echo $f1 | awk '{ if ($NF == "\\" || $NF == "}\\") print $1}') 

            if [ "$still_this_macro" != '' ];then
                found_cnt=$(($found_cnt+1))
            elif [ "$still_this_macro" == '' ];then
            
                if [ $found_cnt != 0 ]; then
                    echo "$BIG_MACRO" "$found_cnt" >> $output_path/$output_temp_defined_file
                fi
                echo "$BIG_MACRO" "$found_cnt" 
                found_stage=0
                found_cnt=0
            fi
        fi
    done < $filename
done

cat $output_path/$output_temp_defined_file | sort -u > $output_path/$output_result_defined_file

exit 

cp $output_path/$output_raw_file $output_path/$output_sed_file
sed -i 's/:/ /g' $output_path/$output_sed_file
awk '{ if ($2 == "#define" && $3 != "") print $3 }' $output_path/$output_sed_file | sort -u > $output_path/$output_awk_file 
awk '$1~/^[a-zA-Z]/' $output_path/$output_awk_file >  $output_path/$output_result_defined_file

cp $output_path/$output_raw_file $output_path/$output_sed_file
sed -i 's/:/ /g' $output_path/$output_sed_file
awk '{ if ($2 == "#undef" && $3 != "") print $3 }' $output_path/$output_sed_file | sort -u > $output_path/$output_awk_file 


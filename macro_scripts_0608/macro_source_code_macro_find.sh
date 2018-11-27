#!/bin/bash

#used to find all the referenced MACRO in the source code
#usage source_code_macro_find.sh $source_path $output_result_file
#
source_path=./
output_path=".output_macro"
source_code_type="*.c"
macro_pattern="#if"
output_raw_file="raw_output.txt"
output_sed_file="sed_output.txt"
output_awk_file="awk_output.txt"
output_result_file="result_macros_source_found.txt"


if [ "$1" == "" ]; then
    echo "please input the source code path"
    exit
fi
source_path=$1
if [ "$2" != "" ]; then
    output_result_file=$2
fi

echo "source_path: $source_path" 
echo "output file: $output_path/$output_result_file"

mkdir -p $output_path
find $source_path -name $source_code_type | xargs grep $macro_pattern > $output_path/$output_raw_file
sed 's/(/ /g' $output_path/$output_raw_file > $output_path/$output_sed_file
sed -i 's/)/ /g' $output_path/$output_sed_file
sed -i 's/=/ /g' $output_path/$output_sed_file
sed -i 's/!/ /g' $output_path/$output_sed_file
sed -i 's/:/ /g' $output_path/$output_sed_file
sed -i 's/ $//' $output_path/$output_sed_file
sed -i 's/ 0$//' $output_path/$output_sed_file
sed -i 's/ 1$//' $output_path/$output_sed_file
sed -i 's/  */ /g' $output_path/$output_sed_file
sed -i 's/#if defined/#ifdefined/' $output_path/$output_sed_file
sed -i 's/#if !defined/#ifndefined/' $output_path/$output_sed_file
awk '{ if ($3 != "") print $3 }' $output_path/$output_sed_file | sort -u > $output_path/$output_awk_file 

awk '$1~/^[a-zA-Z_]/' $output_path/$output_awk_file >  $output_path/$output_result_file


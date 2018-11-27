#!/bin/bash

#used to find all the referenced MACRO in the source code
#usage source_code_macro_find.sh $source_path $output_result_file
#
source_path=./
output_path=".output_macro"
source_code_type="*.h"
macro_pattern="#define "
macro_pattern_undef="#undef "
output_raw_file="raw_output.txt"
output_sed_file="sed_output.txt"
output_awk_file="awk_output.txt"
output_result_defined_file="result_macros_fwconfig.defined.txt"
output_result_undefined_file="result_macros_fwconfig.undefined.txt"


if [ "$1" == "" ]; then
    echo "please input the fwconfig files folder"
    exit
fi
source_path=$1

if [ "$2" != "" ]; then
    output_result_defined_file=$2
fi
if [ "$3" != "" ]; then
    output_result_undefined_file=$3
fi

echo "source_path: $source_path" 
echo "output file defined: $output_path/$output_result_defined_file"
echo "output file undefined: $output_path/$output_result_undefined_file"

mkdir -p $output_path
find $source_path -name $source_code_type | xargs grep $macro_pattern > $output_path/$output_raw_file

cp $output_path/$output_raw_file $output_path/$output_sed_file
sed -i 's/:/ /g' $output_path/$output_sed_file
awk '{ if ($2 == "#define" && $3 != "") print $3 }' $output_path/$output_sed_file | sort -u > $output_path/$output_awk_file 
awk '$1~/^[a-zA-Z]/' $output_path/$output_awk_file >  $output_path/$output_result_defined_file

find $source_path -name $source_code_type | xargs grep $macro_pattern_undef > $output_path/$output_raw_file
cp $output_path/$output_raw_file $output_path/$output_sed_file
sed -i 's/:/ /g' $output_path/$output_sed_file
awk '{ if ($2 == "#undef" && $3 != "") print $3 }' $output_path/$output_sed_file | sort -u > $output_path/$output_awk_file 
awk '$1~/^[a-zA-Z]/' $output_path/$output_awk_file >  $output_path/$output_result_undefined_file


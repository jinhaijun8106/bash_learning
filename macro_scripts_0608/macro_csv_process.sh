#!/bin/bash
source_code_path="src"
fwconfig_path="fwconfig"
output_path=".output_macro"
source_code_find_tool="macro_source_code_macro_find.sh"
source_code_defined_tool="macro_source_code_macro_defined.sh"
fwconfig_defined_tool="macro_fwconfig_macro_defined.sh"

source_macros_file_found="result_macros_source_found.txt"
source_macros_file_defined="result_macros_source_defined.txt"
source_macros_file_undefined="result_macros_source_undefined.txt"

fwconfig_files_macro_defined="result_macros_fwconfig.defined.txt"
fwconfig_files_macro_undefined="result_macros_fwconfig.undefined.txt"
output_file="macro_listed.csv"

# Set "," as the field separator using $IFS 
# and read line by line using while read combo 
#need at two parameters, source path and fwconfig head files path
#fwconfig head files should be moved to a seperate folder to process

if [ "$1" == "" ] || [ "$2" == "" ] ; then
   echo "please input two paramters, source code and fwconfig head file path"
    exit
fi
source_code_path=$1
fwconfig_path=$2

./$source_code_find_tool $source_code_path
./$source_code_defined_tool $source_code_path
./$fwconfig_defined_tool $fwconfig_path

echo "MACRO name,#defined in fwconfig,#undefined in fwconfig,#defined in source,#undefined in source" > $output_file

while IFS=',' read -r f1 
do 
  fwconfig_defined_found="$(awk '{ if ($1 == "'$f1'") print $1 }' $output_path/$fwconfig_files_macro_defined)"
  fwconfig_undefined_found="$(awk '{ if ($1 == "'$f1'") print $1 }' $output_path/$fwconfig_files_macro_undefined)"
  source_defined_found="$(awk '{ if ($1 == "'$f1'" && $1 != "") print $1 }' $output_path/$source_macros_file_defined)"
  source_undefined_found="$(awk '{ if ($1 == "'$f1'" && $1 != "") print $1 }' $output_path/$source_macros_file_undefined)"
  found1="NO"
  found2="NO"
  found3="NO"
  found4="NO"
  if [ "$fwconfig_defined_found" != "" ]; then
      found1="YES"
  fi
  if [ "$fwconfig_undefined_found" != "" ]; then
      found2="YES"
  fi
  if [ "$source_defined_found" != "" ]; then
      found3="YES"
  fi
  if [ "$source_undefined_found" != "" ]; then
      found4="YES"
  fi
  echo $f1 $found1 $found2 $found3 $found4
  echo "$f1, $found1, $found2, $found3, $found4" >> $output_file
done < "$output_path/$source_macros_file_found"

echo "result: $output_file"

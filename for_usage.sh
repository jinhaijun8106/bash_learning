#!/bin/bash
database="name age sex"
for id in $database
do
    echo $id
done

#declare -a array=("name" "age" "sex")
array=("name" "age" "sex")
arrayLen=${#array[@]}

for ((i = 0; i < $((arrayLen)); i++))
do
    echo $i "/" ${array[$i]}
done

#!/bin/bash

FILE_PATH_TEMP=./images_ihelium_copy
FILE_PATH_0=$FILE_PATH_TEMP
FILE_PATH_0+="0"
FILE_NAME_IDs="0 1 2 3 4 5 6 7 8"
array_data=(0 0 0 0 0 0 0 0 0)
array_percent=(0 0 0 0 0 0 0 0 0)
FILE_NAME=WLAN_MERGED_nm.txt
FILE_SUM_CSV=static_mem_stats.M8998QCAHLAWPDLQ0000_USER_MERGED.just_sums.csv
FILE_NO_SUM_CSV=static_mem_stats.M8998QCAHLAWPDLQ0000_USER_MERGED.no_sums.csv

FILE_NAME_OUTPUT_OBJ_SIZE_SUM_RESULT=diag_obj_size_sum_analysis.csv
FILE_NAME_OUTPUT_OBJ_SIZE_RESULT=diag_obj_size_analysis.csv
FILE_NAME_OUTPUT_OBJ_PERCENT_SUM_RESULT=diag_obj_percent_sum_analysis.csv
FILE_NAME_OUTPUT_OBJ_PERCENT_RESULT=diag_obj_percent_analysis.csv

#FUNCTIONS=$(awk ' { if ($4 == "t" && $5 != "") print $5} ' $FILE_PATH_0/$FILE_NAME)
#FUNCTIONS+=$(awk ' { if ($4 == "T" && $5 != "") print $5} ' $FILE_PATH_0/$FILE_NAME)
FULL_PATH_OBJS=$(grep "\.c,(sum)" $FILE_PATH_0/$FILE_SUM_CSV | sed "s/ //g")

#generate the objects percents
rm $FILE_NAME_OUTPUT_OBJ_SIZE_SUM_RESULT -rf
rm $FILE_NAME_OUTPUT_OBJ_SIZE_RESULT -rf
rm $FILE_NAME_OUTPUT_OBJ_PERCENT_SUM_RESULT -rf
rm $FILE_NAME_OUTPUT_OBJ_PERCENT_RESULT -rf
echo "path, obj name, func, text size(ALL enabled), text size (DBGLOG_VERBOSE(0)), DBGLOG_INFO(1), DBGLOG_INFO_LVL_1(2), DBGLOG_INFO_LVL_2(3), DBGLOG_WARN(4), DBGLOG_ERR(5), DBGLOG_LVL_MAX(6), all disabled (7)" > $FILE_NAME_OUTPUT_OBJ_SIZE_SUM_RESULT

echo "path, obj name, func, text size(ALL enabled), text size (DBGLOG_VERBOSE(0)), DBGLOG_INFO(1), DBGLOG_INFO_LVL_1(2), DBGLOG_INFO_LVL_2(3), DBGLOG_WARN(4), DBGLOG_ERR(5), DBGLOG_LVL_MAX(6), all disabled (7)" > $FILE_NAME_OUTPUT_OBJ_SIZE_RESULT

echo "path, obj name, func, text size(ALL enabled), log percents(DBGLOG_VERBOSE(0)), DBGLOG_INFO(1), DBGLOG_INFO_LVL_1(2), DBGLOG_INFO_LVL_2(3), DBGLOG_WARN(4), DBGLOG_ERR(5), DBGLOG_LVL_MAX(6), all disabled (7), log percent(all logs), log size(all logs)" > $FILE_NAME_OUTPUT_OBJ_PERCENT_SUM_RESULT

echo "path, obj name, func, text size(ALL enabled), log percents(DBGLOG_VERBOSE(0)), DBGLOG_INFO(1), DBGLOG_INFO_LVL_1(2), DBGLOG_INFO_LVL_2(3), DBGLOG_WARN(4), DBGLOG_ERR(5), DBGLOG_LVL_MAX(6), all disabled (7), log percent(all logs), log size(all logs)" > $FILE_NAME_OUTPUT_OBJ_PERCENT_RESULT

for EACH_OBJECT in $FULL_PATH_OBJS
do
    output_path=$(echo $EACH_OBJECT | awk -F, '{ print $1,"/",$2,"/",$3,"/",$4}' | sed "s/ //g" );
    output_obj=$(echo $EACH_OBJECT | awk -F, '{ print $5}' | awk -F/ '{ print $NF}' );
    output_string=$output_path,$output_obj,"(sum)"
    output_percent=$output_string
 
    if [ "$output_obj" == "" ] ;then
        echo "error, obj is empty"
        continue;
    fi
    #summary the objects info
    for EACH_ID in $FILE_NAME_IDs
    do
        FILE_PATH_EACH=$FILE_PATH_TEMP$EACH_ID
        EACH_ID_OBJ=$(grep "\.c,(sum)" $FILE_PATH_EACH/$FILE_SUM_CSV | sed "s/ //g" | grep $output_obj)
        EACH_ID_SRC=$(echo $EACH_ID_OBJ | awk -F, '{ print $5}')
        EACH_ID_OBJ_SIZE=$(echo $EACH_ID_OBJ | awk -F, '{ print $7}')
        #echo $output_string
        array_data[$((EACH_ID))]=$(($EACH_ID_OBJ_SIZE));
        array_percent[$((EACH_ID))]=0;
        output_string+=", ${array_data[$((EACH_ID))]}"

        if [ $((EACH_ID)) != 0 ] && [ ${array_data[0]} != 0 ]; then
           array_percent[$((EACH_ID))]=$(((${array_data[$(($EACH_ID - 1))]} - ${array_data[$((EACH_ID))]}) * 100 /${array_data[0]}));
        else
            #the 0's saved the org text size
           array_percent[$((EACH_ID))]=${array_data[$((EACH_ID))]}
        fi
        output_percent+=", ${array_percent[$((EACH_ID))]}"
    done

    if [ ${array_data[0]} != ${array_data[8]} ];then
        total_log_percent=$(((${array_data[$((0))]} - ${array_data[$((8))]}) * 100 /${array_data[0]}));
        total_log_size=$((${array_data[$((0))]} - ${array_data[$((8))]} ));
        output_percent+=",$total_log_percent"
        output_percent+=",$total_log_size"
        echo $output_string 
        echo $output_percent 
        echo $output_string >> $FILE_NAME_OUTPUT_OBJ_SIZE_SUM_RESULT
        echo $output_string >> $FILE_NAME_OUTPUT_OBJ_SIZE_RESULT
        echo $output_percent >> $FILE_NAME_OUTPUT_OBJ_PERCENT_SUM_RESULT
        echo $output_percent >> $FILE_NAME_OUTPUT_OBJ_PERCENT_RESULT
    fi

    FUNCTIONS_STRINGS=$(grep $output_obj $FILE_PATH_0/$FILE_NO_SUM_CSV | sed "s/ //g")
    
    #search each func size in each output
    for FUNCTION_STRING in $FUNCTIONS_STRINGS
    do
        EACH_FUNC_NAME=$(echo $FUNCTION_STRING | awk -F, ' { print $6} ')
        EACH_FUNC_TEXT_SIZE=$(echo $FUNCTION_STRING | awk -F, ' { print $7} ')
        output_string=$output_path,$output_obj,$EACH_FUNC_NAME
        output_percent=$output_string
        if [ "$EACH_FUNC_NAME" == "" ]; then
            continue;
        fi
        if [ $EACH_FUNC_TEXT_SIZE == 0 ] ;then
            continue;
        fi

        for EACH_ID in $FILE_NAME_IDs
        do
            FILE_PATH_EACH=$FILE_PATH_TEMP$EACH_ID
            EACH_ID_FUNC_TEXT_SIZE=$(grep $output_obj $FILE_PATH_EACH/$FILE_NO_SUM_CSV | sed "s/ //g" | grep ",$EACH_FUNC_NAME," |  awk -F, ' { print $7}')

            array_data[$((EACH_ID))]=$(($EACH_ID_FUNC_TEXT_SIZE));
            array_percent[$((EACH_ID))]=0;

            output_string+=", ${array_data[$((EACH_ID))]}"
            if [ $((EACH_ID)) != 0 ] && [ ${array_data[0]} != 0 ]; then
                array_percent[$((EACH_ID))]=$(((${array_data[$(($EACH_ID - 1))]} - ${array_data[$((EACH_ID))]}) * 100 /${array_data[0]}));
            else
                #the 0's saved the org text size
                array_percent[$((EACH_ID))]=${array_data[$((EACH_ID))]}
            fi
            if [ ${array_data[$((EACH_ID))]} != 0 ];then
                output_percent+=", ${array_percent[$((EACH_ID))]}"
            else
                output_percent+=", inlined"
            fi
        done   #EACH_ID
        if [ ${array_data[0]} != ${array_data[8]} ];then
            total_log_percent=$(((${array_data[$((0))]} - ${array_data[$((8))]}) * 100 /${array_data[0]}));
            total_log_size=$((${array_data[$((0))]} - ${array_data[$((8))]} ));
            output_percent+=",$total_log_percent"
            output_percent+=",$total_log_size"
            echo $output_string 
            echo $output_percent 
            echo $output_string >> $FILE_NAME_OUTPUT_OBJ_SIZE_RESULT
            echo $output_percent >> $FILE_NAME_OUTPUT_OBJ_PERCENT_RESULT
        fi

    done   #FUNCTION_STRING


done #each obj

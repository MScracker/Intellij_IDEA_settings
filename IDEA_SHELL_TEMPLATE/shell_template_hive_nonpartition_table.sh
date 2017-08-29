#!/bin/bash
#set( $asterisk = "*" )
# Description: ${DESCRIPTION}
# Author: ${USER}
# Time: ${YEAR}-${MONTH}-${DAY} ${TIME}
# Dependency: ${INPUT}
# Output: ${OUTPUT}

set -ex
username="pms"
export HADOOP_USER_NAME=${DS}{username}
hostname=`hostname -f`
case "${DS}{hostname}" in
    *test*)
         case "${DS}{hostname}" in
             jqhadoop-test221-20.int.yihaodian.com)
                 echo "Test manual schedule."
                 if [[ -z "${DS}1" ]] ;then
                    sql_entry="beeline -u jdbc:hive2://10.17.221.20:20402 -n pms"
                 else
                    sql_entry="${DS}1"
                 fi
                 if [[ -z "${DS}2" ]] ;then
                    yesterday=`date -d "yesterday" +"%Y-%m-%d"`
                 else
                    yesterday="${DS}2"
                 fi
             ;;
             *)
                 echo "Test oozie schedule."
                 hdfs dfs -get /user/spark/prd_conf spark_tmp_conf_dir
                 CONF_DIR=`pwd`/spark_tmp_conf_dir
                 export HADOOP_CONF_DIR=${DS}{CONF_DIR}
                 export HIVE_CONF_DIR=${DS}{CONF_DIR}
             ;;
         esac
    ;;
    *)
        case "${DS}{hostname}" in
            yhd-jqhadoop200.int.yihaodian.com)
                echo "Production manual schedule."
                if [[ -z "${DS}1" ]] ;then
                    sql_entry="beeline -u jdbc:hive2://10.17.28.173:10000 -n pms -p  'pms@)!%' -hiveconf mapred.job.queue.name=pms"
                else
                    sql_entry="${DS}1"
                fi
                if [[ -z "${DS}2" ]] ;then
                    yesterday=`date -d "yesterday" +"%Y-%m-%d"`
                else
                    yesterday="${DS}2"
                fi
             ;;
             *)
                echo "Production oozie schedule."
                hdfs dfs -get /user/spark/conf spark_tmp_conf_dir
                CONF_DIR=`pwd`/spark_tmp_conf_dir
                export SPARK_CONF_DIR=${DS}{CONF_DIR}
                export HIVE_CONF_DIR=${DS}{CONF_DIR}
                export HADOOP_USER_NAME=${DS}{username}
             ;;
         esac
    ;;
esac

input="${INPUT}"
output="${OUTPUT}"

echo "sql_entry=${DS}sql_entry"
echo "yesterday=${DS}yesterday"

data_check=`hdfs dfs -du -s /user/hive/warehouse/${DS}{input%.*}.db/${DS}{input#$asterisk.} | awk -F' ' '{print ${DS}1}'`
if [[ ${DS}data_check -gt 0 ]]; then
    echo "In the script "${DS}0",Suceed in checking data of input:${DS}{input}."
else
    echo "In the script "${DS}0",Failed to obtain data of input:${DS}{input}!!!"
    exit -1
fi













data_check=`hdfs dfs -du -s /user/hive/warehouse/${DS}{output%.*}.db/${DS}{output#$asterisk.} | awk -F' ' '{print ${DS}1}'`
if [[ ${DS}data_check -gt 0 ]]; then
    echo "In the script "${DS}0",Suceed in producing data of output:${DS}{output}."
else
    echo "In the script "${DS}0",Failed to produce data of output:${DS}{output}!!!"
    exit -1
fi
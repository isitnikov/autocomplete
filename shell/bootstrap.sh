#!/usr/bin/env bash
DIRNAME=`dirname $0`
ROOT_DIRNAME=`dirname ${DIRNAME}`
DATA_DIRNAME=`echo "${ROOT_DIRNAME}/data"`
LOG_DIRNAME=`echo "${ROOT_DIRNAME}/log"`
SQL_DIRNAME=`echo "${ROOT_DIRNAME}/sql"`

source "${DIRNAME}/config.sh.dist"

if [ -f "${DIRNAME}/config.sh" ];
then
    source "${DIRNAME}/config.sh"
fi

MYSQL_CONNECT_LINE="mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOST} --port=${MYSQL_PORT} ${MYSQL_DATABASE}"

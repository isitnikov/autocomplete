#!/usr/bin/env bash
DIRNAME=`dirname $0`
source "${DIRNAME}/bootstrap.sh"

if [ ! -f "${DATA_DIRNAME}/${DATA_FILE}" ];
then
    echo "Error! Data file ${DATA_FILE} is not found!"
    exit 1
fi

for TABLE in `mdb-tables ${DATA_DIRNAME}/${DATA_FILE}`;
do
    printf "Removing table ${TABLE}... "
    `${MYSQL_CONNECT_LINE} -e "SET foreign_key_checks = 0; DROP TABLE ${TABLE}; SET foreign_key_checks = 1;" 2>${LOG_DIRNAME}/install.log`

    if [ "$?" ];
    then
        printf "OK!\n"
    else
        printf "Failed!\n"
    fi
done

printf "Creating tables...\n"
mdb-schema ${DATA_DIRNAME}/${DATA_FILE} | pv | sed 's/[][]//g' | sed 's/Long Integer/int/g' | $MYSQL_CONNECT_LINE --force 2>${LOG_DIRNAME}/install.log

if [ "$?" ];
then
    for TABLE in `mdb-tables ${DATA_DIRNAME}/${DATA_FILE}`;
    do
        if [ -f "${SQL_DIRNAME}/afterCreate/${TABLE}.sql" ];
        then
            printf "Applying SQL upgrade for table ${TABLE} after its creating... "
            `$MYSQL_CONNECT_LINE 2>${LOG_DIRNAME}/install.log < ${SQL_DIRNAME}/afterCreate/${TABLE}.sql`

            if [ "$?" ];
            then
                printf "OK!\n"
            else
                printf "Failed!\n"
            fi
        fi
    done

    printf "OK!"
else
    printf "Failed!"
fi
printf "\n\n"

for TABLE in `mdb-tables ${DATA_DIRNAME}/${DATA_FILE}`;
do
    printf "Inserting into table ${TABLE}...\n"
    mdb-export -I mysql ${DATA_DIRNAME}/${DATA_FILE} ${TABLE} | pv | sed -e 's/)$/)\;/' | $MYSQL_CONNECT_LINE 2>${LOG_DIRNAME}/install.log

    if [ "$?" ];
    then
        printf "OK!"
    else
        printf "Failed!"
    fi
    printf "\n\n"
done

for TABLE in `mdb-tables ${DATA_DIRNAME}/${DATA_FILE}`;
do
    if [ -f "${SQL_DIRNAME}/afterInsert/${TABLE}.sql" ];
    then
        printf "Applying SQL upgrade for table ${TABLE} after inserting data... "
        `$MYSQL_CONNECT_LINE 2>${LOG_DIRNAME}/install.log < ${SQL_DIRNAME}/afterInsert/${TABLE}.sql`

        if [ "$?" ];
        then
            printf "OK!\n"
        else
            printf "Failed!\n"
        fi
    fi
done

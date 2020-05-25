#!/bin/bash

################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=$(date +%Y-%m-%d)  ## Current date formatted as : 2020-12-01 — If you change the format, also change it below for the remove older backups part of the script.
HOSTNAME=$(hostname -s)  ## Or put whatever name you want in quotes instead of $(...)

################################################################
################## Update below values  ########################

DB_BACKUP_PATH='/root/Backups'  ## This is the path where the local backups will be stored
WEBSITE_BACKUP_PATH='/var/www/html/invoiceninja/'  ## The path to the web app
WEBSITE_ARCHIVE_FILE="invoice-ninja-website-$TODAY.tar.gz"  ## The name of the archive for the web app
MYSQL_PORT='3306'
BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy

#################################################################
############# Parse required values from .env file  #############

DB_TYPE='DB_TYPE'
DB_HOST='DB_HOST'
DB_DATABASE='DB_DATABASE'
DB_USERNAME='DB_USERNAME'
DB_PASSWORD='DB_PASSWORD'

while IFS="=" read -r key value; do
    if [ $key = $DB_HOST ]
    then
        MYSQL_HOST=$value
    fi

    if [ $key = $DB_DATABASE ]
    then
        DATABASE_NAME=$value
    fi

    if [ $key = $DB_USERNAME ]
    then
        MYSQL_USER=$value
    fi

    if [ $key = $DB_PASSWORD ]
    then
        MYSQL_PASSWORD=$value
    fi
done < $WEBSITE_BACKUP_PATH.env

#################################################################

mkdir -p ${DB_BACKUP_PATH}/${TODAY}
echo "Backup started for SQL database \'${DATABASE_NAME}\' to ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz"

mysqldump -h ${MYSQL_HOST} \
   -P ${MYSQL_PORT} \
   -u ${MYSQL_USER} \
   -p${MYSQL_PASSWORD} \
   ${DATABASE_NAME} | gzip > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz
if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
  exit 1
fi

##### Backup invoice ninja folder  #####

#print start status message
echo "Backing up $WEBSITE_BACKUP_PATH to $DB_BACKUP_PATH/$WEBSITE_ARCHIVE_FILE"

# Backup the files using tar
tar czf ${DB_BACKUP_PATH}/${TODAY}/${WEBSITE_ARCHIVE_FILE} ${WEBSITE_BACKUP_PATH}

# print end message
echo
echo "Backup finished"

##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

DBDELDATE=$(date -d "${BACKUP_RETAIN_DAYS} days ago" +%Y-%m-%d) ## if you changed the format for the TODAY variable, also change it here.

if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi

### End of script ####

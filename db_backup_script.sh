#! /bin/bash

# CREATED BY MASTERBOOTRECORD32 FOR LOTHRINGER OPENAURORE: https://openaurore.ddns.net/
# LICENSED UNDER CUSTOM MOZILLA PUBLIC LICENSE

# VARIABLES
backupdir/path/to/your/backupdir # FOR EXAMPLE /var/lib/backup/websrv/dev-disk-by-uuid-08ea453b-feff-47c2-8ba5-2aefc7109624/backup/databases
recipient_email=youremail@yourdomain.com
user=yourMysqlUser # THE USERNAME OF YOUR MYSQL USER (THE USER SHOULD HAVE ACCESS TO ALL THE DATABASES YOU WANT TO BACKUP)
mysqlpass='mysqlUserPassword' # THE PASSWORD OF OF YOUR MYSQL USER 
keep_day=120 # NUMBER OF DAYS YOU WANT TO KEEP OLDER BACKUPS
dbname1=nameOfYourDatabase1 # THE NAME OF THE FIRST DATABASE YOU WANT TO BACKUP
dbname2=nameOfYourDatabase2 # THE NAME OF THE SECOND DATABASE YOU WANT TO BACKUP
sqlfile1=${backupdir}/${dbname1}-$(date +%d-%m-%Y_%H-%M-%S).sql # THE NAME OF THE FIRST DATABASE DUMP AND ITS SAVING LOCATION
zipfile1=${backupdir}/${dbname1}-$(date +%d-%m-%Y_%H-%M-%S).zip # THE NAME OF THE FIRST ZIP BACKUP AND ITS SAVING LOCATION
sqlfile2=${backupdir}/${dbname2}-$(date +%d-%m-%Y_%H-%M-%S).sql # THE NAME OF THE SECOND DATABASE DUMP AND ITS SAVING LOCATION
zipfile2=${backupdir}/${dbname2}-$(date +%d-%m-%Y_%H-%M-%S).zip # THE NAME OF THE SECOND ZIP BACKUP AND ITS SAVING LOCATION

# SQL DUMP CREATION 
### DATABASE 1 DUMP
mysqldump -u ${user} -p${mysqlpass} ${dbname1} > ${sqlfile1} # CREATES A .sql FILE OF YOUR DATABASE IN YOUR BACKUP DIRECTORY
if [ $? -eq 0 ]; then
  echo 'Sql dump created' 
else
  echo 'mysqldump return non-zero code for your' ${dbname1} 'database' | mail -s 'No backup was created!' ${recipient_email} # IF THE DUMP FAILS, AN E-MAIL IS SENT TO ADMIN (NEEDS EXIM4 OR SENDMAIL TO BE CONFIGURED)
  exit 
fi 

### DATABASE 2 DUMP
mysqldump -u ${user} -p${mysqlpass} ${dbname2} > ${sqlfile2} # CREATES A .sql FILE OF YOUR DATABASE IN YOUR BACKUP DIRECTORY
if [ $? -eq 0 ]; then
  echo 'Sql dump created' 
else
  echo 'mysqldump return non-zero code for your' ${dbname2} 'database' | mail -s 'No backup was created!' ${recipient_email} # IF THE DUMP FAILS, AN E-MAIL IS SENT TO ADMIN
  exit 
fi

# BACKUP COMPRESSION 
### DATABASE 1 COMPRESSION
zip -P yourStrongPassword ${zipfile1} ${sqlfile1} # CREATES A ZIP FILE OF THE FIRST SQL DUMP: -P SECURES THE ZIP WITH A PASSWORD 
if [ $? -eq 0 ]; then
  echo 'The backup was successfully compressed' 
else
  echo 'Error compressing backup for your' ${dbname1} 'database' | mail -s 'Backup was not created!' ${recipient_email} # IF THE COMPRESSION FAILS, AN E-MAIL IS SENT TO ADMIN
  exit 
fi 
rm ${sqlfile1} # CLEANS THE DIRECTORY BY DELETING THE DUMP OF THE DATABASE
echo 'Backup for your' ${dbname1} 'database was successfully created and is located in' ${zipfile1} | mail -s 'Backup was successfully created!' ${recipient_email} # IF THE BACKUP IS SUCCESSFULLY CREATED, AN E-MAIL IS SENT TO ADMIN

### DATABASE 2 COMPRESSION
zip -P yourStrongPassword ${zipfile2} ${sqlfile2} # CREATES A ZIP FILE OF THE SECOND SQL DUMP 
if [ $? -eq 0 ]; then
  echo 'The backup was successfully compressed' 
else
  echo 'Error compressing backup for your' ${dbname2} 'database' | mail -s 'Backup was not created!' ${recipient_email} # IF THE COMPRESSION FAILS, AN E-MAIL IS SENT TO ADMIN
  exit 
fi 
rm ${sqlfile2} # CLEANS THE DIRECTORY BY DELETING THE DUMP OF THE DATABASE
echo 'Backup for your' ${dbname2} 'database was successfully created and is located in' ${zipfile2} | mail -s 'Backup was successfully created!' ${recipient_email} # IF THE BACKUP IS SUCCESSFULLY CREATED, AN E-MAIL IS SENT TO ADMIN

# OLD BACKUPS DELETION
find ${backupdir} -mtime +${keep_day} -delete # DELETES BACKUPS OLDER THAN THE NUMBER OF DAYS CHOSEN IN ${keep_day}

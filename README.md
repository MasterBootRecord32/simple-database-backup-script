# Presentation
The goal of this simple BASH script is to automate the backup of databases on a MySQL Server using a minimal set of tools. 

# Features
- Backup one or multiple databases and compress the .sql dumps in a 7z archive ;
- Protect the archives with a custom password ;
- Set a custom backup location ;
- Set a custom name for the backups ;
- Send E-Mail at the end of each step ;
- Automatically delete backups older than a custom number of days ;

The code is made so that it is easy to read and understand and can be adapted to specific use-cases.

# Dependencies
- The `cron` job scheduler (optional if you prefer using Systemd timers) ;
- The `p7zip` CLI tool ;
- The `p7zip-plugins` pugins package ;
- A mail transfer agent such as `exim4`, `sendmail` or `ssmtp` ;

# Installation
1. Clone this repository in your home directory ;
2. Move `db_backup_script.sh` to a dedicated directory (for example, in a .script directory, in your home directory) ;
3. Edit the file to replace the placeholders with the wanted values:

In VARIABLES, replace at:
```
<webdir>, <backupdir>, <recipient_email>, <keep_day>, <webfiles1> and <webfiles2>
```
In BACKUP CREATION & COMPRESSION, replace at:
```
"yourStrongPassword"
```

4. Give the file execution permissions for the owner only and change owner to root:
```
# chmod 700 /path/to/the/.script/db_backup_script.sh && chown root:root /path/to/the/.script/db_backup_script.sh
```

5. Edit `/etc/crontab` and at the end, add:
```
00 0    1 * *   root    sh /path/to/the/.script/db_backup_script.sh
```
This will execute the script on the first of each month at 0:00.

6. If you prefer using a Systemd timer, you will need to create a timer and a service:

Execute ```# systemctl edit --full --force backup-db.service``` to create the service unit and add:
```
[Unit]
Description=Run the database backup script

[Service]
User=root
ExecStart= /path/to/the/.script/db_backup_script.sh
```
This will execute the db_backup_script.sh from your scripts directory with root privileges.

Then execute ```# systemctl edit --full --force backup-db.timer``` to create the timer unit and add:
```
[Unit]
Description=Run a database backup one time per month

[Timer]
OnCalendar=*-*-01 00:00:00
Persistent=true
Unit=backup-db.service

[Install]
WantedBy=timers.target
```
This will execute the backup-db service on the first of each month at 0:00.

Enable the timer unit using ```# systemctl enable backup-db.timer```.

7. To make sure there are no errors in the script, run it using:
```
# sh /path/to/the/.script/db_backup_script.sh
```

8. To make sure there are no errors in the timer and service units:

Start the timer manually:
```
# systemctl start backup-db.timer
```
Then check if the task is executed successfully with ```journalctl -xe```.

# WARNING !
THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE CODE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CODE OR THE USE OR OTHER DEALINGS IN THE CODE.

**THIS PROJECT MAY NOT BE USED FOR THE PURPOSE OF TRAINING OR IMPROVING MACHINE LEARNING ALGORITHMS. PLEASE, READ THE LICENSE'S TERMS.** 

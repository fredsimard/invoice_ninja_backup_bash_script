# Invoice Ninja backup bash script
A bash script to backup self-hosted Invoice Ninja data, including the MySQL database and the Webapp, locally then remotely.

## What it is
Due to the lack of built-in scripts to backup Invoice Ninja, and my need to create an external backup, I've put together a script with some options to backup the Invoice Ninja MySQL database and the web folder locally first, then a second script to copy this backup over SFTP/SSH. Then with a cronjob you can call it as often as you like.

The remote backup script will sync the contents of the local folder to the specified remote folder over SSH/SFTP. Details below on how to create a secure connection between the local and remote machines to enable this.

**IMPORTANT** : You need to have a public key from your local machine in the authorized keys of your remote machine. See below on how to accomplish this.

## Requirements and warnings
* This is for a system running under Ubuntu 18.0.4 server, although it should work fine in most recent Ubuntu releases, as well as any variant of Debian. It may require some tweaks.
* Save the script wherever you wish, just remember the full path for the remote backup script later.
* You need enough free space to keep the local backups on the disks where you specify to save them, otherwise change the maximum number of days to keep.
* Of course, use at your own risks.

## How to install
1. SSH into your invoice ninja server
2. Create a new file with `sudo nano /path/to/script.sh`, copy and paste the contents of the script, save (Ctrl-O, Ctrl-X).
3. Do a `sudo chmod +x /path/to/script.sh` to make it executable
4. Do the same steps for the remote backup script.
5. In the local backup script change the values where it says "Update below values", as detailed below.
6. In the remote backup script, also change the values (as detailed below).
7. Create a cronjob, unless you wish to do it manually. Instructions below.
8. You're good to go!

## Local script values

`DB_BACKUP_PATH` : This is the path where the local backups will be stored

`WEBSITE_BACKUP_PATH` : The path to the web app, usually `/var/www/html/invoiceninja/`

`WEBSITE_ARCHIVE_FILE` : The name of the archive for the web app. There is the `TODAY` variable included to make the name unique.

`MYSQL_HOST` : Usually localhost

`MYSQL_PORT` : Usually 3306

`MYSQL_USER` : Any SQL user that has sufficient privileges

`MYSQL_PASSWORD` : The SQL password that goes with the user specified above.

`DATABASE_NAME` : Whatever name you gave to the SQL database for invoice ninja.

`BACKUP_RETAIN_DAYS` : Number of days to keep local backup copies, an integer.

## Remote script values

`___REMOTE_HOST_PORT_NUMBER__` : If you're not using port 22 for the remote SSH connection, then put it here. Otherwise, either put 22 or remove the -p entirely.

`__FULL_PATH_TO_LOCAL_BACKUPS_FOLDER__` : The path specified in the local backup script.

`__USERNAME__` : The username for the SSH connection

`__IPADDRESS__` : The IP or FQDN (www.example.com) of the remote host.

`__FULL_PATH_TO_REMOTE_BACKUPS_FOLDER__` : The path where you wish to save the local backups to.

## How to setup a cron job

While still SSHed into the server:

`sudo crontab -e`

Then add these lines to the end of the file, and modify it to your liking.
```
0 2 * * * /bin/bash /path/to/local_script.sh.sh
30 2 * * * /bin/bash /path/to/remote_script.sh
```
This says to start the local backups at 2 AM every day, then start the remote backup at 2:30 AM every day.

## How to establish a secure connection between your server and the remote backup machine over SSH/SFTP

On the origin server, generate public SSH keys, do not specify a password if asked (hit enter):

`ssh-keygen -f ~/.ssh/id_rsa -q -P ""`

Then display the contents of that newly created key:

`cat ~/.ssh/id_rsa.pub`

Copy the entire string, including the leading ssh-rsa and the user@server at the end.

On your remote machine, log in with SSH, and do this command:
`nano ~/.ssh/authorized_keys`
And paste the contents at the end, on a new line. Save and exit nano (Ctrl-O, Ctrl-X).

If the file doesn't exist, here's how to create it:
```
mkdir ~/.ssh
chmod 0700 ~/.ssh
sudo touch ~/.ssh/authorized_keys
sudo chmod 0644 ~/.ssh/authorized_keys
```

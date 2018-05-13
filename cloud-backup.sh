#!/bin/bash
# laste changed 12. Jan. 2018 (sshfs)

#dirs without a slash at the end
sourcedir=/home/dhw
backupdir=/media/dhw/hetzner
excludefile=/home/dhw/bin/cloud-exclude.txt
label=dhw
ssh_identiyfile=/home/dhw/.ssh/hetzner_u159931 

#mount backup direcorty with sshfs
sshfs u159931@u159931.your-storagebox.de:/ $backupdir -o IdentityFile=$ssh_identiyfile -o idmap=user -o uid=$(id -u) -o gid=$(id -g)


cd $sourcedir

int_handler()
{
    echo "Interrupted."
    # Kill the parent process of the script.
    kill $PPID
    exit 1
}
trap 'int_handler' INT


#test if backupdir is mounted 
#if test -d $backupdir; then
if mount | grep $backupdir > /dev/null; then
    rsync -avzk --delete --log-file=/home/dhw/backup/cloud-backup_$(date +'%Y%m%d').log --exclude-from=/$excludefile "$sourcedir/" "$backupdir/$label"
else
    echo "Backup drive not found!"
fi

#unmount backup dirs
fusermount -u $backupdir

echo "Fertig!"
read -p "Drücke ENTER um dieses Fenster zu schliessen"

# We never reach this part.
exit 0

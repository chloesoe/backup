#!/bin/bash

#dirs without a slash at the end
backupdir=/media/dhw/hetzner

#mount backup direcorty with sshfs
sshfs u159931@u159931.your-storagebox.de:/ $backupdir -o IdentityFile=/home/dhw/.ssh/hetzner_u159931 -o idmap=user -o uid=$(id -u) -o gid=$(id -g)

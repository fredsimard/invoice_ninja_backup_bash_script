#!/bin/bash

rsync -avz -e "ssh -p ___REMOTE_HOST_PORT_NUMBER__ -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress __FULL_PATH_TO_LOCAL_BACKUPS_FOLDER__ __USERNAME__@__IPADDRESS__:__FULL_PATH_TO_REMOTE_BACKUPS_FOLDER__

### End of script ####
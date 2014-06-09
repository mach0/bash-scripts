#!/bin/bash
## 
## Usage  : ./docker_backup.sh
## Author : Werner Macho <werner.macho@gmail.com>
##
## Idea taken from   : http://blog.stefanxo.com/category/docker/
##
## Exports running docker containers
##

# Delete old backups? Any files older than $daystokeep will be deleted
# Default option     : 0
# Recommended option : 1
purgeoldbackups=1

# How many days should we keep the backups
daystokeep="7"

# This directory should have enough space to hold all docker containers
# at the same time
# Subdirectories will be automatically created and deleted after finish
backupdir="/tmp"

echo -e ""
echo -e "\e[1;31mBackup Docker\e[00m"
echo -e "\e[1;33m"$(date)"\e[00m"
echo -e ""

# Timestamp (sortable AND readable)
stamp=`date +"%Y_%m_%d"`

# List all running docker instances
instances=`docker ps -q --no-trunc` 

exportdir="$backupdir/docker"
if `test -d ${exportdir}`; then
    echo -e "Backupfolder is already there, skipping creation"
else
    mkdir ${exportdir}
fi

if [[ $# -eq 0 ]] ; then
# Loop the instances
    for container in ${instances}; do
        # Get info on each Docker container
        instancename=`docker inspect --format='{{.Name}}' ${container} | tr '/' '_'`
        imagename=`docker inspect --format='{{.Config.Image}}' ${container} | tr '/' '_'`

        # Define our filenames
        filename="$stamp-$instancename-$imagename.docker.tar.gz"
        exportfile="$exportdir/$filename"

        # Feedback
        echo -e "backing up \e[1;36m$container\e[00m"
        echo -e " container \e[1;36m$instancename\e[00m"
        echo -e " from image \e[1;36m$imagename\e[00m"

        # Dump and gzip
        echo -e " creating \e[0;35m$exportfile\e[00m"
        docker export "$container" | gzip -c > "$exportfile"

    done;
else
    didBackup=false
    for container in ${instances}; do
        # Get info on each Docker container
        instancename=`docker inspect --format='{{.Name}}' ${container} | tr '/' '_'`
        imagename=`docker inspect --format='{{.Config.Image}}' ${container} | tr '/' '_'`

        if [[ ${instancename} == _$1 ]] ; then
            # Define our filenames
            filename="$stamp-$instancename-$imagename.docker.tar.gz"
            exportfile="$exportdir/$filename"

            # Feedback
            echo -e "backing up \e[1;36m$container\e[00m"
            echo -e " container \e[1;36m$instancename\e[00m"
            echo -e " from image \e[1;36m$imagename\e[00m"

            # Dump and gzip
            echo -e " creating \e[0;35m$exportfile\e[00m"
            docker export "$container" | gzip -c > "$exportfile"
            didBackup=true
        fi
    done;
    if ! ${didBackup} ; then
        echo -e "Given name not found in list of available Containers"
        exit 1
    fi
fi

# Purge old backups

if [[ "$purgeoldbackups" -eq "1" ]]
then
    echo -e " \e[1;35mRemoving old backups...\e[00m"
    olderThan=`date -d "$daystokeep days ago" +%s`
    curDate=`date +%s`

    ls ${exportdir} | while read -r line;
    do
        fileDate=`stat -L --format %Y $exportdir/${line}`
        #echo -e $fileDate
        fileAge=`expr $curDate - $fileDate`
        #echo -e $fileAge
        if [[ ${fileDate} -lt ${olderThan} ]]
        then
            fileName=`echo ${line}`
            echo -e " Removing outdated backup \e[1;31m$fileName\e[00m"
            if [[ ${fileName} != "" ]]
            then
                rm "$fileName"
            fi
        fi
    done;
fi

# We're done
echo -e "\e[1;32mDocker Backup done!\e[00m"

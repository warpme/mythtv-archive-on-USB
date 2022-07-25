#!/bin/sh

#Usage:

# How to archive given recording
# 1.  Move desired recordings to archive group.
# 2.  Connect USB HDD and wait until all recordings will transfered.
# 3.  Unmount archive (run 'unmount_tv_archive.sh' script) and wait
#     until all previews will transfered.
# 4.  Disconnect USB HDD. Now all recordings in archive grou will
#     have (Ofline) prefix in title.
# 5.  You are done.
#
# How to watch archived recordings
# 1.  Connect USB HDD
# 2.  Wait until OSD dialog says "Recordings are avaliable. Now all
#     archived recordings are wihout (Ofline) prefix and are ready to
#     watch.
# 3.  Watch desired recordings.
# 4.  When You are done and want to disconnect USB HDD, unmount 
#     archive by runing 'unmount_tv_archive.sh' script.
# 5.  Wait untill OSD dialog says "You can disconnect USB drive"
# 6.  Disconnect USB HDD. Now all recordings in archive group 
#     are unavaliable and will have (Ofline) prefix in title.
# 7.  You are done.





# How to make new archive group
# 1.  Add new recrding group in MythTV. Best to do so is: enter
#     EPG; select program to record; choose recoordings options;
#     in recording group field select "create new group"; put new
#     name in dialog (like "5 Archiwum"); save this schedule. Group
#     apears when programed recordings will be recorded.
# 2.  Prepare USB HDD, format it.
# 3.  Make this HDD labeled "5_Archiwum" (remember: all spaces in
#     group name should be replaced by underscore.
# 4.  Run tv-archive.sh scrpt with group name & command "add"
#     i.e. 'run-tarchive.sh "5 Archiwum" add'
# 5.  Move desired recordings to archive group.
# 6.  Connect USB HDD and wait until all recordings will transfered.
# 7.  Unmount archive (run 'unmount_tv_archive.sh' script) and wait
#     until all previews will transfered.
# 8.  You are done.





# How to make given group an archived group (called i.e. "5 Archiwum")
# 1.  Prepare USB HDD, format it.
# 2.  Make this HDD labeled "5_Archiwum" (remember: all spaces in
#     group name should be replaced by underscore.
# 3.  Run tv-archive.sh scrpt with group name & command "add"
#     i.e. 'run-tarchive.sh "5 Archiwum" add'
# 4.  Connect USB HDD and wait until all recordings will transfered.
# 5.  Unmount archive (run 'unmount_tv_archive.sh' script) and wait
#     until all previews will transfered.
# 6.  You are done.





# How to move archivee rec. from "Old_Group" to "New_Group"
#
# 1.  Make sure there is no any new recordings to archive in "Old_Group"
# 2.  Unmount & dissconect USB HDD disk for "New_Group"
# 3.  Connect USB HDD disk for "Old_Group"
# 4.  Go to recordings screen and move desired recordings from
#     "Old_Group" to "New_Group"
# 5.  Open to edit to 'run-tvarchive.sh' script
# 6.  At begining of this file change "rec_path" from "/myth/tv" to
#     "/myth/tv-archive/<Old_Group>" dir.
# 7.  Connect USB HDD disk for "New_Group"
# 8.  Wait until recordings synchronization on USB HDD disk for "New_Group"
#     finish.
# 9.  Unmount & dissconect USB HDD disk for "New_Group"
# 10. Wait until previews synchronization on USB HDD disk for "New_Group"
#     finish.
# 11. Unmount & dissconect USB HDD disk for "Old_Group"
# 12. Wait until all files synchronization on USB HDD disk for "Old_Group"
#     finish.
# 13. Open againg "run-tvarchive.sh" script to edit
# 14. At begining of this file change "rec_path" from
#     "/myth/tv-archive/<Old_Group>" back to "/myth/tv/" dir.
# 15. You are done.
#

prev_tmp="/myth/tmp"
recordings="/myth/tv /myth/tv1"
log_path="/var/log"
version="3.0"
debug="0"




group_name=$1
action=$2

group=`echo $group_name | sed -e "s| |_|g" -e "s|/|-|g"`
arch_grp_name=`echo $group | sed -e "s|_| |g"`
arch_path="/myth/tv-archive/$group"

#Log() { echo >&2 "`date '+%H:%M:%S.%N'` ${myname##*/}: $*"; }

Log() { 
  echo >&2 "$*"
  echo >&2 "`date '+%H:%M:%S.%N'`: $*" >> $log_path/tv-archive-$group.log
}

Debug() { 
  if [ $debug = "1" ]; then
    echo "$*"
    echo >&2 "`date '+%H:%M:%S.%N'`: $*" >> $log_path/tv-archive-$group.log
  fi
}

Die() { echo >&2 "$*"; exit 1; }

if [ ! -e $log_path/tv-archive-$group.log ]; then
    touch $log_path/tv-archive-$group.log
fi

Log "TV Archive script (c)Piotr Oniszczuk v$version"

if [ -z "$group_name" ]; then
  Log ""
  Log "Call this script with 2 parameters:"
  Log " <group_name> <action>"
  Log "action can be:"
  Log "  \"connected\""
  Log "  \"disconnected\""
  Log "  \"add\""
  Log "  \"remove\""
  Log ""
  exit 1
fi

if [ -z "$action" ]; then
  Log ""
  Log "Call this script with 2 parameters:"
  Log " <group_name> <action>"
  Log "action can be:"
  Log "  \"connected\""
  Log "  \"disconnected\""
  Log "  \"add\""
  Log "  \"remove\""
  Log ""
  action="Not specified !"
fi

group=`echo $group_name | sed -e "s| |_|g" -e "s|/|-|g"`
arch_grp_name=`echo $group | sed -e "s|_| |g"`
arch_path="/myth/tv-archive/$group"

Log ""
Log "Script action                     : \"$action\""
Log "MythTV Recording Group to archive : \"$arch_grp_name\""
Log "MythTV StorageGroup to store      : \"$group\""
Log "Directories with source recordings: \"$recordings\""
Log "Directory to move recordings      : \"$arch_path\""

# Parameters to access DB
: ${MYTHCONFDIR:="$HOME/.mythtv"}
if [ -r "$MYTHCONFDIR/config.xml" ]; then
    export MYTHCONFDIR
    # mythbackend in Fedora packages has $HOME=/etc/mythtv
    elif [ -r "$HOME/config.xml" ]; then
        export MYTHCONFDIR="$HOME"
    elif [ -r "$HOME/.mythtv/config.xml" ]; then
        export MYTHCONFDIR="$HOME/.mythtv"
    elif [ -r "/home/mythtv/.mythtv/config.xml" ]; then
        export MYTHCONFDIR="/home/mythtv/.mythtv"
    elif [ -r "/etc/mythtv/config.xml" ]; then
        export MYTHCONFDIR="/etc/mythtv"
fi


# mythtv mysql database
if [ -r "$MYTHCONFDIR/config.xml" ]; then
    MYTHHOST=$(grep '<Host>'         <"$MYTHCONFDIR/config.xml" | sed -e 's/\s*<Host>\s*\(.*\)\s*<\/Host>\s*/\1/') #'
    MYTHUSER=$(grep '<UserName>'     <"$MYTHCONFDIR/config.xml" | sed -e 's/\s*<UserName>\s*\(.*\)\s*<\/UserName>\s*/\1/') #'
    MYTHPASS=$(grep '<Password>'     <"$MYTHCONFDIR/config.xml" | sed -e 's/\s*<Password>\s*\(.*\)\s*<\/Password>\s*/\1/') #'
    MYTHBASE=$(grep '<DatabaseName>' <"$MYTHCONFDIR/config.xml" | sed -e 's/\s*<DatabaseName>\s*\(.*\)\s*<\/DatabaseName>\s*/\1/') #'
    Log ""
    Log "Using database"
    Log "    -Host : $MYTHHOST"
    Log "    -User : $MYTHUSER"
    Log "    -Pass : $MYTHPASS"
    Log "    -Dbase: $MYTHBASE"
    Log ""
else
    Log "Can not find config.xml with DB settings!"
fi

# Process an SQL query
# $@=query
Sql() {
  [ -n "$MYTHBASE" ] || return 0
  #Log "mysql ${MYTHHOST:+-h$MYTHHOST} -u$MYTHUSER -p$MYTHPASS -D"$MYTHBASE" \"$@\""
  mysql ${MYTHHOST:+-h$MYTHHOST} -u$MYTHUSER -p$MYTHPASS -D"$MYTHBASE" "$@"
}










Log "Building list of recording to archive..."
rec_file_list=$(Sql -Bse "SELECT basename FROM recorded WHERE recgroup='$arch_grp_name';")

if [ ! -n "${rec_file_list}" ]; then
  Log " "
  Log "ERROR: Recording group ${arch_grp_name} seems to be empty !"
  Log "  This might be because You wrongly labeled archive HDD or there is"
  Log "  problem with accessing mythtv recordings table."
  Log "  For fixing this pls:"
  Log "    -make sure You have any recordings in Archive group"
  Log "    -make sure archive HDD is propelry labeled"
  Log "    -check is this script able to access mythtv recordings table at SQL level"
  Log " "
  Log "For safety reasons script will now exit."
  Die
fi

#cd ${rec_path}
for dir in ${recordings} ; do

  Log "List of new recordings in \"${dir}\" to archive:"
  cd ${dir}
  du -c -h ${rec_file_list} 2>/dev/null

  Debug "--List files to process: Begin--"
  Debug "${rec_file_list}"
  Debug "--List files to process: End--"

done




#------------------------------------------------------------------------------
if [ "$action" = "connected" ]; then

  mounted=`mount -v | grep -c ${arch_path}`
  if [ $mounted = 0 ]; then
    Log ""
    Log "Disk at ${arch_path} not mounted !"
    Log ""
    Log "Exiting..."
    Log ""
    Die
  fi

  Log "Removing (Offline) prefix in archived recordings titles..."
  rc=$(Sql -Bse "UPDATE recorded SET title=REPLACE(title, '(Offline) ','')  WHERE recgroup LIKE '$arch_grp_name';")
  #'
  Log $rc

  /usr/bin/perl /usr/local/bin/osd_notify.pl "${arch_grp_name}" avaliable tvarchive

  Log "Syncing recordings files..."
  new_files=0
  for rec in ${rec_file_list} ; do
    Debug "Processing DB entry:${rec}"
    if [ -e ${arch_path}/${rec} ]; then
      Debug "  ${arch_path} already has this file"
    else
      Debug "  ${arch_path} don't have this file"
      rec_basename=`echo ${rec} | sed -e 's/\..*//'`
      Log "  Finding : ${rec} in \"${recordings}\""
      rec_path=`for dir in ${recordings} ; do  find ${dir} -name ${rec} | sed -e "s/\/${rec}//";  done`
      if [ ! -z ${rec_path} ]; then
        Log "  Found!"
        Log "      File    : ${rec}"
        Log "      Basename: ${rec_basename}"
        Log "      Path    : ${rec_path}"
        Log "    Copying previews to archive..."
        /usr/bin/ionice -c 3 /bin/cp -vf ${rec_path}/${rec_basename}*png ${arch_path}/ 2>&1 > /dev/null
        Log "    Moving main file to archive..."
        /usr/bin/ionice -c 3 /bin/mv -vf ${rec_path}/${rec} ${arch_path}/ > /dev/null
        Log "    Generating pretty filanames..."
        /usr/local/bin/mythlink.pl --filename ${arch_path}/${rec} --dest ${arch_path}/
        Log "    Changing StorageGroup..."
        rc=$(Sql -Bse "UPDATE recorded SET storagegroup='$arch_grp_name' WHERE basename='$rec';")
        #'
        Log $rc
        new_files=1
      fi
    fi
  done

  Log "Validating all files in archive dir..."

  if [ ! -e ${arch_path}/.to-delete ]; then
    Debug "${arch_path}/.to-delete not exist!. Creating..."
    mkdir -p -m777 ${arch_path}/.to-delete
  fi
  arch_file_list=`/bin/ls -1 ${arch_path}/*.{mpg,mkv,ts} | sed -e "s|${arch_path}/||g"`

  for file in ${arch_file_list} ; do
    Debug "  Validating file:${file}"
    file_ok=`echo ${rec_file_list} | grep -c "${file}"`

    if [ $file_ok = 0 ] ; then
      file_basename=`echo ${file} | sed -e 's/\..*//'`
      Debug "  Recording with ${file_basename} was deleted by user. Deleting relevant files from archive..."
      mv ${arch_path}/${file_basename}* ${arch_path}/.to-delete/ 2> /dev/null
      new_files=1
    else
      Debug "  Archived file ${file} has coresponding DB rec. Keeping it !"
    fi
  done

  free_space=`df -h | grep "Archiwum" | sed -e 's/[a-z0-9/]*\s*\([0-9.]*[GMT]\)\s*\([0-9.]*[GMT]\)\s*\([0-9.]*[GMT]\)\s*\([0-9%]*\).*/\1 | Zajete: \2(\4) | Wolne: \3/'`
  Log "Done! Disk stats are: ${free_space}"

  if [ $new_files = 1 ]; then
    Log "Notyfying via OSD user about new files added/removed..."
    /usr/bin/perl /usr/local/bin/osd_notify.pl "${free_space}" synchronized tvarchive
  fi

  Log "Creating ${group}.connected semphore at /var/lib/run-tv-archive dir ..."
  mkdir -p /var/lib/run-tv-archive/
  touch /var/lib/run-tv-archive/${group}.connected

  Log "Exiting with sucess!"
  exit 0

fi
#------------------------------------------------------------------------------




#------------------------------------------------------------------------------
if [ "$action" = "disconnected" ]; then

  mounted=`mount -v | grep -c ${arch_path}`
  if [ $mounted = 0 ]; then
    Log ""
    Log "Disk at ${arch_path} not mounted !"
    Log ""
    Log "Exiting..."
    Log ""
    Die
  fi

  Log "Updating previews to current ones..."
  mkdir -p ${prev_tmp}/.tmp
  for rec in ${rec_file_list} ; do
    Debug "Processing file:${rec}"
    rec_basename=`echo ${rec} | sed -e 's/\..*//'`
    /usr/bin/ionice -c 3 /bin/cp -vf ${arch_path}/${rec}*png ${prev_tmp}/.tmp/ 2>&1 > /dev/null
  done

  Log "Unmounting \"${arch_path}\""
  rc=`umount ${arch_path}`
  sleep 1
  mounted=`mount -v | grep -c ${arch_path}`
  if [ $mounted != 0 ]; then
    /usr/bin/perl /usr/local/bin/osd_notify.pl "Nie moge odmontowac dysku. System zwraca: \"$rc\""
    Log "Can't unmount \"${arch_path}\"!. Error is:\"${rc}\" Exiting..."
    exit 1
  fi

  if [ ! -e ${arch_path} ]; then
    Log "${arch_path} for previews not exist !. Creating..."
    mkdir -p -m777 ${arch_path}
    Log ""
  fi
  if [ ! -e ${arch_path}/.to-delete ]; then
    mkdir -p -m777 ${arch_path}/.to-delete
  fi

  Log "Adding (Offline) prefix in recordings titles..."
  rc=$(Sql -Bse "UPDATE recorded SET title = CONCAT('(Offline) ', title) WHERE recgroup LIKE '$arch_grp_name';")
  #'
  Log $rc

  Log "Syncing banners..."
  for rec in ${rec_file_list} ; do
    Debug "Processing DB entry:${rec}"
    if [ -e ${arch_path}/${rec} ]; then
      Debug "  This DB entry has info-banner file..."
    else
      Debug "  This DB entry has NOT info-banner file. Creating it..."
      /bin/cp ${arch_path}/../infobanner.mpeg ${arch_path}/${rec} 2>&1 > /dev/null
    fi
  done

  Log "Updating previews..."
  /usr/bin/ionice -c 3 /bin/mv -u ${prev_tmp}/.tmp/*png ${arch_path}/ 2>&1 > /dev/null
  rm -rf ${prev_tmp}/.tmp/ 2> /dev/null

  Log "Validating all files in archive..."
  arch_file_list=`/bin/ls -1 ${arch_path}/*.{mpg,mkv,ts} | sed -e "s|${arch_path}/||g"`
  for file in ${arch_file_list} ; do
    Debug "Validating file:${file}"
    file_ok=`echo ${rec_file_list} | grep -c "${file}"`
    if [ $file_ok = 0 ] ; then
      Debug "  Recording with ${file} was deleted by user. Deleting relevant files from archive..."
      file_basename=`echo ${file} | sed -e 's/\..*//'`
      mv ${arch_path}/${file_basename}* ${arch_path}/.to-delete/ 2>&1 > /dev/null
    else
      Debug "  Archived file ${file} has coresponding DB rec. Keeping it !"
    fi
  done

  /usr/bin/perl /usr/local/bin/osd_notify.pl "${arch_grp_name}" offline tvarchive

  Log "Deleting ${group}.connected semphore from /var/lib/run-tv-archive dir ..."
  rm -f /var/lib/run-tv-archive/${group}.connected

  Log "All done! Exiting with sucess..."
  exit 0

fi
#------------------------------------------------------------------------------

Log "Error: unrecognozed command! Exiting with erorr..."
exit 1

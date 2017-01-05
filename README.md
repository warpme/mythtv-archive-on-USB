# MythTV-archive-on-USB
Script to archive MythTV recordings to external USB. Archived recordings have dedicated recording group
with titles prepended (Offline) when USB drive is disconected. User can archive recordings by simply moving 
in MythTV UI desired recording to this archive recording group.
After connecting USB drive, recordings are synced in backgrund with this dedicated archive
group and all recordings have removed "(Offline)" prefix. Disconnecting USB drive adds "(Offline") prefix to 
titles and also makes recording file substituted with dummy rec.file having user info.

Usage:

How to archive given recording
==============================

 1.  Move desired recordings to archive group.

 2.  Connect USB HDD and wait until all recordings will transfered.

 3.  Unmount archive (run 'unmount_tv_archive.sh' script) and wait
     until all previews will transfered.

 4.  Disconnect USB HDD. Now all recordings in archive group
     have (Ofline) prefix in title.

 5.  You are done.

 How to watch archived recordings

 1.  Connect USB HDD

 2.  Wait until OSD dialog says "Recordings are avaliable. Now all
     archived recordings are wihout (Ofline) prefix and are ready to
     watch.

 3.  Watch desired recordings.

 4.  When You are done and want to disconnect USB HDD, unmount 
     archive by runing 'unmount_tv_archive.sh' script.

 5.  Wait untill OSD dialog says "You can disconnect USB drive"

 6.  Disconnect USB HDD. Now all recordings in archive group 
     are unavaliable and will have (Ofline) prefix in title.

 7.  You are done.





How to make new archive group
=============================

 1.  Add new recrding group in MythTV. Best to do so is: enter
     EPG; select program to record; choose recoordings options;
     in recording group field select "create new group"; put new
     name in dialog (like "5 Archiwum"); save this schedule. Group
     apears when programed recordings will be recorded.

 2.  Prepare USB HDD, format it.

 3.  Make this HDD labeled "5_Archiwum" (remember: all spaces in
     group name should be replaced by underscore.

 4.  Run tv-archive.sh scrpt with group name & command "add"
     i.e. 'run-tarchive.sh "5 Archiwum" add'

 5.  Move desired recordings to archive group.

 6.  Connect USB HDD and wait until all recordings will transfered.

 7.  Unmount archive (run 'unmount_tv_archive.sh' script) and wait
     until all previews will transfered.

 8.  You are done.





How to make given group an archived group (called i.e. "5 Archiwum")
====================================================================

 1.  Prepare USB HDD, format it.

 2.  Make this HDD labeled "5_Archiwum" (remember: all spaces in
     group name should be replaced by underscore.

 3.  Run tv-archive.sh scrpt with group name & command "add"
     i.e. 'run-tarchive.sh "5 Archiwum" add'

 4.  Connect USB HDD and wait until all recordings will transfered.

 5.  Unmount archive (run 'unmount_tv_archive.sh' script) and wait
     until all previews will transfered.

 6.  You are done.


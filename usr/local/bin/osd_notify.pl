#!/usr/bin/perl -w
#
# osd_notify.pl <vol_name> <action> <type>
#

use Shell;
use strict;
use warnings;
use IO::Socket;
use feature 'switch';


######################################################################
#########   User Defined Variables                           #########
######################################################################

# pattern used to filter IP addresess: all IP hving this string will
# be uses to sent notifications
my $ip_wildcard = "192.168.1.1";
my $debug       = 0;
my $osd_timeout = 10;


######################################################################
#########   End User Defined Variables--Modify nothing below #########
######################################################################

my $type   = "null";
my $action = "null";
my $param  = "null";

if ($ARGV[2]) {$type = $ARGV[2]};
if ($ARGV[1]) {$action = $ARGV[1]};
if ($ARGV[0]) {
  $param = $ARGV[0];
  }
else {
  print "Missing argument ! Exiting...\n\n";
  exit 1
  }

sub get_active_ip_list {
    my $cmd = "arp -n | grep -v \"incomplete\" | grep \"".$ip_wildcard."\" | cut -d \" \" -f1 |";
    my $ip_list = "";
    print ("Active IP cmd:".$cmd."\n") if ($debug);

    my $rc = open(SHELL, $cmd);
    while (<SHELL>) {
        $_ =~ s/Address//;
        $_ =~ s/\n//;
        $ip_list = $ip_list.$_." ";
    }
    close(SHELL);

    print ("Active IP list:".$ip_list."\n") if ($debug);

    return $ip_list
}


sub send_osd_notify_to_all_hosts {
    my ($title,$origin,$description,$extra,$image,$progress_text,$progress,$timeout,$style,$fe_ip_list) = @_;
    my @dest_list = ();
    my $msg = "";
    @dest_list = split(/ /, $fe_ip_list);
    print ("OSD_notify:\n  title=\"$title\"\n  origin=\"$origin\"\n  description=\"$description\"\n  extra=\"$extra\"\n  image=\"$image\"\n  progress_txt=\"$progress_text\"\n  progress=$progress\n  style=\"$style\"\n") if ($debug);

    for (@dest_list) {
        print ("OSD_notify: notify OSD at IP=$_ \n") if ($debug);
        $msg ="<mythnotification version=\"1\">
            <image>$image</image>
            <text>$title</text>
            <origin>$origin</origin>
            <description>$description</description>
            <extra>$extra</extra>
            <progress_text>$progress_text</progress_text>
            <progress>$progress</progress>
            <timeout>$timeout</timeout>";
        if ($style) { $msg = $msg."
            <style>$style</style>" } $msg = $msg."
        </mythnotification>";

        print ("Send data=\"$msg\"\n") if ($debug);
        my $mythnotify_fh = IO::Socket::INET->new(PeerAddr=>$_,Proto=>'udp',PeerPort=>6948);
        if ($mythnotify_fh) {
            print $mythnotify_fh $msg;
            $mythnotify_fh->close;
            print ("Notify via OSD to IP=$_ done\n") if ($debug);
        }
    }
}

my $notify_ip = get_active_ip_list();

print "IP notified : ".$notify_ip."\n";
print "OSD_notify  : param=".$param."\n";
print "OSD_notify  : action=".$action."\n";
print "OSD_notify  : type=".$type."\n";

    if (($action eq "connected") & ($type eq "movies")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Dołączono dysk USB z archiwum filmów",
            $param,
            "Rozpoczynam synchronizację...",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    if (($action eq "avaliable") & ($type eq "movies")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Dysk USB z archiwum filmów",
            $param,
            "Zawartość dysku jest juz dostępna!",
            "images/mythnotify/check.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "disconnected") & ($type eq "movies")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Odołączono dysk USB",
            $param,
            "Jego zawartość nie będzie dostępna...",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "connected") & ($type eq "backup")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Dołączono archiwizacyjny dysk USB",
            "",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "finished") & ($type eq "backup")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Zakończono archiwizację na dysk USB",
            $param,
            "images/mythnotify/check.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "disconnected") & ($type eq "backup")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Zakończono archiwizację na dysk USB",
            $param,
            "images/mythnotify/check.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "connected") & ($type eq "tvarchive")) {
        my $name = $param;
        $name =~ s/_/ /g;
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Dołączono dysk USB z archiwum TV",
            $name,
            "Rozpoczynam synchronizację...",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "avaliable") & ($type eq "tvarchive")) {
        my $name = $param;
        $name =~ s/_/ /g;
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Dysk USB z archiwum TV",
            $name,
            "Zawartość dysku jest już dostępna...",
            "images/mythnotify/check.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "synchronized") & ($type eq "tvarchive")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Dysk USB z archiwum TV",
            "Statystyka: ".$param,
            "Został pomślnie zsynchronizowany...",
            "images/mythnotify/check.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "prepare-to-unmount") & ($type eq "tvarchive")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Przygowowuję dysk USB do odłączenia...",
            "",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "offline") & ($type eq "tvarchive")) {
        my $name = $param;
        $name =~ s/_/ /g;
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Dysk USB z archiwum TV",
            $name,
            "Teraz możesz bezpiecznie odłączyc dysk!",
            "images/mythnotify/check.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "disconnected") & ($type eq "tvarchive")) {
        my $name = $param;
        $name =~ s/_/ /g;
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "Odłączono dysk USB z archiwum TV",
            $name,
            "Niedostępne nagr. będą oznaczone (OFFLINE)",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "no-disk-detected") & ($type eq "tvarchive")) {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Nie znaleziono żadnego dysku USB!",
            "",
            "images/mythnotify/error.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "connected") & ($type eq "general_storage")) {
        my $name = $param;
        $name =~ s/_/ /g;
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Dołączono dysk USB",
            "Nazwa: ".$name,
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    elsif (($action eq "disconnected") & ($type eq "general_storage")) {
        my $name = $param;
        $name =~ s/_/ /g;
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            "Odołączono dysk USB",
            "Nazwa: ".$name,
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
        exit;
    }

    else {
        &send_osd_notify_to_all_hosts(
            "KOMUNIKAT SYSTEMOWY...",
            "",
            $param,
            "",
            "images/mythnotify/warning.png",
            "",
            "",
            $osd_timeout,
            "",
            $notify_ip,
        );
    }

1

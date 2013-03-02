#!/usr/bin/perl
# quick script to grab newest video file from phone;
use strict;
use warnings;
use diagnostics;       # useful for debugging;
use feature 'say';     # beats print;
use Getopt::Long;      # for parsing command-line options;
use WWW::Mechanize;    # for reading web pages programmatically;
use Storable;          # for saving files found by WWW::Mechanize;
use Adb;               # for OO-style interaction with Android SDK's adb;
$|++;                  # disable readline buffering for real-time output;

my $usage = <<'END';
update-phone

Grabs the newest CyanogenMod nightly and flashes phone with it. 
Defaults to 'maguro' device type (Galaxy Nexus), and the most 
recent nightly.

Usage: 
     --option 1        
     --option 2    
     --help        # show this usage information

Supported options:


    -b, --build         # 
    -d, --device         # specify device for cyanogen mod
    -f, --filename         # specify name for downloaded file (optional)
    -h, --help         # show this usage information
    -v, --verbose        # enable chatty output

END

GetOptions(
    'device|d'       => \my $device,
    'filename|f'     => \my $filename,
    'build|b'        => \my $build,
    'type|t'         => \my $type,
    'help|h|?|usage' => \my $help,
    'verbose|v'      => \my $verbose,
) or die "$usage";

if ( $help ) {    # if user requested usage information;
    say $usage;    # display usage information;
    exit 0;        # exit cleanly;
}

$device = 'maguro'  unless $device;
$type   = 'nightly' unless $type;
$verbose = 1;      # debugging;

my $adb = Adb->new;
$adb->start;
$adb->devices;
#$adb->reboot( 'recovery' );

my $nightly = download();
$adb->sideload( $nightly ) or die "Sideloading failed.";
$adb->stop;
exit;

sub download {     # go grab that file;

    my $start = "http://download.cyanogenmod.com/?device=$device&type=$type";

    my $mech = WWW::Mechanize->new( autocheck => 1 );
    print "Looking up latest CyanogenMod nightly for $device platform... " if $verbose;    # chatty output;
    $mech->get( $start );                                                                  #
    say "done." if $verbose;                                                               # chatty output;

    $mech->content =~ m/md5sum: (\w{32})/g;                                                # find MD5 for checking;
    my $md5sum = $1;                                                                       # store matched MD5 sum;

    my $zip = ( $mech->find_all_links( url_regex => qr/\d{8}\-\w+\-$device\.zip$/ ) )[ 0 ];    # first link on page is most recent;
    my $url = $zip->url_abs;                                                                   # retrieve full URL from object;

    say "Fetching image at $url" if $verbose;                                                  # chatty output;

    $filename = ( split( /\//, $url ) )[ -1 ]    # grab name of zipped image file by splitting on URL's /s;
      unless $filename;                          # don't clobber a user-specified filename;

    return 1 if -e $filename and system( 'checkmd5', $md5sum, $filename ) == 0;    # check for pre-existing valid file;

    # continue with download if file isn't already present;
    unlink $filename if -e $filename;                                              # clobber any previous version;

    $mech->get( $url );                                                            # go grab that url;
    $mech->save_content( $filename );                                              # download that file;

    say "Verifying file integrity (md5sum: $md5sum)..." if $verbose;               # chatty output;
    system( 'checkmd5', $md5sum, $filename ) == 0 or return;                          # make sure the file is what it should be before we flash;
    return $filename; # pass back filename to caller;
}


#!/usr/bin/perl
# quick script to grab newest video file from phone;
use strict;
use warnings;
use diagnostics;       # useful for debugging;
use feature 'say';     # beats print;
use Getopt::Long;      # for parsing command-line options;
use WWW::Mechanize;    # for reading web pages programmatically;
use Storable;          # for saving files found by WWW::Mechanize;

my $usage = <<'END';
ScriptName

. 

Usage: 
     --option 1        
     --option 2    
     --help        # show this usage information

Supported options:


    -b, --build         # 
    -d, --device         # specify device for cyanogen mod
    -h, --help         # show this usage information
    -v, --verbose        # enable chatty output

END

GetOptions(
    'device|d'       => \my $device,
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

my $start = "http://download.cyanogenmod.com/?device=$device&type=$type";
say "Starting URL is: $start";

my $mech = WWW::Mechanize->new( autocheck => 1 );
$mech->get( $start );

my $zip = ( $mech->find_all_links( url_regex => qr/\d{8}\-\w+\-$device\.zip$/ ) )[0]; # first link on page is most recent;

my $url = $zip->url_abs;    # retrieve full URL from object;
say "Fetching image at $url" if $verbose;    # chatty output;
$mech->get( $url );                          # go grab that url;
$mech->save_content( 'cyanogenmod-image.zip' ) or die "Could not save image to disk $!";


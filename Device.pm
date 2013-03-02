package Device;
use strict;
use warnings;
use feature 'say';
use Moose;

extends 'Adb';
my $verbose;

has 'mac',       is => 'ro', isa => 'Str',  required => 1;
has 'mode',      is => 'rw', isa => 'Str',  required => 1;
has 'verbose',   is => 'rw', isa => 'Bool', required => 1, default => 1;
has 'connected', is => 'rw', isa => 'Bool', required => 1, default => 1;
has 'adb',       is => 'ro', isa => 'Item', default  => \&start_adb;

sub BUILD {    # initialize object before returning;
    my $self = shift;

    $self->start if $self->autostart;
    $verbose = $self->verbose;

}

sub start_adb { # fire up adb server, providing interface to interact with device;
    my $self = shift;           # unpack class object from caller;

    my $adb = Adb->new;

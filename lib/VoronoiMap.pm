#!/usr/bin/perl -wT
###############################################################################

package VoronoiMap;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( generateRandomPoints );

###############################################################################

=head1 NAME

    VoronoiMap - used to generate maps

=head1 SYNOPSIS

    use VoronoiMap;

=cut

###############################################################################

use Carp;
use CGI;
use ContinentGenerator;
use Data::Dumper;
use Exporter;
use Math::Complex ':pi'; 
use Math::Round;
use NPCGenerator;
use RegionGenerator;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use GovtGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

sub generateRandomPoints {
    my ($map)=@_;

    set_seed(  $map->{'seed'}  + length ((caller(0))[3])  );
    $map->{'points'}=[];
    
    for (my $i=0; $i<$map->{'count'}; $i++) {
        my $x = round((rand()*($map->{'width'}  - $map->{'margin'}*2) )*10)/10 + $map->{'margin'};
        my $y = round((rand()*($map->{'height'} - $map->{'margin'}*2) )*10)/10 + $map->{'margin'};
        push @{$map->{'points'}}, { 'x'=>$x, 'y'=>$y   };
    }
    return $map;

}




1;

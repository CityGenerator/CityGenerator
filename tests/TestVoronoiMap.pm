#!/usr/bin/perl -wT
###############################################################################
#
package TestVoronoiMap;

use strict;
use warnings;
use Test::More;
use VoronoiMap;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test generateRandomPoints' => sub {
    my $map = VoronoiMap::generateRandomPoints({'seed'=>1,'count'=>"30", 'width'=>'200', 'height'=>'200', 'margin'=>'0'});
    is(scalar @{$map->{'points'}},30);
    done_testing();
};


1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestEventFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use EventFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test printSummary' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $event = EventFormatter::printSummary($city);
    isnt( $event, undef, "make sure something is returned." );
    done_testing();
};

subtest 'Test printPostings' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $event = EventFormatter::printPostings($city);
    isnt( $event, undef, "make sure something is returned." );
    done_testing();
};



1;

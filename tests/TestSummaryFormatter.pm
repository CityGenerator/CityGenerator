#!/usr/bin/perl -wT
###############################################################################
#
package TestSummaryFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use SummaryFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Summary' => sub {
    my $city = CityGenerator::create_city( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $summary = SummaryFormatter::printSummary($city);
    is( $summary, "Grisnow is a settlement in the Conacania Province with a normal population of around 60.",
        "summary text" );

    done_testing();
};

1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestSummaryFormatter;

use strict;
use warnings;
use Test::More;
use SummaryFormatter;
use CityGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Summary' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $summary=SummaryFormatter::printSummary($city);
    is($summary, "Grisnow is a settlement in the Conacania Province with a normal population of around 52." );

    done_testing();
};

1;

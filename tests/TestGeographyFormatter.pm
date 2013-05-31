#!/usr/bin/perl -wT
###############################################################################
#
package TestGeographyFormatter;

use strict;
use warnings;
use Test::More;
use GeographyFormatter;
use CityGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Geography' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $geography=GeographyFormatter::printGeography($city);
    is($geography, "This desolate settlement is sparsely populated (27/sq km) and covers 1.93 square kilometers." );

    done_testing();
};

1;

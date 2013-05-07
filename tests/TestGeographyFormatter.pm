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
    is($geography, "This modest settlement is sparsely populated, covering 2.13 hectares and supported by a 0.25 square mile region." );

    done_testing();
};

1;

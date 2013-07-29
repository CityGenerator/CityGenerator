#!/usr/bin/perl -wT
###############################################################################
#
package TestEnvironmentFormatter;

use strict;
use warnings;
use Test::More;
use EnvironmentFormatter;
use CityGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Environment Geography' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $environment=EnvironmentFormatter::printGeography($city);
    is($environment, "This desolate settlement is sparsely populated (27/sq km) and covers 1.93 square kilometers." );

    done_testing();
};
subtest 'Test Environment Climate' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $environment=EnvironmentFormatter::printClimate($city);
    is($environment, 

                    "Grisnow has a Temperate Deciduous Forest climate, which is characterized by warm and wet summers with mild and dry winters, and has spring, summer, fall and winter seasons. ".
                    "Winds in the region are non-existent and the temperature is generally chilly with high variation. ".
                    "Precipitation is moderate, and the sky is mostly cloudy. "

                );
    done_testing();
};

1;

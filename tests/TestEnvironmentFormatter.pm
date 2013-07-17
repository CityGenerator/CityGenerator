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
    is($environment, "

This desolate settlement is sparsely populated (27/sq km) and covers 1.93 square kilometers.

The climate in _______ is generally pleasant. When you arrive after nightfall, the wind is heavy and the cloud cover is dark. It is currently sleeting.
          'climate' => {
                         'storm_chance' => 64,
                         'bar_mod' => {
                                        'time' => '10'
                                      },
                         'time_pop_mod' => '0.75',
                         'precip_chance' => 64,
                         'wind_pop_mod' => '0.95',
                         'seed' => 851428,
                         'time_bar_mod' => '10',
                         'original_seed' => 851428,
                         'precip_description' => 'sleeting',
                         'air_description' => 'thick',
                         'time_exact' => '11:35',
                         'temp_pop_mod' => '1.0',
                         'pop_mod' => {
                                        'wind' => '0.95',
                                        'temp' => '1.0',
                                        'time' => '0.75',
                                        'air' => '1.0'
                                      },
                         'air_pop_mod' => '1.0',
                         'forecast_description' => 'overcast'
                       },



" );

    done_testing();
};

1;

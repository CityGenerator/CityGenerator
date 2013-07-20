#!/usr/bin/perl -wT
###############################################################################
#
package TestCityscapeFormatter;

use strict;
use warnings;
use Test::More;
use CityscapeFormatter;
use CityGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );

subtest 'Test Cityscape walls' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printWalls($city);
    is($cityscape, "Visitors are greeted with a massive wood rampart that is 24 feet tall. The city wall protects the core 80% of the city, with 5 towers spread along the 5.45 kilometer wall.");

    $city=CityGenerator::create_city({seed=>1, 'wall_chance_roll'=>1, 'wall_size_roll'=>22});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printWalls($city);
    is($cityscape, "Visitors are greeted with a wood fence that is 6 feet tall. The city wall protects the core 77% of the city, with 5 towers spread along the 6.01 kilometer wall." );

    $city=CityGenerator::create_city({seed=>1, 'wall_chance_roll'=>100, 'wall_size_roll'=>22});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printWalls($city);
    is($cityscape, "No walls currently surround the city." );

    done_testing();
};

subtest 'Test Cityscape streets' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printStreets($city);
    is($cityscape, "The city is lined with rough dirt tracks in a grid pattern." );

    done_testing();
};

subtest 'Test Cityscape districts' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printDistrictList($city);
    is($cityscape, "The city is broken into the following Districts: market and trade." );

    done_testing();
};

subtest 'Test Cityscape housing' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printHousingList($city);
    is($cityscape, "Among housing, there are 0 wealthy residences, 4 average homes and 2 dilapidated homes." );

    done_testing();
};


subtest 'Test Cityscape' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printCityscape($city);
    is($cityscape, "<p>There is 1 road leading to Grisnow; none are major. Visitors are greeted with a massive wood rampart that is 24 feet tall. The city wall protects the core 80% of the city, with 5 towers spread along the 5.45 kilometer wall. The city is lined with rough dirt tracks in a grid pattern. The city is broken into the following Districts: market and trade. Among housing, there are 0 wealthy residences, 4 average homes and 2 dilapidated homes.</p>" );

    done_testing();
};


subtest 'Test Cityscape roads' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printRoads($city);
    is($cityscape, "There is 1 road leading to Grisnow; none are major." );


    $city=CityGenerator::create_city({seed=>1,'streets'=>{'mainroads'=>0,'roads'=>2}});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printRoads($city);
    is($cityscape, "There are 2 roads leading to Grisnow; none are major." );


    $city=CityGenerator::create_city({seed=>1,'streets'=>{'mainroads'=>1,'roads'=>2}});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printRoads($city);
    is($cityscape, "There are 2 roads leading to Grisnow; 1 is major." );

    $city=CityGenerator::create_city({seed=>1,'streets'=>{'mainroads'=>5,'roads'=>5}});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printRoads($city);
    is($cityscape, "There are 5 roads leading to Grisnow; 5 are major." );


    done_testing();
};

1;

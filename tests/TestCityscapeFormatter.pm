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
    is($cityscape, "No walls currently surround the city." );


    $city=CityGenerator::create_city({seed=>1, 'wall_chance_roll'=>1, 'wall_size_roll'=>22});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printWalls($city);
    is($cityscape, "Visitors are greeted with a thick oak rampart that is 4 feet tall. The city wall protects the core 75% of the city, with 5 towers spread along the 5.52 kilometer wall." );



    done_testing();
};


subtest 'Test Cityscape' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $cityscape=CityscapeFormatter::printCityscape($city);
    is($cityscape, "There is 1 road leading to Grisnow; none are major." );


    $city=CityGenerator::create_city({seed=>1,'streets'=>{'content'=>'foo','mainroads'=>0,'roads'=>2}});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printCityscape($city);
    is($cityscape, "There are 2 roads leading to Grisnow; none are major." );


    $city=CityGenerator::create_city({seed=>1,'streets'=>{'content'=>'foo','mainroads'=>1,'roads'=>2}});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printCityscape($city);
    is($cityscape, "There are 2 roads leading to Grisnow; 1 is major." );

    $city=CityGenerator::create_city({seed=>1,'streets'=>{'content'=>'foo','mainroads'=>5,'roads'=>5}});
    CityGenerator::flesh_out_city($city);
    $cityscape=CityscapeFormatter::printCityscape($city);
    is($cityscape, "There are 5 roads leading to Grisnow; 5 are major." );


    done_testing();
};

1;

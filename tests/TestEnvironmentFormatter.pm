#!/usr/bin/perl -wT
###############################################################################
#
package TestEnvironmentFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use EnvironmentFormatter;
use Exporter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Environment Geography' => sub {
    my $city = CityGenerator::create( { 'seed' => 1, 'area'=>"3.00" } );
    CityGenerator::flesh_out_city($city);
    my $environment = EnvironmentFormatter::printGeography($city);
    like(
        $environment,
        "/This .+ .+ is .+ populated [(].+/sq km[)], covers .+ square kilometers, and roughly has a diameter of .+ meters\. \n/",
        'ensure string is returned'
    );

    done_testing();
};

subtest 'Test Environment Climate' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $environment = EnvironmentFormatter::printClimate($city);
    like($environment, "/climate, which is characterized/", 'ensure a proper string is returned');
    done_testing();
};

subtest 'Test printAstronomy' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $environment = EnvironmentFormatter::printAstronomy($city);
    like($environment, "/In the night sky, you see /", 'ensure a proper string is returned');
    done_testing();
};

subtest 'Test printMoonList' => sub {
    my $city = CityGenerator::create( { seed => 1, 'astronomy'=>{'moons_count'=>0, 'moons_name'=>'no moons'} } );
    CityGenerator::flesh_out_city($city);
    my $environment = EnvironmentFormatter::printMoonList($city);
    is($environment, "no moons", 'ensure no moons are returned');
    done_testing();
};

subtest 'Test printCelestialList' => sub {
    my $city = CityGenerator::create( { seed => 1, 'astronomy'=>{'celestial_count'=>0, 'celestial_name'=>'nothing unusual'} } );
    CityGenerator::flesh_out_city($city);
    my $environment = EnvironmentFormatter::printCelestialList($city);
    is($environment, "nothing unusual", 'ensure no objects are returned');

    $city = CityGenerator::create( { seed => 1, 'astronomy'=>{'celestial_count'=>1, 'celestial_name'=>'one'} } );
    CityGenerator::flesh_out_city($city);
    $environment = EnvironmentFormatter::printCelestialList($city);
    like($environment, "/one: /", 'ensure one is returned');
    done_testing();
};


1;


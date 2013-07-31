#!/usr/bin/perl -wT
###############################################################################
#
package TestWorldGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use WorldGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_world' => sub {
    my $world;
    $world = WorldGenerator::create_world();
    isnt( $world->{'name'}, undef );

    $world = WorldGenerator::create_world( { 'seed' => 12345 } );
    is( $world->{'seed'}, 12345 );
    is( $world->{'name'}, 'Jupon' );

    $world = WorldGenerator::create_world( { 'seed' => 12345, 'name' => 'test' } );
    is( $world->{'seed'}, 12345 );
    is( $world->{'name'}, 'test' );

    done_testing();
};

subtest 'test generate_atmosphere' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373, 'atmosphere' => { 'reason_roll' => 1 } } );
    is( $world->{'atmosphere'}->{'color'},  "blue" );
    is( $world->{'atmosphere'}->{'reason'}, "water vapor" );
    $world = WorldGenerator::create_world( { 'seed' => 765373, 'atmosphere' => { 'reason_roll' => 90 } } );
    is( $world->{'atmosphere'}->{'color'},  "blue" );
    is( $world->{'atmosphere'}->{'reason'}, undef );

    done_testing();
};

subtest 'test generate_basetemp' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'basetemp'},          "mild" );
    is( $world->{'basetemp_modifier'}, "1.10" );


    done_testing();
};

subtest 'test generate_air' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'air'}, "dense" );

    done_testing();
};

subtest 'test generate_wind' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'wind'}, "incredibly strong" );

    done_testing();
};


subtest 'test generate_year' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'year_roll'}, "100" );
    is( $world->{'year'},      "8" );

    $world = WorldGenerator::create_world( { 'seed' => 765373, 'year_roll' => 1 } );
    is( $world->{'year_roll'}, "1" );
    is( $world->{'year'},      "9" );

    done_testing();
};


subtest 'test generate_day' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'day_roll'}, "13" );
    is( $world->{'day'},      "39" );

    $world = WorldGenerator::create_world( { 'seed' => 765373, 'day_roll' => 1 } );
    is( $world->{'day_roll'}, "1" );
    is( $world->{'day'},      "10" );

    done_testing();
};


subtest 'test generate_plates' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'plates_roll'},     "75" );
    is( $world->{'plates'},          "17" );
    is( $world->{'continent_count'}, "5" );

    $world = WorldGenerator::create_world( { 'seed' => 765373, 'plates_roll' => 1 } );
    is( $world->{'plates_roll'},     "1" );
    is( $world->{'plates'},          "9" );
    is( $world->{'continent_count'}, "3" );

    done_testing();
};


subtest 'test generate_surface' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765373 } );
    is( $world->{'surface_roll'}, "62" );
    is( $world->{'surface'},      "711688464" );
    is( $world->{'size'},         "average" );
    is( $world->{'radius'},       "7525" );
    is( $world->{'circumfrence'}, "47280" );

    $world = WorldGenerator::create_world( { 'seed' => 765373, 'surface_roll' => 1 } );
    is( $world->{'surface_roll'}, "1" );
    is( $world->{'surface'},      "77237844" );
    is( $world->{'size'},         "tiny" );
    is( $world->{'radius'},       "2479" );
    is( $world->{'circumfrence'}, "15576" );

    $world = WorldGenerator::create_world( { 'seed' => 765373, 'surface' => 100000 } );
    is( $world->{'surface_roll'}, "62" );
    is( $world->{'surface'},      "100000" );
    is( $world->{'size'},         "average" );
    is( $world->{'radius'},       "89" );
    is( $world->{'circumfrence'}, "559" );

    done_testing();
};


subtest 'test generate_surfacewater' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765379 } );
    is( $world->{'seed'},                     765379 );
    is( $world->{'surfacewater_percent'},     '20' );
    is( $world->{'surfacewater_description'}, 'rare' );

    $world = WorldGenerator::create_world( { 'seed' => 765379, 'smallstorms_percent' => 1 } );
    is( $world->{'seed'},                    765379 );
    is( $world->{'smallstorms_percent'},     '1' );
    is( $world->{'smallstorms_description'}, 'scarce' );
    done_testing();
};

subtest 'test generate_freshwater' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765379 } );
    is( $world->{'seed'},                   765379 );
    is( $world->{'freshwater_percent'},     '45' );
    is( $world->{'freshwater_description'}, 'common' );
    $world = WorldGenerator::create_world( { 'seed' => 765379, 'freshwater_percent' => 1 } );
    is( $world->{'seed'},                   765379 );
    is( $world->{'freshwater_percent'},     '1' );
    is( $world->{'freshwater_description'}, 'scarce' );

    done_testing();
};

subtest 'test generate_civilization' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765379 } );
    is( $world->{'seed'},                     765379 );
    is( $world->{'civilization_percent'},     '20' );
    is( $world->{'civilization_description'}, 'scattered' );
    is( $world->{'civilization_modifier'},    '-3' );

    $world = WorldGenerator::create_world( { 'seed' => 765379, 'civilization_percent' => 1 } );
    is( $world->{'seed'},                     765379 );
    is( $world->{'civilization_percent'},     '1' );
    is( $world->{'civilization_description'}, 'crude' );
    is( $world->{'civilization_modifier'},    '-5' );

    done_testing();
};

subtest 'test generate_smallstorms' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765379 } );
    is( $world->{'seed'},                    765379 );
    is( $world->{'smallstorms_percent'},     '32' );
    is( $world->{'smallstorms_description'}, 'common' );
    $world = WorldGenerator::create_world( { 'seed' => 765379, 'smallstorms_percent' => 1 } );
    is( $world->{'seed'},                    765379 );
    is( $world->{'smallstorms_percent'},     '1' );
    is( $world->{'smallstorms_description'}, 'scarce' );

    done_testing();
};

subtest 'test generate_precipitation' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765379 } );
    is( $world->{'seed'},                      765379 );
    is( $world->{'precipitation_percent'},     '7' );
    is( $world->{'precipitation_description'}, 'scarce' );
    $world = WorldGenerator::create_world( { 'seed' => 765379, 'precipitation_percent' => 90 } );
    is( $world->{'seed'},                      765379 );
    is( $world->{'precipitation_percent'},     '90' );
    is( $world->{'precipitation_description'}, 'abundant' );

    done_testing();
};

subtest 'test generate_clouds' => sub {
    my $world;
    $world = WorldGenerator::create_world( { 'seed' => 765379 } );
    is( $world->{'seed'},               765379 );
    is( $world->{'clouds_percent'},     '97' );
    is( $world->{'clouds_description'}, 'excessive' );
    $world = WorldGenerator::create_world( { 'seed' => 765379, 'clouds_percent' => 1 } );
    is( $world->{'seed'},               765379 );
    is( $world->{'clouds_percent'},     '1' );
    is( $world->{'clouds_description'}, 'scarce' );

    done_testing();
};


1;


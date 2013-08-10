#!/usr/bin/perl -wT
###############################################################################
#
package TestClimateGenerator;

use strict;
use warnings;
use ClimateGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_climate' => sub {
    my $climate;
    GenericGenerator::set_seed(1);
    $climate = ClimateGenerator::create_climate( );
    is( $climate->{'seed'},       '41630' );

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'altitude' => '-5', 'latitude' => '-5', 'continentality' => '-5', 'pressure' => '105' } );

    is( $climate->{'altitude'},       '1' );
    is( $climate->{'continentality'}, '1' );
    is( $climate->{'latitude'},       '1' );
    is( $climate->{'pressure'},       '100' );

    is( $climate->{'temperature'},   '99' );
    is( $climate->{'precipitation'}, '99.5' );

    is( $climate->{'biomekey'}, 'AF' );
    is( $climate->{'name'},     'Tropical Rainforest' );
    is( $climate->{'description'},
        'constant high temperatures, continual rain year-round, and has minimal natural seasons' );
    is_deeply( $climate->{'seasontypes'}, [1] );
    is( $climate->{'seasontype'},        '1' );
    is( $climate->{'color'},             '#9cbba9' );
    is( $climate->{'seasondescription'}, 'negligible seasons' );

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'altitude' => '50', 'latitude' => '50', 'continentality' => '50', 'pressure' => '50' } );

    is( $climate->{'altitude'},       '50' );
    is( $climate->{'continentality'}, '50' );
    is( $climate->{'latitude'},       '50' );
    is( $climate->{'pressure'},       '50' );

    is( $climate->{'temperature'},   '50' );
    is( $climate->{'precipitation'}, '50' );

    is( $climate->{'biomekey'}, 'CW' );
    is( $climate->{'name'},     'Temperate Deciduous Forest' );
    is_deeply( $climate->{'seasontypes'}, [ 4, 6 ] );
    is( $climate->{'seasontype'},        '4' );
    is( $climate->{'seasondescription'}, 'spring, summer, fall and winter seasons' );

    $climate = ClimateGenerator::create_climate(
        {
            'seed'              => 1,
            'altitude'          => '105',
            'latitude'          => '105',
            'continentality'    => '105',
            'pressure'          => '-5',
            'seasontype'        => '6',
            'seasondescription' => 'boring'
        }
    );

    is( $climate->{'altitude'},       '100' );
    is( $climate->{'continentality'}, '100' );
    is( $climate->{'latitude'},       '100' );
    is( $climate->{'pressure'},       '1' );

    is( $climate->{'temperature'},   '0' );
    is( $climate->{'precipitation'}, '0.5' )
        ;    #FIXME why is this .05?? I suspect this was caused by renumbering from 0-100 to 1-100

    is( $climate->{'biomekey'}, 'EF' );
    is( $climate->{'name'},     'Ice Cap' );
    is_deeply( $climate->{'seasontypes'}, [1] );
    is( $climate->{'seasontype'},        '6' );
    is( $climate->{'seasondescription'}, 'boring' );

    $climate = ClimateGenerator::create_climate(
        {
            'seed'           => 1,
            'altitude'       => '0',
            'latitude'       => '0',
            'continentality' => '100',
            'pressure'       => '0',
            'seasontypes'    => [ 1, 2, 3, 4 ]
        }
    );

    is( $climate->{'altitude'},       '1' );
    is( $climate->{'latitude'},       '1' );
    is( $climate->{'continentality'}, '100' );
    is( $climate->{'pressure'},       '1' );

    is( $climate->{'temperature'},   '99' );
    is( $climate->{'precipitation'}, '0.5' );

    is( $climate->{'biomekey'}, 'BS' );
    is( $climate->{'name'},     'Semi-Arid Steppe' );
    is_deeply( $climate->{'seasontypes'}, [ 1, 2, 3, 4 ] );
    is( $climate->{'seasontype'},        '2' );
    is( $climate->{'seasondescription'}, 'rainy and dry seasons' );

    done_testing();
};

subtest 'test calculate_wind' => sub {
    my $climate;

    $climate
        = ClimateGenerator::create_climate( { 'seed' => 1, 'wind_roll' => '100', 'wind_variation_roll' => '100' } );
    $climate = ClimateGenerator::calculate_wind($climate);

    is( $climate->{'wind_roll'},           '100' );
    is( $climate->{'wind'},                'continual' );
    is( $climate->{'wind_variation_roll'}, '100' );
    is( $climate->{'wind_variation'},      'high' );

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'wind' => 'some', 'wind_variation' => 'awful' } );
    $climate = ClimateGenerator::calculate_wind($climate);

    is( $climate->{'wind'},           'some' );
    is( $climate->{'wind_variation'}, 'awful' );
    done_testing();
};
subtest 'test calculate_temp' => sub {
    my $climate;

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'temperature' => '100', 'temp_variation_roll' => '100' } );
    is( $climate->{'biomekey'}, 'AM');
    is( $climate->{'name'}, 'Tropical Seasonal Forest');
    is( $climate->{'description'}, 'constant high temperatures and seasonal torrential rains');
    is( $climate->{'color'}, '#a9cca4');
    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'temperature' => '100', 'temp_variation_roll' => '100', 'biomekey'=>'CS', 'name'=>'foo', 'description'=>'bar', 'color'=>'derp' } );
    is( $climate->{'biomekey'}, 'CS');
    is( $climate->{'name'}, 'foo');
    is( $climate->{'description'}, 'bar');
    is( $climate->{'color'}, 'derp');


    done_testing();
};

subtest 'test calculate_temp' => sub {
    my $climate;

    $climate
        = ClimateGenerator::create_climate( { 'seed' => 1, 'temperature' => '100', 'temp_variation_roll' => '100' } );
    $climate = ClimateGenerator::calculate_temp($climate);

    is( $climate->{'temperature'},         '100' );
    is( $climate->{'temp'},                'unbearably hot' );
    is( $climate->{'temp_variation_roll'}, '100' );
    is( $climate->{'temp_variation'},      'high' );

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'temp' => 'some', 'temp_variation' => 'awful' } );
    $climate = ClimateGenerator::calculate_temp($climate);

    is( $climate->{'temp'},           'some' );
    is( $climate->{'temp_variation'}, 'awful' );
    done_testing();
};

subtest 'test calculate_precip' => sub {
    my $climate;

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'precipitation' => '100', 'precip_variation_roll' => '100' } );
    $climate = ClimateGenerator::calculate_precip($climate);

    is( $climate->{'precipitation'},         '100' );
    is( $climate->{'precip'},                'continual' );
    is( $climate->{'precip_variation_roll'}, '100' );
    is( $climate->{'precip_variation'},      'high' );

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'precip' => 'some', 'precip_variation' => 'awful' } );
    $climate = ClimateGenerator::calculate_precip($climate);

    is( $climate->{'precip'},           'some' );
    is( $climate->{'precip_variation'}, 'awful' );
    done_testing();
};
subtest 'test calculate_cloudcover' => sub {
    my $climate;

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'cloudcover_roll' => '100', 'cloudcover_variation_roll' => '100' } );
    $climate = ClimateGenerator::calculate_cloudcover($climate);

    is( $climate->{'cloudcover_roll'},           '100' );
    is( $climate->{'cloudcover'},                'clear' );
    is( $climate->{'cloudcover_variation_roll'}, '100' );
    is( $climate->{'cloudcover_variation'},      'high' );

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'cloudcover' => 'some', 'cloudcover_variation' => 'awful' } );
    $climate = ClimateGenerator::calculate_cloudcover($climate);

    is( $climate->{'cloudcover'},           'some' );
    is( $climate->{'cloudcover_variation'}, 'awful' );
    done_testing();
};


1;


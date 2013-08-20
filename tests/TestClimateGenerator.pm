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
        { 'seed' => 1, 'stats'=>{'altitude' => '1', 'latitude' => '1', 'continentality' => '1', 'pressure' => '100'} } );

    is( $climate->{'stats'}->{'altitude'},       '1' );
    is( $climate->{'stats'}->{'continentality'}, '1' );
    is( $climate->{'stats'}->{'latitude'},       '1' );
    is( $climate->{'stats'}->{'pressure'},       '100' );

    is( $climate->{'stats'}->{'temperature'},   '99' );
    is( $climate->{'stats'}->{'precipitation'}, '99.5' );

    is( $climate->{'biomekey'}, 'AF' );
    is( $climate->{'name'},     'Tropical Rainforest' );
    is( $climate->{'description'},
        'constant high temperatures, continual rain year-round, and has minimal natural seasons' );
    is_deeply( $climate->{'seasontypes'}, [1] );
    is( $climate->{'seasontype'},        '1' );
    is( $climate->{'color'},             '#9cbba9' );
    is( $climate->{'seasondescription'}, 'negligible seasons' );

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'stats'=>{'altitude' => '50', 'latitude' => '50', 'continentality' => '50', 'pressure' => '50' }} );

    is( $climate->{'stats'}->{'altitude'},       '50' );
    is( $climate->{'stats'}->{'continentality'}, '50' );
    is( $climate->{'stats'}->{'latitude'},       '50' );
    is( $climate->{'stats'}->{'pressure'},       '50' );

    is( $climate->{'stats'}->{'temperature'},   '50' );
    is( $climate->{'stats'}->{'precipitation'}, '50' );

    is( $climate->{'biomekey'}, 'CW' );
    is( $climate->{'name'},     'Temperate Deciduous Forest' );
    is_deeply( $climate->{'seasontypes'}, [ 4, 6 ] );
    ok( $climate->{'seasontype'} == 4 || $climate->{'seasontype'} == 6, "make sure $climate->{'seasontype'} is 4 or 6." );
    ok( $climate->{'seasondescription'} eq 'spring, summer, fall and winter seasons' ||
        $climate->{'seasondescription'} eq 'prevernal, spring, summer, monsoon, autumn and winter seasons', 
        "Either has 4 or 6 seasons" );

    $climate = ClimateGenerator::create_climate(
        {
            'seed'              => 1,
            'stats'=>{
                'altitude'          => '100',
                'latitude'          => '100',
                'continentality'    => '100',
                'pressure'          => '1',
            },
            'seasontype'        => '6',
            'seasondescription' => 'boring'
        }
    );

    is( $climate->{'stats'}->{'altitude'},       '100' );
    is( $climate->{'stats'}->{'continentality'}, '100' );
    is( $climate->{'stats'}->{'latitude'},       '100' );
    is( $climate->{'stats'}->{'pressure'},       '1' );

    is( $climate->{'stats'}->{'temperature'},   '0' );
    is( $climate->{'stats'}->{'precipitation'}, '0.5' )
        ;    #FIXME why is this .05?? I suspect this was caused by renumbering from 0-100 to 1-100

    is( $climate->{'biomekey'}, 'EF' );
    is( $climate->{'name'},     'Ice Cap' );
    is_deeply( $climate->{'seasontypes'}, [1] );
    is( $climate->{'seasontype'},        '6' );
    is( $climate->{'seasondescription'}, 'boring' );

    $climate = ClimateGenerator::create_climate(
        {
            'seed'           => 1,
            'stats'=>{
                'altitude'       => '1',
                'latitude'       => '1',
                'continentality' => '100',
                'pressure'       => '1',
            },
            'seasontypes'    => [ 1, 2, 3, 4 ]
        }
    );

    is( $climate->{'stats'}->{'altitude'},       '1' );
    is( $climate->{'stats'}->{'latitude'},       '1' );
    is( $climate->{'stats'}->{'continentality'}, '100' );
    is( $climate->{'stats'}->{'pressure'},       '1' );

    is( $climate->{'stats'}->{'temperature'},   '99' );
    is( $climate->{'stats'}->{'precipitation'}, '0.5' );

    is( $climate->{'biomekey'}, 'BS' );
    is( $climate->{'name'},     'Semi-Arid Steppe' );
    is_deeply( $climate->{'seasontypes'}, [ 1, 2, 3, 4 ] );
    isnt( $climate->{'seasontype'},        '6', "can be 1,2,3,4 but not 6." );

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

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'stats'=>{'temperature' => '100', 'precipitation'=>'50'}, 'temp_variation_roll' => '100' } );
    is( $climate->{'biomekey'}, 'AM');
    is( $climate->{'name'}, 'Tropical Seasonal Forest');
    is( $climate->{'description'}, 'constant high temperatures and seasonal torrential rains');
    is( $climate->{'color'}, '#a9cca4');

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'stats'=>{'temperature' => '100'}, 'temp_variation_roll' => '100', 'biomekey'=>'CS', 'name'=>'foo', 'description'=>'bar', 'color'=>'derp' } );
    is( $climate->{'biomekey'}, 'CS');
    is( $climate->{'name'}, 'foo');
    is( $climate->{'description'}, 'bar');
    is( $climate->{'color'}, 'derp');


    done_testing();
};

subtest 'test calculate_temp' => sub {
    my $climate;

    $climate
        = ClimateGenerator::create_climate( { 'seed' => 1, 'stats'=>{'temperature' => '100'}, 'temp_variation_roll' => '100' } );
    $climate = ClimateGenerator::calculate_temp($climate);

    is( $climate->{'stats'}->{'temperature'}, '100' );
    is( $climate->{'temp'},                   'unbearably hot' );
    is( $climate->{'temp_variation_roll'},    '100' );
    is( $climate->{'temp_variation'},         'high' );

    $climate = ClimateGenerator::create_climate( { 'seed' => 1, 'temp' => 'some', 'temp_variation' => 'awful' } );
    $climate = ClimateGenerator::calculate_temp($climate);

    is( $climate->{'temp'},           'some' );
    is( $climate->{'temp_variation'}, 'awful' );
    done_testing();
};

subtest 'test calculate_precip' => sub {
    my $climate;

    $climate = ClimateGenerator::create_climate(
        { 'seed' => 1, 'stats'=>{'precipitation' => '100'}, 'precip_variation_roll' => '100' } );
    $climate = ClimateGenerator::calculate_precip($climate);

    is( $climate->{'stats'}->{'precipitation'}, '100' );
    is( $climate->{'precip'},                   'continual' );
    is( $climate->{'precip_variation_roll'},    '100' );
    is( $climate->{'precip_variation'},         'high' );

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


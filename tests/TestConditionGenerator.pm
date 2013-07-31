#!/usr/bin/perl -wT
###############################################################################
#
package TestConditionGenerator;


use strict;
use warnings;
use ConditionGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_condition' => sub {
    my $condition;
    GenericGenerator::set_seed(1);
    $condition = ConditionGenerator::create_condition();
    is( $condition->{'seed'}, 41630 );
    is_deeply( $condition->{'pop_mod'}, {} );
    is_deeply( $condition->{'bar_mod'}, {} );

    $condition = ConditionGenerator::create_condition(
        { 'seed' => 12345, 'pop_mod' => { 'foo' => 1 }, 'bar_mod' => { 'foo' => 1 } } );
    is( $condition->{'seed'}, 12345 );
    is_deeply( $condition->{'pop_mod'}, { 'foo' => 1 } );
    is_deeply( $condition->{'bar_mod'}, { 'foo' => 1 } );

    $condition = ConditionGenerator::create_condition( { 'seed' => 12345, 'pop_mod' => [], 'bar_mod' => 1 } );
    is( $condition->{'seed'}, 12345 );
    is_deeply( $condition->{'pop_mod'}, {} );
    is_deeply( $condition->{'bar_mod'}, {} );


    done_testing();
};

subtest 'test set_time' => sub {
    my $condition;
    $condition = { 'seed' => 40 };
    ConditionGenerator::set_time($condition);
    is( $condition->{'seed'},             40 );
    is( $condition->{'time_description'}, 'at daybreak' );
    is( $condition->{'time_exact'},       '07:52' );
    is( $condition->{'time_pop_mod'},     "1.0" );
    is( $condition->{'time_bar_mod'},     0 );
    is_deeply( $condition->{'pop_mod'}, { 'time' => '1.0' } );
    is_deeply( $condition->{'bar_mod'}, { 'time' => '0' } );

    $condition = {
        'seed'             => 40,
        'time_description' => 'foo1',
        'time_exact'       => 'foo2',
        'time_pop_mod'     => 'foo3',
        'time_bar_mod'     => 'foo4'
    };
    ConditionGenerator::set_time($condition);
    is( $condition->{'seed'},             40 );
    is( $condition->{'time_description'}, 'foo1' );
    is( $condition->{'time_exact'},       'foo2' );
    is( $condition->{'time_pop_mod'},     'foo3' );
    is( $condition->{'time_bar_mod'},     'foo4' );
    is_deeply( $condition->{'pop_mod'}, { 'time' => 'foo3' } );
    is_deeply( $condition->{'bar_mod'}, { 'time' => 'foo4' } );

    done_testing();
};

subtest 'test set_temp' => sub {
    my $condition;
    $condition = { 'seed' => 40 };
    ConditionGenerator::set_temp($condition);
    is( $condition->{'seed'},             40 );
    is( $condition->{'temp_description'}, 'unbearably cold' );
    is( $condition->{'temp_pop_mod'},     '0.10' );

    $condition = { 'seed' => 40, 'temp_description' => 'foo1', 'temp_pop_mod' => 'foo2' };
    ConditionGenerator::set_temp($condition);
    is( $condition->{'seed'},             40 );
    is( $condition->{'temp_description'}, 'foo1' );
    is( $condition->{'temp_pop_mod'},     'foo2' );

    done_testing();
};

subtest 'test set_air' => sub {
    my $condition;
    $condition = { 'seed' => 40 };
    ConditionGenerator::set_air($condition);
    is( $condition->{'seed'},            40 );
    is( $condition->{'air_description'}, 'fresh' );
    is( $condition->{'air_pop_mod'},     '1.10' );

    $condition = { 'seed' => 40, 'air_description' => 'foo1', 'air_pop_mod' => 'foo2' };
    ConditionGenerator::set_air($condition);
    is( $condition->{'seed'},            40 );
    is( $condition->{'air_description'}, 'foo1' );
    is( $condition->{'air_pop_mod'},     'foo2' );

    done_testing();
};

subtest 'test set_wind' => sub {
    my $condition;
    $condition = { 'seed' => 40 };
    ConditionGenerator::set_wind($condition);
    is( $condition->{'seed'},             40 );
    is( $condition->{'wind_description'}, 'breezy' );
    is( $condition->{'wind_pop_mod'},     '1.0' );

    $condition = { 'seed' => 40, 'wind_description' => 'foo1', 'wind_pop_mod' => 'foo2' };
    ConditionGenerator::set_wind($condition);
    is( $condition->{'seed'},             40 );
    is( $condition->{'wind_description'}, 'foo1' );
    is( $condition->{'wind_pop_mod'},     'foo2' );

    done_testing();
};

subtest 'test set_forecast' => sub {
    my $condition;
    $condition = { 'seed' => 40 };
    ConditionGenerator::set_forecast($condition);
    is( $condition->{'seed'},                 40 );
    is( $condition->{'forecast_description'}, 'clear' );

    $condition = { 'seed' => 40, 'forecast_description' => 'foo1' };
    ConditionGenerator::set_forecast($condition);
    is( $condition->{'seed'},                 40 );
    is( $condition->{'forecast_description'}, 'foo1' );

    done_testing();
};

subtest 'test set_clouds' => sub {
    my $condition;
    $condition = { 'seed' => 40 };
    ConditionGenerator::set_clouds($condition);
    is( $condition->{'seed'},               40 );
    is( $condition->{'clouds_description'}, 'whispy' );

    $condition = { 'seed' => 40, 'clouds_description' => 'foo1' };
    ConditionGenerator::set_clouds($condition);
    is( $condition->{'seed'},               40 );
    is( $condition->{'clouds_description'}, 'foo1' );

    done_testing();
};

subtest 'test set_precip' => sub {
    my $condition;

    $condition = { 'seed' => 40 };
    ConditionGenerator::set_precip($condition);
    is( $condition->{'seed'},               40 );
    is( $condition->{'precip_chance'},      1 );
    is( $condition->{'precip_description'}, "hail" );

    $condition = { 'seed' => 41 };
    ConditionGenerator::set_precip($condition);
    is( $condition->{'seed'},               41 );
    is( $condition->{'precip_chance'},      88 );
    is( $condition->{'precip_description'}, undef );

    $condition = { 'seed' => 44 };
    ConditionGenerator::set_precip($condition);
    is( $condition->{'seed'},                  44 );
    is( $condition->{'precip_chance'},         49 );
    is( $condition->{'precip_description'},    "sleeting" );
    is( $condition->{'precip_subdescription'}, undef );

    $condition
        = { 'seed' => 44, 'precip_chance' => '22', 'precip_description' => 'foo', 'precip_subdescription' => 'bar' };
    ConditionGenerator::set_precip($condition);
    is( $condition->{'seed'},                  44 );
    is( $condition->{'precip_chance'},         22 );
    is( $condition->{'precip_description'},    "foo" );
    is( $condition->{'precip_subdescription'}, "bar" );


    done_testing();
};


subtest 'test set_storm' => sub {
    my $condition;

    $condition = { 'seed' => 2 };
    ConditionGenerator::set_storm($condition);
    is( $condition->{'seed'},                  2 );
    is( $condition->{'storm_chance'},          92 );
    is( $condition->{'storm_description'},     undef );
    is( $condition->{'lightning_chance'},      undef );
    is( $condition->{'lightning_description'}, undef );
    is( $condition->{'thunder_chance'},        undef );
    is( $condition->{'thunder_description'},   undef );

    $condition = { 'seed' => 9 };
    ConditionGenerator::set_storm($condition);
    is( $condition->{'seed'},                  9 );
    is( $condition->{'storm_chance'},          1 );
    is( $condition->{'storm_description'},     "in the distance" );
    is( $condition->{'lightning_chance'},      "59" );
    is( $condition->{'lightning_description'}, undef );
    is( $condition->{'thunder_chance'},        24 );
    is( $condition->{'thunder_description'},   "rumbling" );

    $condition = { 'seed' => 8 };
    ConditionGenerator::set_storm($condition);
    is( $condition->{'seed'},                  8 );
    is( $condition->{'storm_chance'},          14 );
    is( $condition->{'storm_description'},     "in the distance" );
    is( $condition->{'lightning_chance'},      22 );
    is( $condition->{'lightning_description'}, "blinding" );
    is( $condition->{'thunder_chance'},        58 );
    is( $condition->{'thunder_description'},   undef );

    $condition = { 'seed' => 9954 };
    ConditionGenerator::set_storm($condition);
    is( $condition->{'seed'},                  9954 );
    is( $condition->{'storm_chance'},          14 );
    is( $condition->{'storm_description'},     "nearby" );
    is( $condition->{'lightning_chance'},      5 );
    is( $condition->{'lightning_description'}, "explosive" );
    is( $condition->{'thunder_chance'},        27 );
    is( $condition->{'thunder_description'},   "rumbling" );


    $condition = {
        'seed'                  => 1,
        'storm_chance'          => '1',
        'storm_description'     => 'foo',
        'lightning_chance'      => '2',
        'lightning_description' => 'bar',
        'thunder_chance'        => '10',
        'thunder_description'   => 'baz',
    };
    ConditionGenerator::set_storm($condition);
    is( $condition->{'seed'},                  1 );
    is( $condition->{'storm_chance'},          1.0 );
    is( $condition->{'storm_description'},     "foo" );
    is( $condition->{'lightning_chance'},      2 );
    is( $condition->{'lightning_description'}, "bar" );
    is( $condition->{'thunder_chance'},        10 );
    is( $condition->{'thunder_description'},   "baz" );

    done_testing();
};

subtest 'test flesh_out_condition' => sub {
    my $condition;

    $condition = { 'seed' => 1 };
    ConditionGenerator::create_condition($condition);
    ConditionGenerator::flesh_out_condition($condition);

    is( $condition->{'storm_chance'}, 5 );
    is_deeply( $condition->{'bar_mod'}, { 'time' => '0' } );
    is( $condition->{'time_description'},   'at daybreak' );
    is( $condition->{'clouds_description'}, 'whispy' );
    is( $condition->{'wind_description'},   'breezy' );
    is( $condition->{'time_pop_mod'},       '1.0' );
    is( $condition->{'precip_chance'},      5 );
    is( $condition->{'wind_pop_mod'},       '1.0' );
    is( $condition->{'time_bar_mod'},       '0' );
    is( $condition->{'temp_description'},   'unbearably cold' );
    is( $condition->{'air_description'},    'fresh' );
    is( $condition->{'time_exact'},         '06:54' );
    is( $condition->{'temp_pop_mod'},       '0.10' );
    is_deeply( $condition->{'pop_mod'}, { 'wind' => '1.0', 'temp' => '0.10', 'time' => '1.0', 'air' => '1.10' } );
    is( $condition->{'air_pop_mod'},          '1.10' );
    is( $condition->{'forecast_description'}, 'clear' );


};


1;


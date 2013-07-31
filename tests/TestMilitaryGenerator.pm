#!/usr/bin/perl -wT
###############################################################################
#
package TestMilitaryGenerator;

use strict;
use warnings;
use Test::More;
use MilitaryGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_military' => sub {
    my $military;
    set_seed(1);
    $military = MilitaryGenerator::create_military();
    is( $military->{'seed'},          41630 );
    is( $military->{'original_seed'}, 41630 );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    is( $military->{'seed'},          22 );
    is( $military->{'original_seed'}, 22 );

    done_testing();
};

subtest 'test generate_preparation' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             41630 );
    is( $military->{'preparation_roll'}, '68' );
    is( $military->{'preparation'},      'properly' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'preparation'} = 'foo';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '86' );
    is( $military->{'preparation'},      'foo' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'preparation_roll'} = '100';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '100' );
    is( $military->{'preparation'},      'perfectly' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'preparation_roll'} = '0';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '0' );
    is( $military->{'preparation'},      'abysmally' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'mil_mod'} = '-5';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '27' );
    is( $military->{'preparation'},      'tolerably' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'mil_mod'} = '-3';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '23' );
    is( $military->{'preparation'},      'inadequately' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'mil_mod'} = '1';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '76' );
    is( $military->{'preparation'},      'admirably' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    $military->{'mil_mod'} = '2';
    $military = MilitaryGenerator::generate_preparation($military);
    is( $military->{'seed'},             22 );
    is( $military->{'preparation_roll'}, '80' );
    is( $military->{'preparation'},      'admirably' );

    done_testing();
};


subtest 'test generate_favored_tactic' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military = MilitaryGenerator::generate_favored_tactic($military);
    is( $military->{'seed'},           41630 );
    is( $military->{'favored tactic'}, 'rigid formations' );

    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military->{'favored tactic'} = "spitwads";
    $military = MilitaryGenerator::generate_favored_tactic($military);
    is( $military->{'seed'},           41630 );
    is( $military->{'favored tactic'}, 'spitwads' );

    done_testing();
};

subtest 'test generate_reputation' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military = MilitaryGenerator::generate_reputation($military);
    is( $military->{'seed'},       41630 );
    is( $military->{'reputation'}, 'ridiculed' );

    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military->{'reputation'} = "spitwads";
    $military = MilitaryGenerator::generate_reputation($military);
    is( $military->{'seed'},       41630 );
    is( $military->{'reputation'}, 'spitwads' );

    done_testing();
};

subtest 'test generate_favored_weapon' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military = MilitaryGenerator::generate_favored_weapon($military);
    is( $military->{'seed'},           41630 );
    is( $military->{'favored weapon'}, 'light flail' );

    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military->{'favored weapon'} = "shoes";
    $military = MilitaryGenerator::generate_favored_weapon($military);
    is( $military->{'seed'},           41630 );
    is( $military->{'favored weapon'}, 'shoes' );

    done_testing();
};


subtest 'test set_troop_size' => sub {
    my $military;

    $military = MilitaryGenerator::create_military( { 'seed' => 1 } );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},             1 );
    is( $military->{'population_total'}, 4690, "random population size" );
    is( $military->{'active_percent'},   15 );
    is( $military->{'reserve_percent'},  7 );
    is( $military->{'para_percent'},     5.5 );
    is( $military->{'active_troops'},    703 );
    is( $military->{'reserve_troops'},   328 );
    is( $military->{'para_troops'},      38 );

    $military = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, } );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},             1 );
    is( $military->{'population_total'}, 10000, "population size" );
    is( $military->{'active_percent'},   12.75 );
    is( $military->{'reserve_percent'},  6.5 );
    is( $military->{'para_percent'},     4.5 );
    is( $military->{'active_troops'},    1275 );
    is( $military->{'reserve_troops'},   650 );
    is( $military->{'para_troops'},      57 );

    $military
        = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, 'military_mod' => 5, } );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},            1 );
    is( $military->{'active_percent'},  16.75 );
    is( $military->{'reserve_percent'}, 7 );
    is( $military->{'para_percent'},    5.25 );
    is( $military->{'active_troops'},   1675 );
    is( $military->{'reserve_troops'},  700 );
    is( $military->{'para_troops'},     87 );

    $military
        = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, 'authority_mod' => 5, } );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},            1 );
    is( $military->{'active_percent'},  15.75 );
    is( $military->{'reserve_percent'}, 5.75 );
    is( $military->{'para_percent'},    6.25 );
    is( $military->{'active_troops'},   1575 );
    is( $military->{'reserve_troops'},  575 );
    is( $military->{'para_troops'},     98 );

    $military = MilitaryGenerator::create_military(
        { 'seed' => 1, 'population_total' => 10000, 'military_mod' => 5, 'authority_mod' => 5 } );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},            1 );
    is( $military->{'active_percent'},  17.25 );
    is( $military->{'reserve_percent'}, 7.5 );
    is( $military->{'para_percent'},    3.75 );
    is( $military->{'active_troops'},   1725 );
    is( $military->{'reserve_troops'},  750 );
    is( $military->{'para_troops'},     64 );

    $military
        = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, 'active_percent' => 5 } );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},            1 );
    is( $military->{'active_percent'},  5 );
    is( $military->{'reserve_percent'}, 5.75 );
    is( $military->{'para_percent'},    4.25 );
    is( $military->{'active_troops'},   500 );
    is( $military->{'reserve_troops'},  575 );
    is( $military->{'para_troops'},     21 );

    $military = MilitaryGenerator::create_military(
        {
            'seed'             => 1,
            'population_total' => 10000,
            'active_percent'   => 5,
            'reserve_percent'  => 5,
            'para_percent'     => 10
        }
    );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},            1 );
    is( $military->{'active_percent'},  5 );
    is( $military->{'reserve_percent'}, 5 );
    is( $military->{'para_percent'},    10 );
    is( $military->{'active_troops'},   500 );
    is( $military->{'reserve_troops'},  500 );
    is( $military->{'para_troops'},     50 );

    $military = MilitaryGenerator::create_military(
        {
            'seed'             => 1,
            'population_total' => 10000,
            'active_percent'   => 5,
            'reserve_percent'  => 5,
            'para_percent'     => 10,
            'active_troops'    => 501,
            'reserve_troops'   => 501,
            'para_troops'      => 51
        }
    );
    $military = MilitaryGenerator::set_troop_size($military);
    is( $military->{'seed'},            1 );
    is( $military->{'active_percent'},  5 );
    is( $military->{'reserve_percent'}, 5 );
    is( $military->{'para_percent'},    10 );
    is( $military->{'active_troops'},   501 );
    is( $military->{'reserve_troops'},  501 );
    is( $military->{'para_troops'},     51 );


    done_testing();
};


1;

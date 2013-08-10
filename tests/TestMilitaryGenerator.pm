#!/usr/bin/perl -wT
###############################################################################
#
package TestMilitaryGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use MilitaryGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_military' => sub {
    my $military;
    GenericGenerator::set_seed(1);
    $military = MilitaryGenerator::create_military();
    is( $military->{'seed'},          41630 );

    $military = MilitaryGenerator::create_military( { 'seed' => 22 } );
    is( $military->{'seed'},          22 );

    done_testing();
};
subtest 'test generate_fortification' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    isnt( $military->{'fortification_roll'}, undef, 'fort roll is set' );
    isnt( $military->{'fortification'},      undef, 'fort is created'  );

    $military = MilitaryGenerator::create_military( { 'seed' => 22, 'fortification'=>'foo' } );
    is( $military->{'fortification'},      'foo' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22, 'fortification_roll'=>100 } );
    is( $military->{'fortification_roll'}, '100' );
    is( $military->{'fortification'},      'perfectly' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22,'fortification_roll'=>0 } );
    is( $military->{'fortification_roll'}, '0' );
    is( $military->{'fortification'},      'abysmally' );

    done_testing();
};

subtest 'test generate_preparation' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    
    isnt( $military->{'preparation_roll'}, undef, 'prep roll is set' );
    isnt( $military->{'preparation'},      undef, 'prep is created'  );

    $military = MilitaryGenerator::create_military( { 'seed' => 22, 'preparation'=>'foo' } );
    is( $military->{'preparation'},      'foo' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22, 'preparation_roll'=>100 } );
    is( $military->{'preparation_roll'}, '100' );
    is( $military->{'preparation'},      'perfectly' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22,'preparation_roll'=>0 } );
    is( $military->{'preparation_roll'}, '0' );
    is( $military->{'preparation'},      'abysmally' );

    $military = MilitaryGenerator::create_military( { 'seed' => 22, 'mil_mod'=>-5 } );
    ok( $military->{'preparation_roll'} <45, 'small military' );
    isnt( $military->{'preparation'},    undef, "making sure prep value is setyy" );

    $military = MilitaryGenerator::create_military( { 'seed' => 22,'mil_mod'=>-3 } );
    ok( $military->{'preparation_roll'} <45, 'small military' );
    isnt( $military->{'preparation'},    undef, "making sure prep value is set" );

    $military = MilitaryGenerator::create_military( { 'seed' => 22,  'mil_mod'=>1 } );
    ok( $military->{'preparation_roll'} >=1 && $military->{'preparation_roll'} <=100, 'any size military' );
    isnt( $military->{'preparation'},    undef, "making sure prep value is set" );

    $military = MilitaryGenerator::create_military( { 'seed' => 22, 'mil_mod'=>2 } );
    ok( $military->{'preparation_roll'} >55, 'large military' );
    isnt( $military->{'preparation'},    undef, "making sure prep value is set" );

    done_testing();
};


subtest 'test generate_favored_tactic' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military = MilitaryGenerator::generate_favored_tactic($military);
    is( $military->{'seed'},           41630 );
    isnt( $military->{'favored tactic'}, undef, 'ensuring favoried tactic exists' );

    $military = MilitaryGenerator::create_military( { 'seed' => 41630, 'favored tactic'=>'spitwads' } );
    $military = MilitaryGenerator::generate_favored_tactic($military);
    is( $military->{'favored tactic'}, 'spitwads' );

    done_testing();
};

subtest 'test generate_reputation' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    isnt( $military->{'reputation'},undef, 'ensuring reputation exists' );

    $military = MilitaryGenerator::create_military( { 'seed' => 41630, 'reputation'=>'spitwads' } );
    is( $military->{'reputation'}, 'spitwads' );

    done_testing();
};

subtest 'test generate_favored_weapon' => sub {
    my $military;
    $military = MilitaryGenerator::create_military( { 'seed' => 41630 } );
    $military = MilitaryGenerator::generate_favored_weapon($military);
    isnt( $military->{'favored weapon'}, undef, 'ensuring favored weapon exists' );

    $military = MilitaryGenerator::create_military( { 'seed' => 41630,'favored weapon' => "shoes" } );
    is( $military->{'favored weapon'}, 'shoes' );

    done_testing();
};


subtest 'test set_troop_size' => sub {
    my $military;

    $military = MilitaryGenerator::create_military(  );
    $military = MilitaryGenerator::set_troop_size($military);
    foreach my $value (qw( seed population_total active_percent reserve_percent para_percent active_troops reserve_troops para_troops ) ){
        isnt( $military->{$value},   undef );
    }

    $military = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, } );
    foreach my $value (qw( seed population_total active_percent reserve_percent para_percent active_troops reserve_troops para_troops)){
        isnt($military->{$value}, undef, "ensure $value is set");
    }

    my $military2
        = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, 'military_mod' => 5, } );
    is( $military2->{'seed'},             $military->{'seed'},           "ensure seed is the same" );
    ok( $military2->{'active_percent'}   >$military->{'active_percent'}, "ensure active_percent is larger");
    ok( $military2->{'reserve_percent'}  >$military->{'reserve_percent'},"ensure reserve_percent is larger");
    #ok( $military2->{'para_percent'}     >$military->{'para_percent'},   "ensure para_percent is larger");
    ok( $military2->{'active_troops'}    >$military->{'active_troops'},  "ensure active_troops is larger");
    ok( $military2->{'reserve_troops'}   >$military->{'reserve_troops'}, "ensure reserve_troops is larger");
    ok( $military2->{'para_troops'}      >$military->{'para_troops'},    "ensure para_troops is larger");



    $military2
        = MilitaryGenerator::create_military(       { 'seed' => 1, 'population_total' => 10000, 'authority_mod' => 5, } );
    is( $military2->{'seed'},             $military->{'seed'},           "ensure seed is the same" );
    ok( $military2->{'active_percent'}   >$military->{'active_percent'}, "ensure active_percent is larger");
    ok( $military2->{'reserve_percent'}  >$military->{'reserve_percent'},"ensure reserve_percent is larger");
    #ok( $military2->{'para_percent'}     >$military->{'para_percent'},   "ensure para_percent is larger");
    ok( $military2->{'active_troops'}    >$military->{'active_troops'},  "ensure active_troops is larger");
    ok( $military2->{'reserve_troops'}   >$military->{'reserve_troops'}, "ensure reserve_troops is larger");
    ok( $military2->{'para_troops'}      >$military->{'para_troops'},    "ensure para_troops is larger");

    $military2 = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, 'military_mod' => 5, 'authority_mod' => 5 } );
    is( $military2->{'seed'},             $military->{'seed'},           "ensure seed is the same" );
    ok( $military2->{'active_percent'}   >$military->{'active_percent'}, "ensure active_percent is larger");
    ok( $military2->{'reserve_percent'}  >$military->{'reserve_percent'},"ensure reserve_percent is larger");
    #ok( $military2->{'para_percent'}     >$military->{'para_percent'},   "ensure para_percent is larger");
    ok( $military2->{'active_troops'}    >$military->{'active_troops'},  "ensure active_troops is larger");
    ok( $military2->{'reserve_troops'}   >$military->{'reserve_troops'}, "ensure reserve_troops is larger");
    ok( $military2->{'para_troops'}      >$military->{'para_troops'},    "ensure para_troops is larger");

    $military2 = MilitaryGenerator::create_military( { 'seed' => 1, 'population_total' => 10000, 'active_percent' => 0,'reserve_percent'=>0,'para_percent'=>0 } );
    is( $military2->{'seed'},             $military->{'seed'},           "ensure seed is the same" );
    ok( $military2->{'active_percent'}   <$military->{'active_percent'}, "ensure active_percent is smaller");
    ok( $military2->{'reserve_percent'}  <$military->{'reserve_percent'},"ensure reserve_percent is smaller");
    ok( $military2->{'para_percent'}     <$military->{'para_percent'},   "ensure para_percent is smaller");
    ok( $military2->{'active_troops'}    <$military->{'active_troops'},  "ensure active_troops is smaller");
    ok( $military2->{'reserve_troops'}   <$military->{'reserve_troops'}, "ensure reserve_troops is smaller");
    ok( $military2->{'para_troops'}      <$military->{'para_troops'},    "ensure para_troops is smaller");



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

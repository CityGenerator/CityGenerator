#!/usr/bin/perl -wT
###############################################################################
#
package TestNPCGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test set_sex' => sub {
    my $npc;
    $npc = NPCGenerator::create_npc( { seed => 4 } );
    isnt( $npc->{'pronoun'}, undef );

    $npc = NPCGenerator::create_npc( { 'seed' => 4, 'pronoun' => 'she' } );
    is( $npc->{'pronoun'}, 'she' );

    $npc = NPCGenerator::create_npc( { 'seed' => 4, 'pronoun' => 'it' } );
    is( $npc->{'pronoun'}, 'it' );

    $npc = NPCGenerator::create_npc( { 'seed' => 4, 'pronoun' => 'he' } );
    is( $npc->{'pronoun'}, 'he' );


    done_testing();
};

subtest 'test set_level' => sub {
    my $npc;

    $npc = NPCGenerator::create_npc( { 'seed' => 5 } );
    is( $npc->{'level'}, '3' );

    $npc = NPCGenerator::create_npc( { 'seed' => 5, 'size_modifier' => 12 } );
    NPCGenerator::set_level($npc);
    is( $npc->{'level'}, '7' );

    $npc = NPCGenerator::create_npc( { 'seed' => 5, 'level' => 20 } );
    is( $npc->{'level'}, '20' );


    $npc = NPCGenerator::create_npc( { seed => 5, 'size_modifier' => 1000 } );
    NPCGenerator::set_level($npc);
    is( $npc->{'level'}, '20' );

    $npc = NPCGenerator::create_npc( { seed => 5, 'size_modifier' => -5 } );
    NPCGenerator::set_level($npc);
    is( $npc->{'level'}, '1' );

    done_testing();
};
subtest 'test set_class' => sub {
    my $npc;

    $npc = NPCGenerator::create_npc( { 'seed' => 5 } );
    is( $npc->{'class'}, 'Bard' );

    $npc = NPCGenerator::create_npc( { 'seed' => 5, 'class_roll' => 12 } );
    is( $npc->{'class'}, 'Commoner' );

    $npc = NPCGenerator::create_npc( { 'seed' => 5, 'class_roll' => 12, 'class' => 'Druid' } );
    is( $npc->{'class'}, 'Druid' );


    done_testing();
};


subtest 'test create_npc' => sub {
    subtest 'test create_npc race and seed' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => 1 } );
        is( $npc->{'race'}, 'mindflayer' );

        $npc = NPCGenerator::create_npc( { 'seed' => 41630, 'race' => 'orc' } );
        is( $npc->{'race'}, 'orc' );

        $npc = NPCGenerator::create_npc( { 'seed' => 1, 'race' => 'elf' } );
        is( $npc->{'race'}, 'elf', "race is elf when set" );
        is( $npc->{'seed'}, 1,     "seed is 1 when set." );

        done_testing();
    };
    subtest 'test create_npc_acceptable_races' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => 1 } );
        is( $npc->{'race'}, 'mindflayer', );

        $npc = NPCGenerator::create_npc( { 'seed' => 1, 'available_races' => ['deep dwarf'] } );
        is( $npc->{'race'}, 'deep dwarf', );

        $npc = NPCGenerator::create_npc( { 'seed' => 1, 'available_races' => [ 'deep dwarf', 'human', 'halfling' ] } );
        is_deeply( $npc->{'available_races'}, undef, "ensure available races were removed" );
        is( $npc->{'race'}, 'deep dwarf' );

        done_testing();
    };

    subtest 'test create_npc name' => sub {
        my $npc;
        $npc = NPCGenerator::create_npc( { 'seed' => '1', 'race' => 'elf' } );
        is( $npc->{'name'}, 'Abaellthil Meadowsing', "name is set" );
        done_testing();
    };
    subtest 'test create_npc profession' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => '1', 'race' => 'elf' } );
        is( $npc->{'profession'}, 'actor' );
        is( $npc->{'business'},   'theater' );

        $npc = NPCGenerator::create_npc(
            { 'seed' => '1', 'race' => 'elf', 'allowed_professions' => [ 'cobbler', 'priest' ] } );
        is( $npc->{'profession'}, 'cobbler' );
        is( $npc->{'business'},   'cobblershop' );

        $npc = NPCGenerator::create_npc( { 'seed' => '1', 'race' => 'elf', 'allowed_professions' => ['priest'] } );
        is( $npc->{'profession'}, 'priest' );
        is( $npc->{'business'},   'shrine' );

        $npc = NPCGenerator::create_npc( { 'seed' => '1', 'race' => 'elf', 'allowed_professions' => ['churchle'] } );
        is( $npc->{'profession'}, 'churchle' );
        is( $npc->{'business'},   'churchle' );

        done_testing();
    };

    subtest 'test create_npc attitudes' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => 1 } );
        is( $npc->{'primary_attitude'},   'Fear',        "emotional state" );
        is( $npc->{'secondary_attitude'}, 'Nervousness', "emotional state" );
        is( $npc->{'ternary_attitude'},   'Uneasiness',  "emotional state" );

        $npc = NPCGenerator::create_npc(
            {
                'seed'               => 1,
                'primary_attitude'   => 'Anger',
                'secondary_attitude' => 'Rage',
                'ternary_attitude'   => 'Hostility'
            }
        );
        is( $npc->{'primary_attitude'},   'Anger',     "emotional state" );
        is( $npc->{'secondary_attitude'}, 'Rage',      "emotional state" );
        is( $npc->{'ternary_attitude'},   'Hostility', "emotional state" );

        done_testing();
    };
    done_testing();
};

subtest 'test get_races' => sub {

    my $races = NPCGenerator::get_races();

    is( scalar(@$races), 23, "Total of 23 races allowed." );

    done_testing();
};

subtest 'test generate_npc_names' => sub {
    GenericGenerator::set_seed(1);
    my $names = NPCGenerator::generate_npc_names( 'human', 2 );
    is( scalar(@$names), 2 );
    $names = NPCGenerator::generate_npc_names( 'any', 2 );
    is( scalar(@$names), 2 );
    $names = NPCGenerator::generate_npc_names( 'any', 'ef' );
    is( scalar(@$names), 10 );
    $names = NPCGenerator::generate_npc_names( 'any', );
    is( scalar(@$names), 10 );
    $names = NPCGenerator::generate_npc_names( 'fakerace', );
    is( scalar(@$names), 10 );
    done_testing();
};

subtest 'test generate_npc_name' => sub {

    subtest 'test generating Mutt Race' => sub {
        GenericGenerator::set_seed(1);
        my $name = NPCGenerator::generate_npc_name('any');
        is( $name, 'Dave Matgton' );

        for ( my $i = 0 ; $i < 10 ; $i++ ) {
            GenericGenerator::set_seed( 2 + $i );
            $name = NPCGenerator::generate_npc_name('half-orc');

            #like($name, qr/(\(orc\)|\(human\))/, "should be human or orc" );
        }
        done_testing();
    };
    subtest 'test generating unknown race' => sub {
        GenericGenerator::set_seed(1);
        my $name = NPCGenerator::generate_npc_name('CongressCritter');
        is( $name, 'unnamed congresscritter' );
        done_testing();
    };

    done_testing();
};

subtest 'test NPC motivations' => sub {
    my $npc;
    $npc = NPCGenerator::create_npc( { 'seed' => 1 } );
    isnt( $npc->{'motivation'},        undef, );
    isnt( $npc->{'motivation_detail'}, undef, );
    is( $npc->{'motivation_description'}, $npc->{'motivation'} . " " . $npc->{'motivation_detail'}, );

    $npc = NPCGenerator::create_npc(
        {
            'seed'                   => 1,
            'motivation'             => 'to play',
            'motivation_detail'      => 'whirlyball',
            'motivation_description' => 'to hate whirlyball'
        }
    );
    is( $npc->{'motivation'},             'to play', );
    is( $npc->{'motivation_detail'},      'whirlyball', );
    is( $npc->{'motivation_description'}, 'to hate whirlyball', );

    $npc = NPCGenerator::create_npc( { 'seed' => 1, 'motivation' => 'to play', 'motivation_detail' => 'whirlyball' } );
    is( $npc->{'motivation'},             'to play', );
    is( $npc->{'motivation_detail'},      'whirlyball', );
    is( $npc->{'motivation_description'}, 'to play whirlyball', );

    $npc = NPCGenerator::create_npc( { 'seed' => 1, 'motivation' => 'to play' } );
    is( $npc->{'motivation'},             'to play', );
    is( $npc->{'motivation_detail'},      '', );
    is( $npc->{'motivation_description'}, 'to play', );

    $npc = NPCGenerator::create_npc( { 'seed' => 1, 'motivation' => 'finding a missing' } );
    is( $npc->{'motivation'},             'finding a missing', );
    is( $npc->{'motivation_detail'},      'parent', );
    is( $npc->{'motivation_description'}, 'finding a missing parent', );

    done_testing();

};


1;

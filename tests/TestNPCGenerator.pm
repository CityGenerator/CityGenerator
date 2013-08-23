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

    $npc = NPCGenerator::create_npc( { 'seed' => 4, 'pronoun' => 'it', 'posessivepronoun'=>'frog', 'sex'=>'other' } );
    is( $npc->{'pronoun'}, 'it' );
    is( $npc->{'posessivepronoun'}, 'frog' );
    is( $npc->{'sex'}, 'other' );

    $npc = NPCGenerator::create_npc( { 'seed' => 4, 'pronoun' => 'he' } );
    is( $npc->{'pronoun'}, 'he' );


    done_testing();
};

subtest 'test set_class' => sub {
    my $npc;

    $npc = NPCGenerator::create_npc( { 'seed' => 5 } );
    isnt( $npc->{'class'}, undef, 'class exists' );

    $npc = NPCGenerator::create_npc( { 'seed' => 5, 'class_roll' => 12 } );
    is( $npc->{'class'}, 'Commoner' );

    $npc = NPCGenerator::create_npc( { 'seed' => 5, 'class_roll' => 12, 'class' => 'Druid' } );
    is( $npc->{'class'}, 'Druid', 'class is preset to Druid' );


    done_testing();
};


subtest 'test create_npc' => sub {
    subtest 'test create_npc race and seed' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => 1 } );
        isnt( $npc->{'race'}, undef, 'race is set' );

        $npc = NPCGenerator::create_npc( { 'seed' => 1, 'race' => 'orc' } );
        is( $npc->{'race'}, 'orc', 'race is preset to orc' );

        done_testing();
    };
    subtest 'test create_npc_acceptable_races' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => 1 } );
        isnt( $npc->{'race'}, undef, "ensure race is set" );

        $npc = NPCGenerator::create_npc( { 'seed' => 1, 'available_races' => ['deep dwarf'] } );
        is( $npc->{'race'}, 'deep dwarf', "deep dwarf is the only acceptable choice");

        $npc = NPCGenerator::create_npc( { 'seed' => 1, 'available_races' => [ 'deep dwarf', 'human', 'halfling' ] } );
        is_deeply( $npc->{'available_races'}, undef, "ensure available races were removed" );
        ok( $npc->{'race'} eq 'deep dwarf' || $npc->{'race'} eq 'human' || $npc->{'race'} eq 'halfling' , "$npc->{'race'} one of the 3 races" );

        done_testing();
    };

    subtest 'test create_npc name' => sub {
        my $npc;
        $npc = NPCGenerator::create_npc( { 'seed' => '1', 'race' => 'elf' } );
        isnt( $npc->{'name'}, undef, "name is set" );
        done_testing();
    };
    subtest 'test create_npc profession' => sub {
        my $npc;

        $npc = NPCGenerator::create_npc( { 'seed' => '1',  } );
        isnt( $npc->{'profession'}, undef, 'business is set' );
        isnt( $npc->{'business'},   undef, 'business is set' );

        $npc = NPCGenerator::create_npc(
            { 'seed' => '1', 'race' => 'elf', 'allowed_professions' => [ ] } );
        isnt( $npc->{'profession'}, undef, 'business is set' );
        isnt( $npc->{'business'},   undef, 'business is set' );

        $npc = NPCGenerator::create_npc(
            { 'seed' => '1', 'race' => 'elf', 'allowed_professions' => [ 'cobbler', 'cheesemaker' ] } );
        ok( $npc->{'profession'} eq 'cobbler' || $npc->{'profession'} eq 'cheesemaker',  "$npc->{'profession'} is either a cobbler or cheesemaker" );
        ok( $npc->{'business'} eq  'cobblershop' || $npc->{'business'} eq  'cheeseshop', "$npc->{'business'} is a cobblershop or a cheeseshop");

        $npc = NPCGenerator::create_npc( { 'seed' => '1', 'allowed_professions' => ['priest'] } );
        is( $npc->{'profession'}, 'priest', "$npc->{'profession'} is a priest" );
        ok( $npc->{'business'} eq   'shrine' || $npc->{'business'} eq   'temple' || $npc->{'business'} eq   'church', "$npc->{'business'} is a shrine, temple or church"  );

        $npc = NPCGenerator::create_npc( { 'seed' => '1',  'allowed_professions' => ['churchle'] } );
        is( $npc->{'profession'}, 'churchle', "$npc->{'profession'} a churchele isn't real, right?" );
        is( $npc->{'business'},   $npc->{'profession'}, "$npc->{'business'} should be the same as $npc->{'profession'}." );

        done_testing();
    };

    subtest 'test create_npc attitudes' => sub {
        my $npc;
        my $presets={'seed' => 1 };
        $npc = NPCGenerator::create_npc( $presets );
        foreach my $value (qw( primary_attitude secondary_attitude ternary_attitude)){
            isnt($npc->{$value},undef, "$value 'emotional state");
        }

        $presets->{'primary_attitude'}='Anger';
        $npc = NPCGenerator::create_npc( $presets );
        is( $npc->{'primary_attitude'},'Anger', "You are Angry");
        foreach my $value (qw( secondary_attitude ternary_attitude)){
            isnt($npc->{$value},undef, "$value 'emotional state");
        }
        $presets->{'secondary_attitude'}='Rage';
        $npc = NPCGenerator::create_npc( $presets );
        is( $npc->{'primary_attitude'},'Anger', "You are Angry");
        is( $npc->{'secondary_attitude'},'Rage', "You feel rage");
        foreach my $value (qw( ternary_attitude)){
            isnt($npc->{$value},undef, "$value 'emotional state");
        }
        $presets->{'ternary_attitude'}='Hostility';
        $npc = NPCGenerator::create_npc( $presets );
        is( $npc->{'primary_attitude'},'Anger', "You are Angry");
        is( $npc->{'secondary_attitude'},'Rage', "You feel rage");
        is( $npc->{'ternary_attitude'},'Hostility', "You feel Hostility");


        $presets={'seed' => 1 };
        $presets->{'primary_attitude'}='Foo';
        $npc = NPCGenerator::create_npc( $presets );
        is($npc->{'primary_attitude'},'Foo', "primary_attitude is Foo");
        is($npc->{'secondary_attitude'},'Foo', "secondary_attitude is Foo");
        is($npc->{'ternary_attitude'},'Foo', "ternary_attitude is Foo");

        $presets->{'secondary_attitude'}='Bar';
        $npc = NPCGenerator::create_npc( $presets );
         is($npc->{'primary_attitude'},'Foo', "primary_attitude is Foo");
         is($npc->{'secondary_attitude'},'Bar', "secondary_attitude is Bar");
         is($npc->{'ternary_attitude'},'Foo', "ternary_attitude is Foo");

        $presets->{'ternary_attitude'}='Baz';
        $npc = NPCGenerator::create_npc( $presets );
         is($npc->{'primary_attitude'},'Foo', "primary_attitude is Foo");
         is($npc->{'secondary_attitude'},'Bar', "secondary_attitude is Bar");
         is($npc->{'ternary_attitude'},'Baz', "ternary_attitude is Baz");

        $presets={'seed' => 1 };

        $presets->{'secondary_attitude'}='Bar';
        $npc = NPCGenerator::create_npc( $presets );
         is($npc->{'secondary_attitude'},'Bar', "secondary_attitude is Bar");
         is($npc->{'ternary_attitude'},'Bar', "ternary_attitude is Bar");

        $presets->{'ternary_attitude'}='Baz';
        $npc = NPCGenerator::create_npc( $presets );
         is($npc->{'secondary_attitude'},'Bar', "secondary_attitude is Bar");
         is($npc->{'ternary_attitude'},'Baz', "ternary_attitude is Baz");




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

        for ( my $i = 0 ; $i < 10 ; $i++ ) {
            GenericGenerator::set_seed( 2 + $i );
            $name = NPCGenerator::generate_npc_name('half-orc');
            isnt( $name, undef, "as long as it's something" );
            #FIXME I have no way to test that this is human or halforc and not lizardfolk.
        }
        done_testing();
    };
    subtest 'test generating unknown race' => sub {
        GenericGenerator::set_seed(1);
        my $name = NPCGenerator::generate_npc_name('CongressCritter');
        isnt( $name, undef, "something is returned." );
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

    $npc = NPCGenerator::create_npc( { 'seed' => 1, 'motivation_detail' => 'fun'  } );
    isnt( $npc->{'motivation'},            undef, );
    is( $npc->{'motivation_detail'},      "fun", );
    like( $npc->{'motivation_description'}, '/ fun$/', "ends with fun" );

    $npc = NPCGenerator::create_npc( { 'seed' => 1, 'motivation' => 'finding a missing' } );
    is( $npc->{'motivation'},             'finding a missing', );
    foreach my $value (qw( motivation_detail  motivation_description)){
        isnt($npc->{$value},undef, "$value 'ensure value exists");
    }

    done_testing();

};


1;

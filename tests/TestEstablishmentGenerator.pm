#!/usr/bin/perl -wT
###############################################################################
#
package TestEstablishmentGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use EstablishmentGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_establishment' => sub {
    my $establishment;
    $establishment = EstablishmentGenerator::create_establishment( );
    isnt( $establishment->{'seed'}, undef );
    isnt( $establishment->{'name'}, undef );
    isnt( $establishment->{'manager'}, undef);
    foreach my $stat (qw/ price popularity size reputation /) {
        cmp_ok( $establishment->{'stats'}->{$stat}, '<=', 100, "$stat max" );
        cmp_ok( $establishment->{'stats'}->{$stat}, '>=', 1,   "$stat min" );
    }

    my $stats={
             'reputation'=>50, 'size'=>50, 'price'=>50, 'popularity'=>50
        };


    $establishment = EstablishmentGenerator::create_establishment( {'seed'=>1, 'name'=>'sleepy beaver', 'stats'=>$stats, 'type'=>'barbershop', 'manager_title'=>'briggadoon' } );
    is( $establishment->{'seed'}, 1 );
    is( $establishment->{'name'}, 'Sleepy Beaver' );
    is( $establishment->{'type'}, 'barbershop' );
    is( $establishment->{'manager_title'}, 'briggadoon' );
    foreach my $stat (qw/ price popularity size reputation /) {
        is( $establishment->{'stats'}->{$stat}, 50, "$stat is set" );
    }

    my $descriptors;
    foreach my $stat (qw/ price popularity size reputation /) {
        $descriptors->{$stat."_description"}= "foo";
    }

    $establishment = EstablishmentGenerator::create_establishment( $descriptors);
    foreach my $stat (qw/ price popularity size reputation /) {
        is ($establishment->{$stat."_description"}, "foo", "$stat description set to foo" );
    }


    $establishment = EstablishmentGenerator::create_establishment( {'seed'=>1, 'trailer'=>'Foo', 'manager_class'=>'Derp', 'graft'=>'foo', 'enforcer'=>'bob', 'condition'=>'shiny', 'direction'=>'west', 'service_type'=>'foo'});
    is( $establishment->{'trailer'}, 'Foo' );
    is( $establishment->{'service_type'}, 'foo' );
    is( $establishment->{'graft'}, 'foo' );
    is( $establishment->{'direction'}, 'west');
    is( $establishment->{'condition'}, 'shiny' );
    is( $establishment->{'enforcer'}, 'bob' );
    like( $establishment->{'name'}, '/Foo$/' );
    is( $establishment->{'manager_class'}, 'Derp' );

    my $manager=NPCGenerator::create_npc({'seed'=>1}) ;
    $establishment = EstablishmentGenerator::create_establishment( {'seed'=>1, 'manager'=>$manager});
    is( $establishment->{'manager'}, $manager );

    done_testing();
};

1;

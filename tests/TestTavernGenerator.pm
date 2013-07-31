#!/usr/bin/perl -wT
###############################################################################
#
package TestTavernGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use TavernGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_tavern' => sub {
    my $tavern;
    $tavern = TavernGenerator::create_tavern( { 'seed' => 41630 } );
    is( $tavern->{'seed'}, 41630 );
    is( $tavern->{'name'}, 'Ruby Thug' );

    foreach my $stat (qw/ cost popularity size reputation /) {
        cmp_ok( $tavern->{'stats'}->{$stat}, '<=', 100, "$stat max" );
        cmp_ok( $tavern->{'stats'}->{$stat}, '>=', 1,   "$stat min" );
    }


    $tavern = TavernGenerator::create_tavern(
        {
            'seed'  => 41630,
            'name'  => 'test',
            'stats' => { 'cost' => 11, 'popularity' => 11, 'size' => 11, 'reputation' => 11 }
        }
    );
    is( $tavern->{'seed'},                  41630 );
    is( $tavern->{'name'},                  'test' );
    is( $tavern->{'stats'}->{'cost'},       11 );
    is( $tavern->{'stats'}->{'popularity'}, 11 );
    is( $tavern->{'stats'}->{'size'},       11 );
    is( $tavern->{'stats'}->{'reputation'}, 11 );


    done_testing();
};

subtest 'test generate_bartender' => sub {
    my $tavern;

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22 } );
    is( $tavern->{'bartender'}->{'race'}, 'orc' );

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22, 'bartender' => { 'race' => 'dwarf' } } );
    is( $tavern->{'bartender'}->{'race'}, 'dwarf' );

    done_testing();
};
subtest 'test generate_amenities' => sub {
    my $tavern;

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22 } );
    cmp_ok( $tavern->{'amenity_count'},          '<=', 3, "amenity max" );
    cmp_ok( $tavern->{'amenity_count'},          '>=', 0, "amenity min" );
    cmp_ok( scalar( @{ $tavern->{'amenity'} } ), '<=', 3, "amenity max" );
    cmp_ok( scalar( @{ $tavern->{'amenity'} } ), '>=', 0, "amenity min" );
    is( scalar( @{ $tavern->{'amenity'} } ), $tavern->{'amenity_count'}, 'amenities match count' );

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22, 'amenity_count' => '2' } );
    is( $tavern->{'amenity_count'},          2 );
    is( scalar( @{ $tavern->{'amenity'} } ), 2 );

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22, 'amenity_count' => '1', 'amenity' => ['grapejuice'] } );
    is( $tavern->{'amenity_count'},          1 );
    is( scalar( @{ $tavern->{'amenity'} } ), 1 );
    is( $tavern->{'amenity'}->[0],           'grapejuice' );

    done_testing();
};

subtest 'test generate_violence' => sub {
    my $tavern;

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22 } );
    is( $tavern->{'violence'}, 'swift justice' );

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22, 'violence' => 'nothing' } );
    is( $tavern->{'violence'}, 'nothing' );

    done_testing();
};
subtest 'test generate_law' => sub {
    my $tavern;

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22 } );
    is( $tavern->{'law'}, 'harasses' );

    $tavern = TavernGenerator::create_tavern( { 'seed' => 22, 'law' => 'does nothing' } );
    is( $tavern->{'law'}, 'does nothing' );

    done_testing();
};


1;


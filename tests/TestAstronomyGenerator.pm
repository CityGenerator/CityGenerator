#!/usr/bin/perl -wT
###############################################################################
#
package TestAstronomyGenerator;

use strict;
use warnings;

use AstronomyGenerator;
use Data::Dumper;
use Exporter;
use Test::More;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);

use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create' => sub {
    my $astronomy;

    $astronomy = AstronomyGenerator::create();
    isnt( $astronomy->{'seed'}, undef, 'ensure the seed is set' );

    $astronomy = AstronomyGenerator::create( { 'seed' => 1 } );
    is( $astronomy->{'seed'}, 1, 'ensure the seed is 1' );

    done_testing();
};


subtest 'test generate_starsystem' => sub {
    my $astronomy;
    $astronomy = AstronomyGenerator::create( { 'seed' => 12345 } );
    is( $astronomy->{'seed'},               12345,     "correct seed" );
    is( $astronomy->{'star'}[0]->{'name'},  'Krojol',  "correct name" );
    is( $astronomy->{'star'}[0]->{'size'},  'average', "correct size" );
    is( $astronomy->{'star'}[0]->{'color'}, 'white',   "correct color" );

    $astronomy = AstronomyGenerator::create( { 'seed' => 1, 'starsystem_roll' => 98 } );
    foreach my $fieldname (qw( name size color)) {
        foreach my $id (qw( 0 1 2 )) {
            isnt( $astronomy->{'star'}[$id]->{$fieldname}, undef, " $fieldname for star $id" );
        }
    }

    $astronomy = AstronomyGenerator::create(
        {
            'seed'             => 1,
            'star'             => [ { 'name' => 'foo', 'size' => 'bar', 'color' => 'baz' } ],
            'star_description' => ['blah blah']
        }
    );
    foreach my $fieldname (qw( name size color)) {
        isnt( $astronomy->{'star'}[0]->{$fieldname}, undef, " $fieldname for star 0" );
    }

    is( $astronomy->{'star_description'}[0], 'blah blah', 'ensure star description is not overwritten' );

    $astronomy = AstronomyGenerator::create(
        {
            'seed'             => 1,
            'star'             => [ { 'name' => 'foo', 'size_roll' => 50, 'color_roll' => 50 } ],
            'star_description' => ['blah blah']
        }
    );

    is( $astronomy->{'star'}[0]->{'name'},  'foo',     'selected name' );
    is( $astronomy->{'star'}[0]->{'size'},  'average', 'average size roll' );
    is( $astronomy->{'star'}[0]->{'color'}, 'yellow',  'average color roll' );

    done_testing();
};
subtest 'test generate_moons' => sub {
    my $astronomy;

    subtest 'test moon count and name' => sub {
        $astronomy = AstronomyGenerator::create( { 'seed' => 765379, 'moons_roll' => "96", 'moons_count'=>0, 'moons_name'=>'derple moon' } );
        is( $astronomy->{'moons'}[0], undef);
        is( $astronomy->{'moons_name'}, 'derple moon');
        done_testing();
    };
    

    $astronomy = AstronomyGenerator::create( { 'seed' => 765379, 'moons_roll' => "96" } );
    foreach my $fieldname (qw( name size )) {
        foreach my $id (qw( 0 1 2 )) {
            isnt( $astronomy->{'moon'}[$id]->{$fieldname}, undef, " $fieldname for moon $id" );
        }
    }

    $astronomy = AstronomyGenerator::create(
        {
            'seed'             => 12345,
            'moon'             => [ { 'name' => 'foo', 'size' => 'bar', 'color' => 'baz' } ],
            'moon_description' => ['blah blah']
        }
    );

    is( $astronomy->{'moon'}[0]->{'name'},   'foo',       'set name' );
    is( $astronomy->{'moon'}[0]->{'size'},   'bar',       'set size' );
    is( $astronomy->{'moon'}[0]->{'color'},  'baz',       'set color' );
    is( $astronomy->{'moon_description'}[0], 'blah blah', 'set moon description' );

    $astronomy = AstronomyGenerator::create(
        {
            'seed'             => 12345,
            'moon'             => [ { 'name' => 'foo', 'size_roll' => 50, 'color_roll' => 50 } ],
            'moon_description' => ['blah blah']
        }
    );

    is( $astronomy->{'moon'}[0]->{'size'},  'average',    'rolled size' );
    is( $astronomy->{'moon'}[0]->{'color'}, 'bone white', 'rolled color' );

    done_testing();
};

subtest 'test generate_celetial_objects' => sub {
    my $astronomy;
    $astronomy = AstronomyGenerator::create( { 'seed' => 765373, 'celestial_roll' => 70 } );
    is( $astronomy->{'celestial_count'}, "2",                     'rolled count' );
    is( $astronomy->{'celestial_roll'},  "70",                    'set roll' );
    is( $astronomy->{'celestial_name'},  "two celestial objects", 'rolled name' );

    foreach my $fieldname (qw( name size )) {
        foreach my $id (qw( 0 1 )) {
            isnt( $astronomy->{'celestial'}[$id]->{$fieldname}, undef, " $fieldname for celestial $id" );
        }
    }

    is( $astronomy->{'celestial'}[2], undef, 'ensure theres no 3rd object' );

    $astronomy = AstronomyGenerator::create( { 'seed' => 765373, 'celestial_roll' => 1 } );
    is( $astronomy->{'celestial_count'}, "0",               'rolled count' );
    is( $astronomy->{'celestial_roll'},  "1",               'low set roll' );
    is( $astronomy->{'celestial_name'},  "nothing unusual", 'rolled description' );
    is( $astronomy->{'celestial'}[0],    undef,             'ensure no objects' );

    done_testing();
};


done_testing();
1;


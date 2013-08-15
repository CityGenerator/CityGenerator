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
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_establishment' => sub {
    my $establishment;
    GenericGenerator::set_seed(1);
    $establishment = EstablishmentGenerator::create_establishment( { } );
    isnt( $establishment->{'seed'}, undef );
    isnt( $establishment->{'name'}, undef );
    isnt( $establishment->{'manager'}, undef);
    foreach my $stat (qw/ price popularity size reputation /) {
        cmp_ok( $establishment->{'stats'}->{$stat}, '<=', 100, "$stat max" );
        cmp_ok( $establishment->{'stats'}->{$stat}, '>=', 1,   "$stat min" );
    }
    isnt( $establishment->{'type'}, undef );
    isnt( $establishment->{'manager_title'}, undef );
    isnt( $establishment->{'manager_class'}, undef );
    isnt( $establishment->{'manager'}, undef );

    $establishment = EstablishmentGenerator::create_establishment(
        {
            'seed'  => 41630,
            'name'  => 'test',
            'type'  => 'pottery',
            'stats' => { 'price' => 11, 'popularity' => 11, 'size' => 11, 'reputation' => 11 },
            'price_description'         => 'bummer',
            'popularity_description'    => 'bummer',
            'size_description'          => 'bummer',
            'reputation_description'    => 'bummer',
        }
    );
    is( $establishment->{'seed'},                  41630 );
    is( $establishment->{'name'},                  undef );
    foreach my $stat (qw(price popularity size reputation)){
        is( $establishment->{'stats'}->{$stat},       11 );
        is( $establishment->{$stat."_description"},    "bummer" );
    }
    is( $establishment->{'type'}, 'pottery' );
    is( $establishment->{'manager_title'}, 'potter' );
    isnt( $establishment->{'manager_class'}, undef );
    isnt( $establishment->{'manager'}, undef );

    #print DUMPER $establishment; 
    
    is( $establishment->{'condition'},              'cluttered'      );
    is( $establishment->{'direction'},              'north'          ); 
    is( $establishment->{'enforcer'},               'local thugs'    ); 
    is( $establishment->{'graft'},                  'gives protection to'); 
    is( $establishment->{'manager_class'},          'expert'         ); 
    is( $establishment->{'manager_title'},          'potter'         ); 
    is( $establishment->{'name'},                   undef            );
    is( $establishment->{'neighborhood'},           'seedy'          ); 
    is( $establishment->{'occupants'},              undef            ); 
    is( $establishment->{'popularity_description'}, 'bummer'         ); 
    is( $establishment->{'price_description'},      'bummer'         ); 
    is( $establishment->{'reputation_description'}, 'bummer'         ); 
    is( $establishment->{'seed'},                   41630            ); 
    is( $establishment->{'service_type'},           'service'        ); 
    is( $establishment->{'size_description'},       'bummer'         ); 
    is( $establishment->{'storefront'},             'mud'            ); 
    is( $establishment->{'storeroof'},              'turf'           ); 
    is( $establishment->{'trailer'},                'inc.'           ); 
    is( $establishment->{'type'},                   'pottery'        );
    is( $establishment->{'windows'},                'small'          ); 
    
    
    $establishment = EstablishmentGenerator::create_establishment(
        {
            'seed'          => 41630,
            'type'          => 'pottery',
            'manager_class' => 'dogbert',
            'manager_title' => 'catbert',
        }
    );
    is( $establishment->{'seed'},                  41630 );
    is( $establishment->{'type'}, 'pottery' );
    is( $establishment->{'manager_title'}, 'catbert' );
    is( $establishment->{'manager_class'}, 'dogbert' );
    is( $establishment->{'manager'}->{'class'}, 'dogbert' );
    is( $establishment->{'manager'}->{'profession'}, 'catbert' );
    is( $establishment->{'manager'}->{'business'}, 'pottery' );

    done_testing();
};

subtest 'test generate_manager' => sub {
    my $establishment;

    $establishment = EstablishmentGenerator::create_establishment( { 'seed' => 22 } );
    is( $establishment->{'manager'}->{'race'}, 'drow' );

    $establishment = EstablishmentGenerator::create_establishment( { 'seed' => 22, 'manager' => { 'race' => 'ogre' } } );
    is( $establishment->{'manager'}->{'race'}, 'ogre' );

    done_testing();
};

1;

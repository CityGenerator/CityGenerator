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
    $establishment = EstablishmentGenerator::create_establishment( { 'seed' => 41630 } );
    is( $establishment->{'seed'}, 41630 );
    is( $establishment->{'name'}, 'Ruby Thug' );

    foreach my $stat (qw/ price popularity size reputation /) {
        cmp_ok( $establishment->{'stats'}->{$stat}, '<=', 100, "$stat max" );
        cmp_ok( $establishment->{'stats'}->{$stat}, '>=', 1,   "$stat min" );
    }


    $establishment = EstablishmentGenerator::create_establishment(
        {
            'seed'  => 41630,
            'name'  => 'test',
            'stats' => { 'price' => 11, 'popularity' => 11, 'size' => 11, 'reputation' => 11 }
        }
    );
    is( $establishment->{'seed'},                  41630 );
    is( $establishment->{'name'},                  'test' );
    is( $establishment->{'stats'}->{'price'},       11 );
    is( $establishment->{'stats'}->{'popularity'}, 11 );
    is( $establishment->{'stats'}->{'size'},       11 );
    is( $establishment->{'stats'}->{'reputation'}, 11 );


    done_testing();
};

subtest 'test generate_owner' => sub {
    my $establishment;

    $establishment = EstablishmentGenerator::create_establishment( { 'seed' => 22 } );
    is( $establishment->{'owner'}->{'race'}, 'dwarf' );

    $establishment = EstablishmentGenerator::create_establishment( { 'seed' => 22, 'owner' => { 'race' => 'ogre' } } );
    is( $establishment->{'owner'}->{'race'}, 'ogre' );

    done_testing();
};

1;

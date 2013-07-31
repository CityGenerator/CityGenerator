#!/usr/bin/perl -wT
###############################################################################
#
package TestContinentGenerator;

use strict;
use warnings;
use ContinentGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( set_seed );
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_continent' => sub {
    my $continent;
    $continent = ContinentGenerator::create_continent();
    isnt( $continent->{'seed'}, undef, "ensure seed is set" );

    $continent = ContinentGenerator::create_continent( { 'seed' => 12345 } );
    is( $continent->{'seed'}, 12300, 'ensure continent ID is stripped' );

    #FIXME need name testing
    $continent = ContinentGenerator::create_continent( { 'seed' => 12345, 'name' => 'test' } );
    is( $continent->{'name'}, 'test', 'ensure name is set' );

    done_testing();
};


1;


#!/usr/bin/perl -wT
###############################################################################
#
package TestWantedPosterGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use WantedPosterGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_wantedposter' => sub {
    my $wantedposter;

    $wantedposter = WantedPosterGenerator::create_wantedposter( );
    isnt( $wantedposter->{'seed'}, undef, 'ensure seed is set.' );


    $wantedposter = WantedPosterGenerator::create_wantedposter( { 'seed' => 12, } );
    is( $wantedposter->{'seed'}, 12, 'ensure seed is set.' );



    done_testing();
};

1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestMythGenerator;

use strict;
use warnings;

use Data::Dumper;
use Exporter;
use GenericGenerator qw( set_seed );
use MythGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_myth' => sub {
    my $myth;
    $myth = MythGenerator::create_myth();
    isnt( $myth->{'seed'}, undef, 'ensure seed is set' );

    $myth = MythGenerator::create_myth( { 'seed' => 12 } );
    is( $myth->{'seed'}, 12, 'ensure seed is set to 12' );


    done_testing();
};

1;

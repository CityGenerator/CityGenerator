#!/usr/bin/perl -wT
###############################################################################
#
package TestCuisineGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use CuisineGenerator;
use CityGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $cuisine;
    GenericGenerator::set_seed(2);
    $cuisine = CuisineGenerator::create( );
    isnt( $cuisine->{'seed'}, undef, 'ensure seed is set.' );

    $cuisine = CuisineGenerator::create( {'seed'=>1, });
    is( $cuisine->{'seed'},    1,    'ensure seed is set.' );

    subtest 'test create' => sub {

        $cuisine = CuisineGenerator::create( {'seed'=>1, 'sauce'=>'true'});
        is( $cuisine->{'seed'},    1,    'ensure seed is set.' );

        done_testing();
    };




    done_testing();
};

done_testing();
1;


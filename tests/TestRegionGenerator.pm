#!/usr/bin/perl -wT
###############################################################################
#
package TestRegionGenerator;

use strict;
use warnings;

use Data::Dumper;
use Exporter;
use GenericGenerator qw( set_seed );
use RegionGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $region;
    $region = RegionGenerator::create( { 'seed' => 41630 } );
    is( $region->{'seed'}, 41630, 'ensure seed is set' );
    is( $region->{'name'}, 'Conacania Province', 'ensure name is generated' );

    $region = RegionGenerator::create( { 'seed' => 12345, 'name' => 'test' } );
    is( $region->{'seed'}, 12345,  'ensure seed is trimmed' );
    is( $region->{'name'}, 'test', 'ensure name is set' );

    done_testing();
};

done_testing();

1;


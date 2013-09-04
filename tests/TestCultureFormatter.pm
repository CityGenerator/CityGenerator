#!/usr/bin/perl -wT
###############################################################################
#
package TestCultureFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use CultureFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'Test printLegends' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $culture = CultureFormatter::printLegends($city);
    isnt( $culture, undef, "make sure something is returned." );
    done_testing();
};

done_testing();
1;

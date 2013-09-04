#!/usr/bin/perl -wT
###############################################################################
#
package TestMapJSONFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use MapJSONFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test MapJSON' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $json = MapJSONFormatter::printCityMapJSON($city);
    like($json, '/"seed":1,/');
    
    done_testing();
};


done_testing();
1;

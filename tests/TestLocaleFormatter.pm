#!/usr/bin/perl -wT
###############################################################################
#
package TestLocaleFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use LocaleFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Locale' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    #my $locale = LocaleFormatter::printSummary($city);
    is(1,1, "FIXME");
    #like( $locale, "/.+ is governed through a.+, where .+\. \nThe government as a whole is seen as .+\. \nOfficials in .+ are often seen as .+ and the policies are .+\. \nThe political influence of .+ in the region is .+ due to .+\. \nIn times of crisis, the population .+\. /", 'ensure that summary is formatted properly.');
    done_testing();
};


done_testing();
1;

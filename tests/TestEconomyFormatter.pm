#!/usr/bin/perl -wT
###############################################################################
#
package TestEconomyFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use EconomyFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Economy' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $economy = EconomyFormatter::printSummary($city);
    like($economy, "/The economy in .+ is currently .+\./");
    #like( $economy, "/.+ is governed through a.+, where .+\. \nThe government as a whole is seen as .+\. \nOfficials in .+ are often seen as .+ and the policies are .+\. \nThe political influence of .+ in the region is .+ due to .+\. \nIn times of crisis, the population .+\. /", 'ensure that summary is formatted properly.');
    done_testing();
};


done_testing();
1;

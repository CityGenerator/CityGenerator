#!/usr/bin/perl -wT
###############################################################################
#
package TestPeopleFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use PeopleFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test People' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $people = PeopleFormatter::printSummary($city);
    like($people, "/The people in .+ .+ outsiders\./");
    #like( $people, "/.+ is governed through a.+, where .+\. \nThe government as a whole is seen as .+\. \nOfficials in .+ are often seen as .+ and the policies are .+\. \nThe political influence of .+ in the region is .+ due to .+\. \nIn times of crisis, the population .+\. /", 'ensure that summary is formatted properly.');
    done_testing();
};

done_testing();
1;

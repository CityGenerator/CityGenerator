#!/usr/bin/perl -wT
###############################################################################
#
package TestGovtFormatter;

use strict;
use warnings;
use Test::More;
use GovtFormatter;
use CityGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Govt' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $govt=GovtFormatter::printSummary($city);
    is($govt, 
            "Grisnow is governed through a totalitarian government, where the government subordinates individuals by controlling all political and economic matters, as well as the attitudes, values, and beliefs. ".
            "The government as a whole is seen as shrewd. ".
            "Officials in Grisnow are often seen as the epitome corruption and the policies are mocked. ".
            "The political influence of Grisnow in the region is receding due to riots in the region. ".
            "In times of crisis, the population squabbles amongst themselves. "
    );
    done_testing();
};

subtest 'Test Govt Crime' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $crime=GovtFormatter::printCrime($city);
    is($crime, 
        "Crime is rampant. \n".
        "The most common crime is murder. \n".
        "The imprisonment made is 0.00 of the population (0 adults). \n"
    );
    done_testing();
};

1;

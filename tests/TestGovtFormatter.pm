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
    my $govt=GovtFormatter::printGovt($city);
    is($govt, "Grisnow is ruled a much loved cult leader. Within the city there is a a dragon that quietly denounces current leadership. The population approves of cult leader policies in general.");
    done_testing();
};

subtest 'Test Govt Crime' => sub {
    my $city=CityGenerator::create_city({seed=>1});
    CityGenerator::flesh_out_city($city);
    my $crime=GovtFormatter::printCrime($city);
    is($crime, "Crime is rampant. Laws are enforced by a city watch. Justice is served by by a magistrate, with a common punishment being fines. The most common crime is murder. The imprisonment rate is 0% of the population (0 adult[s]).");
    done_testing();
};

1;

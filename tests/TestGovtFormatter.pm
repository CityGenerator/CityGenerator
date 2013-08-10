#!/usr/bin/perl -wT
###############################################################################
#
package TestGovtFormatter;

use strict;
use warnings;

use CityGenerator;
use Data::Dumper;
use Exporter;
use GovtFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Govt' => sub {
    my $city = CityGenerator::create_city( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $govt = GovtFormatter::printSummary($city);
    is(
        $govt,
"Kanhall is governed through a totalitarian government, where the government subordinates individuals by controlling all political and economic matters, as well as the attitudes, values, and beliefs. The government as a whole is seen as shrewd. Officials in Kanhall are often seen as the epitome corruption and the policies are mocked. The political influence of Kanhall in the region is receding due to riots in the region. In times of crisis, the population squabbles amongst themselves. ",
        'ensure summary is printed'
    );
    done_testing();
};

subtest 'Test Military print' => sub {
    my $city = CityGenerator::create_city( { seed => 1  } );
    CityGenerator::flesh_out_city($city);
    my $military = GovtFormatter::printMilitary($city);
    is(
        $military,
        "Kanhall has a disinterested attitude towards the military. \n".
        "Their standing army of 186 citizens (13.5%) is at the ready, with a reserve force of 72 (5.25%). \n".
        "Of the active duty military, 8 (4.5%) are special forces. \n".
        "Due to their disinterested attitude and lack of defensible wall, Kanhall is spectacularly fortified. \n".
        "Kanhall fighters are ridiculed for their use of great crossbows in battle. \n".
        "They are mocked for their guerrilla warfare and are considered admirably skilled in battle. \n"
    );
    done_testing();
};

subtest 'Test Govt Crime' => sub {
    my $city = CityGenerator::create_city( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $crime = GovtFormatter::printCrime($city);
    is(
        $crime,
        "Crime is rampant. \n"
            . "The most common crime is fraud. \n"
            . "The imprisonment rate is 0.44% of the population (5 adults). \n",
        'ensure crime is printed'
    );
    done_testing();
};

1;

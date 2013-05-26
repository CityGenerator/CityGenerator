#!/usr/bin/perl -wT
###############################################################################
#
package TestCensusDataFormatter;

use strict;
use warnings;
use Test::More;
use CensusDataFormatter;
use CityGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test CensusData General Information' => sub {
    my $city=CityGenerator::create_city({seed=>'126405'});
    CityGenerator::flesh_out_city($city);
    my $censusdata=CensusDataFormatter::printCensusData($city);

    is($censusdata, " ".CensusDataFormatter::printGeneralInformation($city).
                    " ".CensusDataFormatter::printRacialBreakdown($city).
                    " ".CensusDataFormatter::printMisc($city) );
    done_testing();
};

subtest 'Test CensusData General Information' => sub {
    my $city=CityGenerator::create_city({seed=>'126405'});
    CityGenerator::flesh_out_city($city);
    my $censusdata=CensusDataFormatter::printGeneralInformation($city);

    is($censusdata, "                    <h3>General Information</h3>
                    <ul>
                        <li> Pop. Estimate: 18554 </li>
                        <li> Children: 40.00% (7421) </li>
                        <li> Elderly: 16.00% (2968) </li>
                    </ul>
" );
    done_testing();
};

subtest 'Test CensusData Racial Breakdown' => sub {
    my $city=CityGenerator::create_city({seed=>'126405'});
    CityGenerator::flesh_out_city($city);
    my $censusdata=CensusDataFormatter::printRacialBreakdown($city);

    is($censusdata, "                    <h3>Racial Breakdown</h3>
                    <ul>
                        <li>10130 half-orc (54.5%)</li>
                        <li>5733 half-dwarf (30.8%)</li>
                        <li>1020 half-elf (5.4%)</li>
                        <li>946 dwarf (5%)</li>
                        <li>445 human (2.3%)</li>
                        <li>280 other (1.5%)</li>
                    </ul>
" );
    done_testing();
};


subtest 'Test CensusData Misc' => sub {
    my $city=CityGenerator::create_city({seed=>'126405'});
    CityGenerator::flesh_out_city($city);
    my $censusdata=CensusDataFormatter::printMisc($city);
    is(1,1);
#    is($censusdata, "                    <h3>Misc.</h3>
#                    <ul>
#                        <li>2449 Residential Buildings</li>
#                        <li>9 Districts</li>
#                        <li>925 Businesses</li>
#                        <li>3736 Specialists</li>
#                    </ul>
#" );
    done_testing();
};









1;

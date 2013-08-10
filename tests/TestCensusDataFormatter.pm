#!/usr/bin/perl -wT
###############################################################################
#
package TestCensusDataFormatter;

use strict;
use warnings;

use CensusDataFormatter;
use CityGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test CensusData General Information' => sub {
    my $city = CityGenerator::create_city( { seed => '126405' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printCensusData($city);

    is( $censusdata,
              " "
            . CensusDataFormatter::printGeneralInformation($city) . " "
            . CensusDataFormatter::printRacialBreakdown($city) . " "
            . CensusDataFormatter::printMisc($city) );
    done_testing();
};

subtest 'Test CensusData General Information' => sub {
    my $city = CityGenerator::create_city( { seed => '126405' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printGeneralInformation($city);

    is(
        $censusdata, "                    <h3>General Information</h3>
                    <ul>
                        <li> Pop. Estimate: 833 </li>
                        <li> Children: 28.93% (241) </li>
                        <li> Elderly: 11.88% (99) </li>
                    </ul>
"
    );
    done_testing();
};

subtest 'Test CensusData Racial Breakdown' => sub {
    my $city = CityGenerator::create_city( { seed => '126405' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printRacialBreakdown($city);
    is(
        $censusdata, "                    <h3>Racial Breakdown</h3>
                    <ul>
                        <li>644 half-dwarf (77.3%)</li>
                        <li>160 halfling (19.2%)</li>
                        <li>28 half-orc (3.3%)</li>
                        <li>1 other (0.1%)</li>
                    </ul>
"
    );
    done_testing();
};


subtest 'Test CensusData Misc' => sub {
    my $city = CityGenerator::create_city( { seed => '126405' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printMisc($city);
    is( 1, 1 );
    is(
        $censusdata, "                    <h3>Misc.</h3>
                    <ul>
                        <li>4 Districts</li>
                        <li>40 Businesses</li>
                        <li>70 Specialists</li>
                        <li>107 Residences</li>
                    </ul>
"
    );
    done_testing();
};


1;

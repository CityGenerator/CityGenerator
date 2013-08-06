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
                        <li> Pop. Estimate: 18,554 </li>
                        <li> Children: 25.00% (4,638) </li>
                        <li> Elderly: 1.50% (278) </li>
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
                        <li>17,367 ogre (93.6%)</li>
                        <li>594 drow (3.2%)</li>
                        <li>220 other (1.1%)</li>
                        <li>186 minotaur (1%)</li>
                        <li>186 bugbear (1%)</li>
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
                        <li>7 Districts</li>
                        <li>352 Businesses</li>
                        <li>2,838 Specialists</li>
                        <li>1,884 Residences</li>
                    </ul>
"
    );
    done_testing();
};


1;

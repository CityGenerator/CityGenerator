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
    my $city = CityGenerator::create_city( { seed => '1' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printGeneralInformation($city);

    like(
        $censusdata, 
        "/<h3>.*<\/h3>
                    <ul>
                        <li> Pop. Estimate: .*<\/li>
                        <li> Children: .*% \(.*\) <\/li>
                        <li> Elderly: .*% \(.*\) <\/li>
                    <\/ul>/"
    );
    done_testing();
};

subtest 'Test CensusData Racial Breakdown' => sub {
    my $city = CityGenerator::create_city( { seed => '126405' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printRacialBreakdown($city);
    like(
        $censusdata, 
        "/<h3>Racial Breakdown<\/h3>
                    <ul>
                        <li>.* \\(.*%\\)<\/li>/"
    );
    done_testing();
};


subtest 'Test CensusData Misc' => sub {
    my $city = CityGenerator::create_city( { seed => '126405' } );
    CityGenerator::flesh_out_city($city);
    my $censusdata = CensusDataFormatter::printMisc($city);
    like(
        $censusdata,
        "/<h3>Misc.<\/h3>
                    <ul>
                        <li>.* Districts?<\/li>
                        <li>.* Businesses?<\/li>
                        <li>.* Specialists?<\/li>
                        <li>.* Residences?<\/li>
                    <\/ul>/"
    );
    done_testing();
};


1;

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
    like( $military, '/attitude towards the military/', 'make sure base text is returned'    );

    $city = CityGenerator::create_city( { seed => 1, 'tactics'=>{'content'=>'foo' }  } );
    CityGenerator::flesh_out_city($city);
    $city->{'walls'}->{'condition'}="some value" ;
    $military = GovtFormatter::printMilitary($city);
    like( $military, '/some value/', 'make sure some value is found'    );
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

subtest 'Test Govt Leader' => sub {
    my $city = CityGenerator::create_city( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $text = GovtFormatter::printLeader($city);
    like( $text, '/has been in power/', 'leader returns text'    );

    delete $city->{'govt'}->{'leader'}->{'name'};
    $text = GovtFormatter::printLeader($city);
    like( $text, "/is ruled by The $city->{'govt'}->{'leader'}->{'title'}./", 'leader returns Title text'    );

    done_testing();
};

subtest 'Test Govt laws' => sub {
    my $city = CityGenerator::create_city( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $text = GovtFormatter::printLaw($city);
    like( $text, '/Laws are enforced by/', 'leader returns text'    );

    done_testing();
};



1;

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
    like(
        $govt,
            "/.* is governed through a .*, where .* The government as a whole is seen as .* Officials in .* are often seen as .* and the policies are .* The political influence of .* in the region is .* In times of crisis, the population .*/",
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
    $city->{'walls'}->{'style'}="foo" ;
    $military = GovtFormatter::printMilitary($city);
    like( $military, '/some value/', 'make sure some value is found'    );
    done_testing();
};

subtest 'Test Govt Crime' => sub {
    my $city = CityGenerator::create_city( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $crime = GovtFormatter::printCrime($city);
    like(        $crime,         "/Crime is /",  'ensure crime is printed'    );
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

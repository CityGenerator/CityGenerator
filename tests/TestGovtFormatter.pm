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
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $govt = GovtFormatter::printSummary($city);
    like( $govt, "/.+ is governed through a.+, where .+\. \nThe government as a whole is seen as .+\. \nOfficials in .+ are often seen as .+ and the policies are .+\. \nThe political influence of .+ in the region is .+ due to .+\. \nIn times of crisis, the population .+\. /", 'ensure that summary is formatted properly.');
    done_testing();
};

subtest 'Test Military print' => sub {
    my $city = CityGenerator::create( { seed => 1  } );
    CityGenerator::flesh_out_city($city);
    my $military = GovtFormatter::printMilitary($city);

    like ($military,
        "/.+ has a.+ attitude towards the military. \nTheir standing army of .+ citizens [(].+%[)] is at the ready, with a reserve force of .+ [(].+%[)]. \nOf the active duty military, .+ [(].+%[)] are special forces. \n/");
    like ($military,
        "/Due to their .+ attitude and .+, .+ is .+ fortified. \n.+ fighters are .+ for their use of .+ in battle. \nThey are .+ for their .+ and are considered .+ skilled in battle. \n/");

    
    subtest 'Test Military walls' => sub {
        $city->{'walls'}->{'condition'}="red";
        $city->{'walls'}->{'style'}="blue";
        $military = GovtFormatter::printMilitary($city);
        like ($military, "/red blue/");

        $city->{'walls'}->{'condition'}=undef;
        $city->{'walls'}->{'style'}="blue";
        $military = GovtFormatter::printMilitary($city);
        like ($military, "/lack of defensible wall/");

        $city->{'walls'}->{'condition'}="red";
        $city->{'walls'}->{'style'}=undef;
        $military = GovtFormatter::printMilitary($city);
        like ($military, "/lack of defensible wall/");

        $city->{'walls'}->{'condition'}=undef;
        $city->{'walls'}->{'style'}=undef;
        $military = GovtFormatter::printMilitary($city);
        like ($military, "/lack of defensible wall/");
    };

    done_testing();
};

subtest 'Test Govt Crime' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $crime = GovtFormatter::printCrime($city);
    like( $crime, "/Crime is .+\. \nThe most common crime is .+\. \nThe imprisonment rate is .+% of the population [(].+ adults?[)]. /");

    done_testing();
};

subtest 'Test Govt Leader' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $text = GovtFormatter::printLeader($city);
    like($text, "/The .+ has been in power .+ and is .+ by the people\. \nThere is .+ opposition to the .+ and policies\. \nThe right to rule was granted .+, and that power is maintained .+\. \n/");

    delete $city->{'govt'}->{'leader'}->{'name'};
    $text = GovtFormatter::printLeader($city);
    like($text, "/.+ is ruled by The .+\. /", "make sure it says 'The boss'" );

    $city->{'govt'}->{'leader'}->{'name'}="Bob";
    $text = GovtFormatter::printLeader($city);
    like($text, "/.+ is ruled by .+ Bob\. /", "make sure it says 'Bob'" );

    done_testing();
};

subtest 'Test Govt laws' => sub {
    my $city = CityGenerator::create( { seed => 1 } );
    CityGenerator::flesh_out_city($city);
    my $text = GovtFormatter::printLaw($city);
    like( $text, "/Laws are enforced by a.+, .+\. \nJustice is served .+, with a common punishment being .+\. \n/");

    done_testing();
};



1;

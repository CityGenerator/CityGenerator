#!/usr/bin/perl -wT
###############################################################################
#
package TestWorldFormatter;

use strict;
use warnings;
use Test::More;
use WorldFormatter;
use WorldGenerator;

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test World Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1});
    my $summary=WorldFormatter::printSummary($world);
    is($summary, 
                "Merrth is a average, mild planet orbiting a binary star. ".
                "Merrth has a double moon, a fragile green atmosphere and fresh water is common. ".
                "The surface of the planet is 50% covered by water. "
    );
    done_testing();
};

subtest 'Test World Sky Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Merrth orbits a single star: Tol, an average yellow star. ".
                "Merrth also has no moons. ".
                "In the night sky, you see nothing unusual. ".
                "During the day, the sky is green. "
    );

    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>31, 'celestial_roll'=>31 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Merrth orbits a single star: Tol, an average yellow star. ".
                "Merrth also has a single moon: Moladus, a small dull brown moon. ".
                "In the night sky, you see a celestial object: a miniscule nearby planet that has been around for generations. ".
                "During the day, the sky is green. "
    );


    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>71, 'moons_roll'=>71, 'celestial_roll'=>61 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Merrth orbits a binary star: Tol, an average yellow star and Krok, an average blue star. ".
                "Merrth also has a double moon: Moladus, a small dull brown moon and Spolepso, a massive light blue moon. ".
                "In the night sky, you see two celestial objects: a miniscule nearby planet that has been around for generations and a massive black hole that has been around for decades. ".
                "During the day, the sky is green. "
    );


    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>97, 'moons_roll'=>96, 'celestial_roll'=>93 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Merrth orbits a trinary star: Tol, an average yellow star; Krok, an average blue star; and Bek, an average yellow star. ".
                "Merrth also has a triple moon: Moladus, a small dull brown moon; Spolepso, a massive light blue moon; and Charo, a large briliant silver moon. ".
                "In the night sky, you see three celestial objects: a miniscule nearby planet that has been around for generations, a massive black hole that has been around for decades, and a massive supernova that has been around for all eternity. ".
                "During the day, the sky is green. " 
    );

    done_testing();
};


subtest 'Test World Land Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printLandSummary($world);
    is($summary, 
                "Merrth is 553,296,763 square kilometers (with a circumfrence of 41,688 kilometers). ".
                "Surface water is common, covering 50% of the planet. ".
                "Around 37% of the planet's water is fresh water. ".
                "The crust is split into 18 plates, resulting in 6 continents. "
    );

    done_testing();
};


subtest 'Test World Weather Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printWeatherSummary($world);
    is($summary, 
                "While Merrth has a reasonable amount of variation, the overall climate is mild. ".
                "Small storms are rare, precipitation is excessive, the atmosphere is fragile and clouds are plentiful. "
    );

    done_testing();
};






1;

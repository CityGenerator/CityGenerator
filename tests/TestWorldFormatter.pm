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
                "Manus is a large, hot planet orbiting a single star. ".
                "Manus has a no moons, a meager murky atmosphere and fresh water is plentiful. ".
                "The surface of the planet is 80% covered by water. "
    );
    done_testing();
};

subtest 'Test World Sky Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printSkySummary($world);
    is($summary,
                "Manus orbits a single star: Uuc, a massive blue star. ".
                "Manus also has no moons. ".
                "In the night sky, you see nothing unusual. ".
                "During the day, the sky is murky, which is partially due to clouds. "
    );

    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>31, 'celestial_roll'=>31 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Manus orbits a single star: Uuc, a massive blue star. ".
                "Manus also has a single moon: Phota, a large light blue moon. ".
                "In the night sky, you see a celestial object: a massive galaxy that has been around for generations. ".
                "During the day, the sky is murky, which is partially due to clouds. "
    );


    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>71, 'moons_roll'=>71, 'celestial_roll'=>61 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary,
                "Manus orbits a binary star: Uuc, a massive blue star and Luj, a supermassive yellow star. ".
                "Manus also has a double moon: Phota, a large light blue moon and Deimeke, a large briliant silver moon. ".
                "In the night sky, you see two celestial objects: a massive galaxy that has been around for generations and a massive asteroid belt that has been around for decades. ".
                "During the day, the sky is murky, which is partially due to clouds. "
    );


    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>97, 'moons_roll'=>96, 'celestial_roll'=>93 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Manus orbits a trinary star: Uuc, a massive blue star; Luj, a supermassive yellow star; and Mel, an average red star. ".
                "Manus also has a triple moon: Phota, a large light blue moon; Deimeke, a large briliant silver moon; and Prokalite, an average bone white moon. ".
                "In the night sky, you see three celestial objects: a massive galaxy that has been around for generations, a massive asteroid belt that has been around for decades, and an imposing nearby planet that has been around for all eternity. ".
                "During the day, the sky is murky, which is partially due to clouds. "
    );

    done_testing();
};


subtest 'Test World Land Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printLandSummary($world);
    is($summary,
                "Manus is 1,016,774,107 square kilometers (with a circumfrence of 56,517 kilometers). ".
                "Surface water is plentiful, covering 80% of the planet. ".
                "Around 67% of the planet's water is fresh water. ".
                "The crust is split into 8 plates, resulting in 2 continents. " 
    );

    done_testing();
};


subtest 'Test World Weather Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printWeatherSummary($world);
    is($summary, 
                "While Manus has a reasonable amount of variation, the overall climate is hot. ".
                "Small storms are common, precipitation is rare, the atmosphere is meager and clouds are rare. "
    );

    done_testing();
};


subtest 'Test World Data Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>60, 'celestial_roll'=>60 });
    my $summary=WorldFormatter::printWorldDataSummary($world);
    is($summary,"
    <ul>
        <li>Stars: 1</li>
        <li>Moons: 1</li>
        <li>Celestial Objects: 1</li>
        <li>Weather: hot</li>
        <li>Sky: murky</li>
        <li>Size: large</li>
        <li>Year: 355 days</li>
        <li>Day: 30 hours</li>
        <li>Oceans: 80%</li>
        <li>Fresh water: plentiful</li>
    </ul>" 
    );

    done_testing();
};





1;

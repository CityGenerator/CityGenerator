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
                "Macurto is a large, warm planet orbiting a single star.\n".
                "Macurto has a no moons, a fragile brown atmosphere and fresh water is common.\n".
                "The surface of the planet is 27% covered by water.\n"
    );
    done_testing();
};

subtest 'Test World Sky Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printSkySummary($world);
    is($summary,
                "Macurto orbits a single star: Mec, a large blue star.\n".
                "Macurto also has no moons.\n".
                "In the night sky, you see nothing unusual.\n".
                "During the day, the sky is brown, which is partially due to pollution.\n"
    );

    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>31, 'celestial_roll'=>31 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary,
                "Macurto orbits a single star: Mec, a large blue star.\n".
                "Macurto also has a single moon: Ganamelite, a large dull brown moon.\n".
                "In the night sky, you see a celestial object: an imposing asteroid belt that has been around for centuries.\n".
                "During the day, the sky is brown, which is partially due to pollution.\n"
    );


    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>71, 'moons_roll'=>71, 'celestial_roll'=>61 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary,
                "Macurto orbits a binary star: Mec, a large blue star and Naj, a massive yellow star.\n".
                "Macurto also has a double moon: Ganamelite, a large dull brown moon and Deikadene, an average light blue moon.\n".
                "In the night sky, you see two celestial objects: an imposing asteroid belt that has been around for centuries and an imposing black hole that has been around for only a few years.\n".
                "During the day, the sky is brown, which is partially due to pollution.\n"
    );


    $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>97, 'moons_roll'=>96, 'celestial_roll'=>93 });
    $summary=WorldFormatter::printSkySummary($world);
    is($summary, 
                "Macurto orbits a trinary star: Mec, a large blue star; Naj, a massive yellow star; and Tol, a small red star.\n".
                "Macurto also has a triple moon: Ganamelite, a large dull brown moon; Deikadene, an average light blue moon; and Modo, an average briliant silver moon.\n".
                "In the night sky, you see three celestial objects: an imposing asteroid belt that has been around for centuries, an imposing black hole that has been around for only a few years, and a tiny supernova that has been around for time immemorial.\n".
                "During the day, the sky is brown, which is partially due to pollution.\n"

    );

    done_testing();
};


subtest 'Test World Land Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printLandSummary($world);
    is($summary,
                "Macurto is 760,399,542 square kilometers (with a circumfrence of 48,870 kilometers).\n".
                "Surface water is rare, covering 27% of the planet.\n".
                "Around 52% of the planet's water is fresh water.\n".
                "The crust is split into 8 plates, resulting in 2 continents.\n"
    );

    done_testing();
};


subtest 'Test World Weather Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>0, 'celestial_roll'=>0 });
    my $summary=WorldFormatter::printWeatherSummary($world);
    is($summary,
                "While Macurto has a reasonable amount of variation, the overall climate is warm.\n".
                "Small storms are common, precipitation is rare, the atmosphere is fragile and clouds are scarce.\n"
 
    );

    done_testing();
};


subtest 'Test World Data Summary' => sub {
    my $world=WorldGenerator::create_world({seed=>1, 'starsystem_roll'=>1, 'moons_roll'=>60, 'celestial_roll'=>60 });
    my $summary=WorldFormatter::printWorldDataSummary($world);
    is($summary,"    <ul>
        <li>Stars: 1</li>
        <li>Moons: 1</li>
        <li>Celestial Objects: 1</li>
        <li>Weather: warm</li>
        <li>Sky: brown</li>
        <li>Size: large</li>
        <li>Year: 188 days</li>
        <li>Day: 24 hours</li>
        <li>Oceans: 27%</li>
        <li>Fresh water: common</li>
    </ul>
" 
    );

    done_testing();
};





1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestWorldFormatter;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use WorldFormatter;
use WorldGenerator;
use AstronomyGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'Test World Summary' => sub {
    my $astro = AstronomyGenerator::create( { seed => 1 } );
    my $world = WorldGenerator::create( { seed => 1, 'astronomy' => $astro } );
    my $summary = WorldFormatter::printSummary($world);
    is( $summary,
              "Macurto is a large, warm planet orbiting a single star.\n"
            . "Macurto has a single moon, a fragile brown atmosphere and fresh water is common.\n"
            . "The surface of the planet is 27% covered by water.\n" );
    done_testing();
};

subtest 'Test World Sky Summary' => sub {
    my $astro = AstronomyGenerator::create(
        { seed => 1, 'starsystem_roll' => 1, 'moons_roll' => 1, 'celestial_roll' => 1 } );
    my $world = WorldGenerator::create( { seed => 1, 'astronomy' => $astro } );
    my $summary = WorldFormatter::printSkySummary($world);
    is(
        $summary,

        "Macurto orbits a single star: Bek, an average orange star.\n"
            . "Macurto also has no moons.\n"
            . "In the night sky, you see nothing unusual.\n"
            . "During the day, the sky is brown, which is partially due to pollution.\n"
    );

    $astro = AstronomyGenerator::create(
        { seed => 1, 'starsystem_roll' => 1, 'moons_roll' => 31, 'celestial_roll' => 31 } );
    $world = WorldGenerator::create( { seed => 1, 'astronomy' => $astro } );
    $summary = WorldFormatter::printSkySummary($world);
    is( $summary,
              "Macurto orbits a single star: Bek, an average orange star.\n"
            . "Macurto also has a single moon: Chale, an average pale yellow moon.\n"
            . "In the night sky, you see a celestial object: a miniscule asteroid belt that has been around for decades.\n"
            . "During the day, the sky is brown, which is partially due to pollution.\n" );


    $astro = AstronomyGenerator::create(
        { seed => 1, 'starsystem_roll' => 71, 'moons_roll' => 71, 'celestial_roll' => 61 } );
    $world = WorldGenerator::create( { seed => 1, 'astronomy' => $astro } );
    $summary = WorldFormatter::printSkySummary($world);
    is( $summary,
              "Macurto orbits a binary star: Bek, an average orange star and Abar, an average white star.\n"
            . "Macurto also has a double moon: Chale, an average pale yellow moon and Sinoropso, a small rusty red moon.\n"
            . "In the night sky, you see two celestial objects: a miniscule asteroid belt that has been around for decades and a miniscule black hole that has been around for all eternity.\n"
            . "During the day, the sky is brown, which is partially due to pollution.\n" );


    $astro = AstronomyGenerator::create(
        { seed => 1, 'starsystem_roll' => 97, 'moons_roll' => 96, 'celestial_roll' => 93 } );
    $world = WorldGenerator::create( { seed => 1, 'astronomy' => $astro } );
    $summary = WorldFormatter::printSkySummary($world);
    is(
        $summary,
"Macurto orbits a trinary star: Bek, an average orange star; Abar, an average white star; and Lur, an average yellow star.\n"
            . "Macurto also has a triple moon: Chale, an average pale yellow moon; Sinoropso, a small rusty red moon; and Eladi, a supermassive light blue moon.\n"
            . "In the night sky, you see three celestial objects: a miniscule asteroid belt that has been around for decades, a miniscule black hole that has been around for all eternity, and a massive supernova that has been around for millenia.\n"
            . "During the day, the sky is brown, which is partially due to pollution.\n"

    );

    done_testing();
};


subtest 'Test World Land Summary' => sub {

    my $world = WorldGenerator::create( { seed => 1, } );
    my $summary = WorldFormatter::printLandSummary($world);
    is( $summary,
              "Macurto is 760,399,542 square kilometers (with a circumference of 48,870 kilometers).\n"
            . "Surface water is rare, covering 27% of the planet.\n"
            . "Around 52% of the planet's water is fresh water.\n"
            . "The crust is split into 8 plates, resulting in 2 continents.\n" );

    done_testing();
};


subtest 'Test World Weather Summary' => sub {
    my $world = WorldGenerator::create( { seed => 1, } );
    my $summary = WorldFormatter::printWeatherSummary($world);
    is(
        $summary,
        "While Macurto has a reasonable amount of variation, the overall climate is warm.\n"
            . "Small storms are common, precipitation is rare, the atmosphere is fragile and clouds are scarce.\n"

    );

    done_testing();
};


subtest 'Test World Data Summary' => sub {
    my $world = WorldGenerator::create( { seed => 1, } );
    my $summary = WorldFormatter::printWorldDataSummary($world);
    is(
        $summary, "    <ul>
        <li>Stars: 1</li>
        <li>Moons: 1</li>
        <li>Celestial Objects: 0</li>
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


done_testing();
1;

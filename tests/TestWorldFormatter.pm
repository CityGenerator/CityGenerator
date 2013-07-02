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


subtest 'Test World' => sub {
    my $world=WorldGenerator::create_world({seed=>1});

    my $summary=WorldFormatter::printSummary($world);
    is($summary, "Merrth is a tiny, unbearably cold planet orbiting a single star. Merrth has a no moons, a fresh blue atmosphere and fresh water is scarce. The surface of the planet is 5% covered by water. " );

    done_testing();
};

1;

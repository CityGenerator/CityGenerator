#!/usr/bin/perl -wT
###############################################################################
#
package TestAdventureGenerator;

use strict;
use warnings;
use Test::More;
use AdventureGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test generate_adventure' => sub {
    my $adventure;

    $adventure=AdventureGenerator::generate_name({'seed'=>1});
    is($adventure->{'namepattern'},"VERB SUBJECT");
    is($adventure->{'name'},"Evenly Choke a Degenerate Knife");

    $adventure=AdventureGenerator::generate_name({'seed'=>2});
    is($adventure->{'namepattern'},"VERB.gerund SUBJECT");
    is($adventure->{'name'},"Partially Swinging an Overlooked Danger");


    done_testing();
};

1;

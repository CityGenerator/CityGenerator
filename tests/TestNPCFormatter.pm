#!/usr/bin/perl -wT
###############################################################################
#
package TestNPCFormatter;

use strict;
use warnings;

use NPCGenerator;
use Data::Dumper;
use Exporter;
use NPCFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test NPC' => sub {
    my $npc = NPCGenerator::create( { seed => 1 } );
    my $npctext = NPCFormatter::printSummary($npc);
    like($npctext, "/.+ is .+ .+ who is .+ .+ by trade. \n/");
    #like( $npc, "/.+ is governed through a.+, where .+\. \nThe government as a whole is seen as .+\. \nOfficials in .+ are often seen as .+ and the policies are .+\. \nThe political influence of .+ in the region is .+ due to .+\. \nIn times of crisis, the population .+\. /", 'ensure that summary is formatted properly.');
    done_testing();
};

done_testing();
1;

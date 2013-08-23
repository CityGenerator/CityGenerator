#!/usr/bin/perl -wT
###############################################################################
#
package TestWantedPosterGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use WantedPosterGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_wantedposter' => sub {
    my $wantedposter;

    $wantedposter = WantedPosterGenerator::create_wantedposter( );
    isnt( $wantedposter->{'seed'}, undef, 'ensure seed is set.' );

    my $npc=NPCGenerator::create_npc({'seed'=>1});
    $wantedposter = WantedPosterGenerator::create_wantedposter( { 'seed' => 12, 'npc'=>$npc, 'acceptable_locations'=>[{'content'=>'foo'},{'content'=>'bar'},]  } );

    is( $wantedposter->{'seed'}, 12, 'ensure seed is set.' );
    is($wantedposter->{'npc'}->{'name'}, $npc->{'name'}, 'NPC is the value passed in');


    $wantedposter = WantedPosterGenerator::create_wantedposter( { 'seed' => 12, 'npc'=>$npc, 'lastseen'=>'baz'  } );

    is( $wantedposter->{'seed'}, 12, 'ensure seed is set.' );
    is($wantedposter->{'lastseen'}, 'baz', 'baz is preset');



    done_testing();
};

1;

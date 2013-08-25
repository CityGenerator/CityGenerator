#!/usr/bin/perl -wT
###############################################################################
#
package TestLegendGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use LegendGenerator;
use CityGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $legend;
    GenericGenerator::set_seed(2);
    $legend = LegendGenerator::create( );
    isnt( $legend->{'seed'}, undef, 'ensure seed is set.' );

    my $npc=NPCGenerator::create();
    my $location=CityGenerator::generate_city_name({ 'seed'=>$legend->{'seed'}} );
    $legend = LegendGenerator::create( {'seed'=>1, 'npc'=>$npc, 'villain'=>$npc, 'location'=>$location});
    is( $legend->{'seed'},    1,    'ensure seed is set.' );
    is( $legend->{'npc'},     $npc, 'ensure hero is set.' );
    is( $legend->{'villain'}, $npc, 'ensure villain is set.' );



    done_testing();
};


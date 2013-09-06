#!/usr/bin/perl -wT
###############################################################################
#
package TestCritterGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use CritterGenerator;
use CityGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $critter;
    GenericGenerator::set_seed(2);
    $critter = CritterGenerator::create( );
    isnt( $critter->{'seed'}, undef, 'ensure seed is set.' );

    $critter = CritterGenerator::create( {'seed'=>1,});
    is( $critter->{'seed'}, 1, 'ensure seed is set.' );

    $critter = CritterGenerator::create( {'seed'=>1, 'npc'=>{'firstname'=>'Joe'}});
    is( $critter->{'seed'}, 1, 'ensure seed is set.' );
    is($critter->{'npc'}->{'firstname'}, 'Joe');
    done_testing();
};

done_testing();
1;

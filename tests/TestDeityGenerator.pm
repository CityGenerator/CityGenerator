#!/usr/bin/perl -wT
###############################################################################
#
package TestDeityGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use DeityGenerator;
use CityGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $deity;
    GenericGenerator::set_seed(2);
    $deity = DeityGenerator::create( );
    isnt( $deity->{'seed'}, undef, 'ensure seed is set.' );

    $deity = DeityGenerator::create( {'seed'=>1, 'holy symbol'=>'spoon', 'worst_stat'=>'strength', 'best_stat'=>'wisdom', 'portfolio_value'=>7});
    is( $deity->{'seed'}, 1, 'ensure seed is set.' );
    is( $deity->{'holy symbol'}, 'spoon', 'Make Tick Happy.' );
    is( $deity->{'best_stat'}, 'wisdom', 'test wisdom.' );
    is( $deity->{'worst_stat'}, 'strength', 'test strength.' );

    $deity = DeityGenerator::create( {'seed'=>1, 'holy symbol'=>'spoon', 'portfolio_value'=>1, 'portfolio'=>['peanuts'] });
    is( $deity->{'seed'}, 1, 'ensure seed is set.' );

    done_testing();
};

done_testing();
1;

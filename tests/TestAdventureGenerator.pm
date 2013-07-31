#!/usr/bin/perl -wT
###############################################################################
#
package TestAdventureGenerator;

use strict;
use warnings;
use AdventureGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( set_seed );

use Test::More;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_city generate_city_name);


subtest 'test generate_adventure ' => sub {
    my $adventure;

    $adventure = AdventureGenerator::create_adventure();

    $adventure = AdventureGenerator::create_adventure( { 'seed' => 2 } );
    is( $adventure->{'seed'}, 2, 'ensure seed is set' );

    done_testing();
};


subtest 'test generate_adventure name' => sub {
    my $adventure;
    GenericGenerator::set_seed(1);
    $adventure = AdventureGenerator::generate_name();
    is( $adventure->{'namepattern'}, "SUBJECT",          'test a simple subject' );
    is( $adventure->{'name'},        "The Foggy Symbol", 'ensure the subject is well formed' );

    $adventure = AdventureGenerator::generate_name( { 'seed' => 1, 'name' => "Bill and Ted's Excellent Adventure" } );
    is( $adventure->{'name'}, "Bill and Ted's Excellent Adventure", 'ensure namepattern is ignored' );

    my $tokens
        = 'NOUN SUBJECT ADJECTIVE VERB VERB.thirdperson VERB.participle VERB.gerund ARTICLE ADVERB NEGATE ARTICLE';
    my $tokenstring
        = "Hand the Primal Adventure Golden Vivaciously Accuse Stinks Retreated Freely Displaying ARTICLE Cautiously Don't ARTICLE";
    $adventure = AdventureGenerator::generate_name( { 'seed' => 1, 'namepattern' => $tokens } );
    is( $adventure->{'namepattern'}, $tokens,      'ensure all the tokens are parsed.' );
    is( $adventure->{'name'},        $tokenstring, 'ensure the name is as expected.' );

    done_testing();
};

1;

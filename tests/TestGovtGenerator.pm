#!/usr/bin/perl -wT
###############################################################################
#
package TestGovtGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use GovtGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_govt' => sub {
    my $govt;
    $govt = GovtGenerator::create_govt( { 'seed' => 12 } );
    is( $govt->{'seed'}, 12 );

    done_testing();
};

subtest 'test set_govt_type' => sub {
    my $govt;
    $govt = GovtGenerator::create_govt( { 'seed' => 41630 } );
    is( $govt->{'seed'}, 41630 );
    is( $govt->{'description'},
        'the ruler or small clique wield absolute power (not restricted by a constitution or laws)' );
    is( $govt->{'type'},            'dictatorship' );
    is( $govt->{'title'}->{'male'}, 'Inquisitor' );

    $govt = GovtGenerator::create_govt(
        { 'seed' => 41630, 'description' => 'he says he wins', 'type' => 'blah', 'title' => { 'male' => 'Sir' } } );
    is( $govt->{'seed'},            41630 );
    is( $govt->{'description'},     'he says he wins' );
    is( $govt->{'type'},            'blah' );
    is( $govt->{'title'}->{'male'}, 'Sir' );

    done_testing();
};
subtest 'test set_ruler' => sub {
    my $govt;
    $govt = GovtGenerator::create_govt( { 'seed' => 41630 } );
    is( $govt->{'seed'}, 41630 );

    #    is($govt->{'leader'}->{'right'},        'by revolution');
    #    is($govt->{'leader'}->{'reputation'},   '');
    #    is($govt->{'leader'}->{'length'},       '');
    #    is($govt->{'leader'}->{'opposition'},   '');
    #    is($govt->{'leader'}->{'maintained'},   '');

    $govt = GovtGenerator::create_govt( { 'seed' => 41630, } );
    is( $govt->{'seed'}, 41630 );

    done_testing();
};

#
#
#subtest 'test set_reputation' => sub {
#    my $govt;
#    $govt=GovtGenerator::create_govt({'seed'=>41630});
#    GovtGenerator::set_reputation($govt);
#    is($govt->{'seed'},41630);
#    is($govt->{'reputation'},'revered');
#
#    #FIXME check for collisions like approval_mod
#    $govt=GovtGenerator::create_govt({'seed'=>12, 'reputation'=>'foo', 'reputation_approval_mod'=>'5'});
#    GovtGenerator::set_reputation($govt);
#    is($govt->{'seed'},12);
#    is($govt->{'reputation_approval_mod'},5);
#    is($govt->{'reputation'},"foo");
#
#    done_testing();
#};
#
#
subtest 'test generate_stats' => sub {
    my $govt;
    $govt = GovtGenerator::create_govt( { 'seed' => 41630 } );
    is( $govt->{'seed'}, 41630 );
    foreach my $stat (qw/ corruption approval efficiency influence unity theology/) {
        cmp_ok( $govt->{'stats'}->{$stat}, '<=', 100, "$stat max" );
        cmp_ok( $govt->{'stats'}->{$stat}, '>=', 1,   "$stat min" );
    }

    is( $govt->{'corruption_description'}, 'decent' );
    is( $govt->{'approval_description'},   'honored' );
    is( $govt->{'efficiency_description'}, 'mostly sufficient' );
    is( $govt->{'unity_description'},      'overcomes their differences' );
    is( $govt->{'influence_description'},  'enduring' );
    is( $govt->{'influencereason'},        'riots in the region' );

    $govt = GovtGenerator::create_govt(
        {
            'seed'  => 41630,
            'stats' => {
                'corruption' => 12,
                'approval'   => 33,
                'efficiency' => 44,
                'influence'  => 55,
                'unity'      => 66,
                'theology'   => 77
            }
        }
    );
    is( $govt->{'seed'},                  41630 );
    is( $govt->{'stats'}->{'corruption'}, 12 );
    is( $govt->{'stats'}->{'approval'},   33 );
    is( $govt->{'stats'}->{'efficiency'}, 44 );
    is( $govt->{'stats'}->{'influence'},  55 );
    is( $govt->{'stats'}->{'unity'},      66 );
    is( $govt->{'stats'}->{'theology'},   77 );

    $govt = GovtGenerator::create_govt(
        {
            'seed'                   => 41630,
            'corruption_description' => '',
            'approval_description'   => '',
            'efficiency_description' => '',
            'unity_description'      => '',
            'influence_description'  => '',
            'influencereason'        => ''
        }
    );
    is( $govt->{'corruption_description'}, '' );
    is( $govt->{'approval_description'},   '' );
    is( $govt->{'efficiency_description'}, '' );
    is( $govt->{'unity_description'},      '' );
    is( $govt->{'influence_description'},  '' );
    is( $govt->{'influencereason'},        '' );


    done_testing();
};

#
#subtest 'test set_secondary_power' => sub {
#    my $govt;
#    $govt=GovtGenerator::create_govt({'seed'=>41630});
#    GovtGenerator::set_secondary_power($govt);
#    is($govt->{'seed'},41630);
#    is($govt->{'secondary_power'}->{'plot'},"openly denounces");
#    is($govt->{'secondary_power'}->{'power'},'an advisor');
#    is($govt->{'secondary_power'}->{'subplot_roll'},"74");
#    is($govt->{'secondary_power'}->{'subplot'},undef);
#
#    $govt=GovtGenerator::create_govt({'seed'=>2, 'secondary_power'=>{'plot'=>'foo', 'subplot_roll'=>3}});
#    GovtGenerator::set_secondary_power($govt);
#    is($govt->{'seed'},2);
#    is($govt->{'secondary_power'}->{'plot'},"foo");
#    is($govt->{'secondary_power'}->{'power'},"a barbarian");
#    is($govt->{'secondary_power'}->{'subplot_roll'},"3");
#    is($govt->{'secondary_power'}->{'subplot'},"wishing to rule with a violent, iron fist");
#
#    $govt=GovtGenerator::create_govt({'seed'=>2, 'secondary_power'=>{'plot'=>'foo', 'power'=>'bar', 'subplot_roll'=>3, 'subplot'=>'baz'}});
#    GovtGenerator::set_secondary_power($govt);
#    is($govt->{'seed'},2);
#    is($govt->{'secondary_power'}->{'plot'},"foo");
#    is($govt->{'secondary_power'}->{'power'},"bar");
#    is($govt->{'secondary_power'}->{'subplot_roll'},"3");
#    is($govt->{'secondary_power'}->{'subplot'},"baz");
#
#    done_testing();
#};
#
#
#
#
#
#
#
#

1;

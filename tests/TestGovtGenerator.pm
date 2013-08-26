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

subtest 'test create' => sub {
    my $govt;
    $govt = GovtGenerator::create(  );
    isnt( $govt->{'seed'},          undef, 'seed is set' );
    isnt( $govt->{'description'},   undef, 'description is set'  );
    isnt( $govt->{'type'},          undef, 'type is set' );
    isnt( $govt->{'title'},         undef, 'title is set' );

    done_testing();
};

subtest 'test set_govt_type' => sub {
    my $govt;

    $govt = GovtGenerator::create(
        { 'seed' => 1, 'description' => 'he says he wins', 'type' => 'blah', 'title' => { 'male' => 'Sir' } } );
    is( $govt->{'seed'},            1 );
    is( $govt->{'description'},     'he says he wins' );
    is( $govt->{'type'},            'blah' );
    is( $govt->{'title'}->{'male'}, 'Sir' );

    done_testing();
};

subtest 'test generate_stats' => sub {
    my $govt;
    $govt = GovtGenerator::create( { 'seed' => 1 } );
    is( $govt->{'seed'}, 1 );
    foreach my $stat (qw/ corruption approval efficiency influence unity theology/) {
        ok( $govt->{'stats'}->{$stat} >= 1 && $govt->{'stats'}->{$stat} <= 100, "$govt->{'stats'}->{$stat} is between 1 and 100" );
        isnt( $govt->{$stat.'_description'}, undef, "$stat description is set" );
    }

    my $stats= {
                'corruption' => 12,
                'approval'   => 33,
                'efficiency' => 44,
                'influence'  => 55,
                'unity'      => 66,
                'theology'   => 77
            };


    $govt = GovtGenerator::create( { 'seed'=>1, 'stats'=>$stats, } );

    is( $govt->{'seed'}, 1 );

    foreach my $key ( keys %$stats  ){
        is( $govt->{'stats'}->{$key}, $stats->{$key}, "$key is $stats->{$key} " );

    }


    my $presets={
            'seed'                   => 41630,
            'corruption_description' => '',
            'approval_description'   => '',
            'efficiency_description' => '',
            'unity_description'      => '',
            'influence_description'  => '',
            'influencereason'        => ''
        };


    $govt = GovtGenerator::create( $presets  );
    foreach my $key ( keys %$stats  ){
        is( $govt->{$key}, $presets->{$key}, "$key is $presets>{$key} " );

    }
    done_testing();
};

#subtest 'test set_secondary_power' => sub {
#    my $govt;
#    $govt=GovtGenerator::create({'seed'=>41630});
#    GovtGenerator::set_secondary_power($govt);
#    is($govt->{'seed'},41630);
#    is($govt->{'secondary_power'}->{'plot'},"openly denounces");
#    is($govt->{'secondary_power'}->{'power'},'an advisor');
#    is($govt->{'secondary_power'}->{'subplot_roll'},"74");
#    is($govt->{'secondary_power'}->{'subplot'},undef);
#
#    $govt=GovtGenerator::create({'seed'=>2, 'secondary_power'=>{'plot'=>'foo', 'subplot_roll'=>3}});
#    GovtGenerator::set_secondary_power($govt);
#    is($govt->{'seed'},2);
#    is($govt->{'secondary_power'}->{'plot'},"foo");
#    is($govt->{'secondary_power'}->{'power'},"a barbarian");
#    is($govt->{'secondary_power'}->{'subplot_roll'},"3");
#    is($govt->{'secondary_power'}->{'subplot'},"wishing to rule with a violent, iron fist");
#
#    $govt=GovtGenerator::create({'seed'=>2, 'secondary_power'=>{'plot'=>'foo', 'power'=>'bar', 'subplot_roll'=>3, 'subplot'=>'baz'}});
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

1;

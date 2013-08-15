#!/usr/bin/perl -wT
###############################################################################
#
package TestRumorGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use RumorGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_rumor' => sub {
    my $rumor;
GenericGenerator::set_seed(2);
    $rumor = RumorGenerator::create_rumor( );
    isnt( $rumor->{'seed'}, undef, 'ensure seed is set.' );


    $rumor = RumorGenerator::create_rumor( { 'seed' => 12, 'source'=>'bobo', 'heardit'=>'what?', 'belief'=>'something'} );
    is( $rumor->{'seed'}, 12, 'ensure seed is set.' );
    is( $rumor->{'source'}, 'bobo', 'ensure source is set.' );



    done_testing();
};

subtest 'test select_feature' => sub {
    my $rumor;
    $rumor = RumorGenerator::create_rumor( {'seed' => 12, 'request_roll'=>0, 'hook_roll'=>0, 'requirement_roll'=>0, 'disclaimer_roll'=>0, 'detail_roll'=>0 });
    foreach my $featurename (qw( verbed stealth location scarything fearresult dangeroushobby template ) ){
        isnt( $rumor->{$featurename}, undef, "ensure $featurename is set." );
    }
    my $presets={
      'seed'         => 12,
      'template'     => 'template',
    };
    foreach my $featurename (qw( verbed stealth location scarything fearresult dangeroushobby template ) ){
        $presets->{$featurename}= "$featurename preset";
    };
    $rumor = RumorGenerator::create_rumor( $presets );
    foreach my $featurename (qw( verbed stealth location scarything fearresult dangeroushobby ) ){
        is( $rumor->{$featurename}, "$featurename preset", "ensure $featurename is set." );
    }

    done_testing();
};

1;

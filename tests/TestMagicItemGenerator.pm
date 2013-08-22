#!/usr/bin/perl -wT
package TestMagicItemGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use MagicItemGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_item' => sub {
    my $item;
    $item = MagicItemGenerator::create_item( );
    isnt( $item->{'seed'}, undef, 'ensure seed is set.' );

    $item = MagicItemGenerator::create_item( { 'seed' => 12 } );
    is( $item->{'seed'}, 12, 'ensure seed is set.' );

    done_testing();
};

subtest 'test itemtypes' => sub {
    my $item;
    $item = MagicItemGenerator::create_item( { 'seed' => 12, 'item'=>'armor' } );
    is( $item->{'seed'}, 12, 'ensure seed is set.' );
    is( $item->{'item'}, 'armor', 'ensure type is set.' );

    done_testing();
};

subtest 'test item stats' => sub {
    my $item;
    my $stats={ 'value' => 100, 'repair' => 100, 'quality' => 100, 'strength' => 100};
    $item = MagicItemGenerator::create_item( { 'seed' => 12, 'item'=>'potion', 'stats'=>$stats,   } );
    foreach my $key (keys %$stats){
        is($item->{'stats'}->{$key}, $stats->{$key}, "$key is $stats->{$key}"  );
    }
    my $presets={ 'seed' => 12, 'item'=>'potion',  'value_description' => 'a', 'repair_description' => 'b', 'quality_description' => 'c', 'strength_description' => 'd'};
    $item = MagicItemGenerator::create_item( $presets );
    foreach my $key (keys %$presets){
        is($item->{$key}, $presets->{$key}, "$key is $presets->{$key}"  );
    }

    done_testing();
};

1;

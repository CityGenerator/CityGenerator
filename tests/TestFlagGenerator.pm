#!/usr/bin/perl -wT
###############################################################################
#
package TestFlagGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use FlagGenerator;
use GenericGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_flag' => sub {
    my $flag;
    GenericGenerator::set_seed(1);
    $flag = FlagGenerator::create_flag( );
    is($flag->{'seed'}, 41630);

    $flag = FlagGenerator::create_flag( { 'seed' => 41630 } );
    $flag->{'colors'} = undef;
    FlagGenerator::generate_colors($flag);
    is( $flag->{'seed'},        41630 );
    is( @{ $flag->{'colors'} }, 7 );


    $flag = FlagGenerator::create_flag( { 'seed' => 12345 } );
    is( $flag->{'seed'},        12345 );
    is( @{ $flag->{'colors'} }, 7 );

    done_testing();
};


subtest 'test generate_shape' => sub {
    my $flag;
    $flag = FlagGenerator::create_flag( { 'seed' => 41630 } );
    FlagGenerator::generate_shape($flag);
    is( $flag->{'shape'}->{'name'}, 'para' );

    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'shape' => { 'name' => 'bone' } } );
    FlagGenerator::generate_shape($flag);
    is( $flag->{'shape'}->{'name'}, 'bone' );
};

subtest 'test generate_ratio' => sub {
    my $flag;
    $flag = FlagGenerator::create_flag( { 'seed' => 41630 } );
    FlagGenerator::generate_ratio($flag);
    is( $flag->{'ratio'}, '1.6' );

    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'ratio' => 3 } );
    FlagGenerator::generate_ratio($flag);
    is( $flag->{'ratio'}, '3' );
};

subtest 'test generate_division' => sub {
    my $flag;
    $flag = FlagGenerator::create_flag( { 'seed' => 41630 } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'}, 'diagonal' );

    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'division' => { 'name' => 'stripes' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'},  'stripes' );
    is( $flag->{'division'}->{'side'},  'horizontal' );
    is( $flag->{'division'}->{'count'}, '9' );

    $flag = FlagGenerator::create_flag(
        { 'seed' => 41630, 'division' => { 'name' => 'stripes', 'side' => 'vertical' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'},  'stripes' );
    is( $flag->{'division'}->{'side'},  'vertical' );
    is( $flag->{'division'}->{'count'}, '9' );

    $flag = FlagGenerator::create_flag(
        { 'seed' => 41630, 'division' => { 'name' => 'stripes', 'side' => 'vertical', 'count' => '13' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'},  'stripes' );
    is( $flag->{'division'}->{'side'},  'vertical' );
    is( $flag->{'division'}->{'count'}, '13' );


    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'division' => { 'name' => 'bunny' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'}, 'bunny' );
};


subtest 'test generate_overlay' => sub {
    my $flag;
    $flag = FlagGenerator::create_flag( { 'seed' => 41630 } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'}, 'quad' );
    is( $flag->{'overlay'}->{'side'}, 'sw' );

    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'overlay' => { 'name' => 'stripe' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'horizontal' );
    is( $flag->{'overlay'}->{'count'},          '9' );
    is( $flag->{'overlay'}->{'count_selected'}, '8' );

    $flag = FlagGenerator::create_flag(
        { 'seed' => 41630, 'overlay' => { 'name' => 'stripe', 'side' => 'vertical', 'count_selected' => '1' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'vertical' );
    is( $flag->{'overlay'}->{'count'},          '9' );
    is( $flag->{'overlay'}->{'count_selected'}, '1' );

    $flag = FlagGenerator::create_flag(
        { 'seed' => 41630, 'overlay' => { 'name' => 'stripe', 'side' => 'vertical', 'count' => '13' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'vertical' );
    is( $flag->{'overlay'}->{'count'},          '13' );
    is( $flag->{'overlay'}->{'count_selected'}, '12' );


    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'overlay' => { 'name' => 'bunny' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'}, 'bunny' );
};

subtest 'test generate_symbol' => sub {
    my $flag;
    $flag = FlagGenerator::create_flag( { 'seed' => 41630 } );
    FlagGenerator::generate_symbol($flag);
    is( $flag->{'symbol'}->{'name'}, 'circle' );

    $flag = FlagGenerator::create_flag( { 'seed' => 41630, 'symbol' => { 'name' => 'bunny' } } );
    FlagGenerator::generate_symbol($flag);
    is( $flag->{'symbol'}->{'name'}, 'bunny' );
};


1;


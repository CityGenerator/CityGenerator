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


subtest 'test create' => sub {
    my $flag;
    GenericGenerator::set_seed(1);
    $flag = FlagGenerator::create( );
    is($flag->{'seed'}, 41630);

    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    $flag->{'colors'} = undef;
    FlagGenerator::generate_colors($flag);
    is( $flag->{'seed'},        41630 );
    is( @{ $flag->{'colors'} }, 7 );


    $flag = FlagGenerator::create( { 'seed' => 12345 } );
    is( $flag->{'seed'},        12345 );
    is( @{ $flag->{'colors'} }, 7 );

    done_testing();
};


subtest 'test generate_shape' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    isnt( $flag->{'shape'}->{'name'}, undef );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'shape' => { 'name' => 'bone' } } );
    is( $flag->{'shape'}->{'name'}, 'bone' );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'shape_roll' =>92 } );
    is( $flag->{'shape'}->{'name'}, 'tongued' );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'shape_roll' =>92, 'shape'=>{'tongueshape'=>'sine', } } );
    is( $flag->{'shape'}->{'name'}, 'tongued' );
    is( $flag->{'shape'}->{'tongueshape'}, 'sine' );
done_testing();

};

subtest 'test generate_ratio' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    FlagGenerator::generate_ratio($flag);
    is( $flag->{'ratio'}, '1.6' );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'ratio' => 3 } );
    FlagGenerator::generate_ratio($flag);
    is( $flag->{'ratio'}, '3' );
done_testing();
};

subtest 'test generate_division' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'}, 'diagonal' );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'division' => { 'name' => 'stripes' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'},  'stripes' );
    is( $flag->{'division'}->{'side'},  'horizontal' );
    is( $flag->{'division'}->{'count'}, '9' );

    $flag = FlagGenerator::create(
        { 'seed' => 41630, 'division' => { 'name' => 'stripes', 'side' => 'vertical' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'},  'stripes' );
    is( $flag->{'division'}->{'side'},  'vertical' );
    is( $flag->{'division'}->{'count'}, '9' );

    $flag = FlagGenerator::create(
        { 'seed' => 41630, 'division' => { 'name' => 'stripes', 'side' => 'vertical', 'count' => '13' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'},  'stripes' );
    is( $flag->{'division'}->{'side'},  'vertical' );
    is( $flag->{'division'}->{'count'}, '13' );


    $flag = FlagGenerator::create( { 'seed' => 41630, 'division' => { 'name' => 'bunny' } } );
    FlagGenerator::generate_division($flag);
    is( $flag->{'division'}->{'name'}, 'bunny' );
done_testing();
};


subtest 'test generate_overlay' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'}, 'quad' );
    is( $flag->{'overlay'}->{'side'}, 'sw' );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'overlay' => { 'name' => 'stripe' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'horizontal' );
    isnt( $flag->{'overlay'}->{'count'},          undef );
    ok( $flag->{'overlay'}->{'count_selected'}<=$flag->{'overlay'}->{'count'} , "make sure the selected item is less than count" );

    $flag = FlagGenerator::create(
        { 'seed' => 41630, 'overlay' => { 'name' => 'stripe', 'side' => 'vertical', 'count_selected' => '1' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'vertical' );
    isnt( $flag->{'overlay'}->{'count'},          undef );
    ok( $flag->{'overlay'}->{'count_selected'}<=$flag->{'overlay'}->{'count'} , "make sure the selected item is less than count" );

    $flag = FlagGenerator::create(
        { 'seed' => 41630, 'overlay' => { 'name' => 'stripe', 'side' => 'vertical', 'count' => '13' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'vertical' );
    is( $flag->{'overlay'}->{'count'},          '13' );
    ok( $flag->{'overlay'}->{'count_selected'}<=$flag->{'overlay'}->{'count'} , "make sure the selected item is less than count" );

    $flag = FlagGenerator::create(
        { 'seed' => 41630, 'overlay' => { 'name' => 'stripe', 'side' => 'vertical', 'count' => '13', 'count_selected'=>2 } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'},           'stripe' );
    is( $flag->{'overlay'}->{'side'},           'vertical' );
    is( $flag->{'overlay'}->{'count'},          '13' );
    is( $flag->{'overlay'}->{'count_selected'}, 2 , "make sure the selected item is 2" );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'overlay' => { 'name' => 'bunny' } } );
    FlagGenerator::generate_overlay($flag);
    is( $flag->{'overlay'}->{'name'}, 'bunny' );
done_testing();
};

subtest 'test generate_symbol' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    FlagGenerator::generate_symbol($flag);
    is( $flag->{'symbol'}->{'name'}, 'circle' );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'symbol' => { 'name' => 'circle' } } );
    FlagGenerator::generate_symbol($flag);
    is( $flag->{'symbol'}->{'name'}, 'circle' );
    isnt( $flag->{'symbol'}->{'radius_direction'}, undef );
done_testing();
};

subtest 'test generate_border' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 41630 } );
    FlagGenerator::generate_border($flag);
    isnt( $flag->{'border'}->{'name'}, undef );

    $flag = FlagGenerator::create( { 'seed' => 41630, 'border' => { 'name' => 'solid' } } );
    FlagGenerator::generate_border($flag);
    is( $flag->{'border'}->{'name'}, 'solid' );
    like( $flag->{'border'}->{'size'}, '/\.\\d\\d/' );
done_testing();
};

subtest 'test generate_letter' => sub {
    my $flag;
    $flag = FlagGenerator::create( { 'seed' => 1, } );
    isnt( $flag->{'symbol'}->{'letter'}, undef, "make sure it's something" );

    $flag = FlagGenerator::create( { 'seed' => 1, 'cityname'=>'Aba' } );
    is( $flag->{'symbol'}->{'letter'}, 'A' );
done_testing();

};

done_testing();
1;


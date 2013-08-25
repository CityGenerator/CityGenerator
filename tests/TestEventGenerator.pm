#!/usr/bin/perl -wT
###############################################################################
#
package TestEventGenerator;

use strict;
use warnings;
use Data::Dumper;
use EventGenerator;
use Exporter;
use GenericGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create' => sub {
    my $event;
    GenericGenerator::set_seed(1);
    $event = EventGenerator::create();
    is( $event->{'seed'}, 41630 );

    $event = EventGenerator::create( { 'seed' => 12 } );
    is( $event->{'seed'}, 12 );

    done_testing();
};

subtest 'test select_base' => sub {
    my $event;
    $event = EventGenerator::create( { 'seed' => 12 } );
    EventGenerator::select_base($event);

    is( $event->{'seed'}, 12 );
    is( $event->{'base'}, 'festival' );
    is( $event->{'name'}, 'festival' );

    $event = EventGenerator::create( { 'seed' => 12, 'base' => 'foo' } );
    EventGenerator::select_base($event);

    is( $event->{'seed'}, 12 );
    is( $event->{'base'}, 'foo' );
    is( $event->{'name'}, 'foo' );


    done_testing();
};

subtest 'test select_modifier' => sub {
    my $event;
    $event = EventGenerator::create( { 'seed' => 12, 'base' => 'war' } );
    EventGenerator::select_modifier($event);

    is( $event->{'seed'},     12 );
    is( $event->{'base'},     'war' );
    isnt( $event->{'modifier'}, undef );
    like( $event->{'name'},     '/.+war/' );


    $event = EventGenerator::create( { 'seed' => 12, 'base' => 'war', 'modifier' => 'foo' } );
    EventGenerator::select_modifier($event);

    is( $event->{'seed'},     12 );
    is( $event->{'base'},     'war' );
    is( $event->{'modifier'}, 'foo' );
    is( $event->{'name'},     'foo war' );


    done_testing();
};


1;

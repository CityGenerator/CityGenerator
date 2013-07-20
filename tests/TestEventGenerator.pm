#!/usr/bin/perl -wT
###############################################################################
#
package TestEventGenerator;

use strict;
use warnings;
use Test::More;
use EventGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_event' => sub {
    my $event;
    set_seed(1);
    $event=EventGenerator::create_event();
    is($event->{'seed'},41630);

    $event=EventGenerator::create_event({'seed'=>12});
    is($event->{'seed'},12);

    done_testing();
};

subtest 'test select_base' => sub {
    my $event;
    $event=EventGenerator::create_event({'seed'=>12});
    EventGenerator::select_base($event);

    is($event->{'seed'},12);
    is($event->{'base'}, 'festival');
    is($event->{'name'}, 'festival');

    $event=EventGenerator::create_event({'seed'=>12, 'base'=>'foo'});
    EventGenerator::select_base($event);

    is($event->{'seed'},12);
    is($event->{'base'}, 'foo');
    is($event->{'name'}, 'foo');


    done_testing();
};

subtest 'test select_modifier' => sub {
    my $event;
    $event=EventGenerator::create_event({'seed'=>12, 'base'=>'war'});
    EventGenerator::select_modifier($event);

    is($event->{'seed'},12);
    is($event->{'base'},     'war');
    is($event->{'modifier'}, 'the aftermath of a');
    is($event->{'name'},     'the aftermath of a war');


    $event=EventGenerator::create_event({'seed'=>12, 'base'=>'war', 'modifier'=>'foo'});
    EventGenerator::select_modifier($event);

    is($event->{'seed'},12);
    is($event->{'base'},     'war');
    is($event->{'modifier'}, 'foo');
    is($event->{'name'},     'foo war');


    done_testing();
};


1;

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

    set_seed(1);
    $event=EventGenerator::create_event({'seed'=>12});
    is($event->{'seed'},12);



    done_testing();
};

1;

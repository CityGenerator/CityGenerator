#!/usr/bin/perl -wT
###############################################################################
#
package TestMythGenerator;

use strict;
use warnings;
use Test::More;
use MythGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_myth' => sub {
    my $myth;
    set_seed(1);
    $myth=MythGenerator::create_myth();
    is($myth->{'seed'},41630);

    $myth=MythGenerator::create_myth({'seed'=>12});
    is($myth->{'seed'},12);



    done_testing();
};

1;

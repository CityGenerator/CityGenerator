#!/usr/bin/perl -wT
###############################################################################
#
package TestMilitaryGenerator;

use strict;
use warnings;
use Test::More;
use MilitaryGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_military' => sub {
    my $military;
    set_seed(1);
    $military=MilitaryGenerator::create_military();
    is($military->{'seed'},41630);
    is($military->{'original_seed'},41630);


    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    is($military->{'seed'},22);
    is($military->{'original_seed'},22);


    done_testing();
};

1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestContinentGenerator;

use strict;
use warnings;
use Test::More;
use ContinentGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_continent' => sub {
    my $continent;
    set_seed(1);
    $continent=ContinentGenerator::create_continent();
    is($continent->{'seed'},41600);

    $continent=ContinentGenerator::create_continent({'seed'=>12345});
    is($continent->{'seed'},12300);
#FIXME need name testing
    $continent=ContinentGenerator::create_continent({'seed'=>12345, 'name'=>'test'});
    is($continent->{'seed'},12300);
    is($continent->{'name'},'test');

    done_testing();
};





1;


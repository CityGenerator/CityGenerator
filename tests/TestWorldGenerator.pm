#!/usr/bin/perl -wT
###############################################################################
#
package TestWorldGenerator;

use strict;
use warnings;
use Test::More;
use WorldGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_world' => sub {
    my $world;
    set_seed(1);
    $world=WorldGenerator::create_world();
    is($world->{'seed'},41600);

    $world=WorldGenerator::create_world({'seed'=>12345});
    is($world->{'seed'},12300);
    is($world->{'name'},'Merngrn');

    $world=WorldGenerator::create_world({'seed'=>12345, 'name'=>'test'});
    is($world->{'seed'},12300);
    is($world->{'name'},'test');

    done_testing();
};





1;


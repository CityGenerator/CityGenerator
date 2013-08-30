#!/usr/bin/perl -wT
###############################################################################
#
package TestDeityGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use DeityGenerator;
use CityGenerator;
use NPCGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $deity;
    GenericGenerator::set_seed(2);
    $deity = DeityGenerator::create( );
    isnt( $deity->{'seed'}, undef, 'ensure seed is set.' );

print Dumper $deity;

    done_testing();
};

done_testing();
1;

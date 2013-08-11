#!/usr/bin/perl -wT
###############################################################################
#
#
#
#
#
#
#
#
#
#              This is an posting generator to help others learn
#           to create a generator. It's intended to be used as a
#           skeleton to build on. Make sure you remove this block
#           before you commit it!
#
#
#
#
#
#
#
#
#
#
###############################################################################
package TestExampleGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use ExampleGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_example' => sub {
    my $example;
    $example = ExampleGenerator::create_example( );
    isnt( $example->{'seed'}, undef, 'ensure seed is set.' );

    $example = ExampleGenerator::create_example( { 'seed' => 12 } );
    is( $example->{'seed'}, 12, 'ensure seed is set.' );

    done_testing();
};

1;

#!/usr/bin/perl -wT
###############################################################################
#
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
    isnt( $example->{'seed'}, undef 'ensure seed is set.' );

    $example = ExampleGenerator::create_example( { 'seed' => 12 } );
    is( $example->{'seed'}, 12 );

    done_testing();
};

1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestPostingGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use PostingGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_posting' => sub {
    my $posting;
    $posting = PostingGenerator::create_posting( );
    isnt( $posting->{'seed'}, undef, 'ensure seed is set.' );

    $posting = PostingGenerator::create_posting( { 'seed' => 12 } );
    is( $posting->{'seed'}, 12, 'ensure seed is set.' );

    done_testing();
};

1;

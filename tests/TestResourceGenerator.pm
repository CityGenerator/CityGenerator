#!/usr/bin/perl -wT
###############################################################################
#
package TestResourceGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use ResourceGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $resource;
    GenericGenerator::set_seed(2);

    $resource = ResourceGenerator::create( );
    isnt( $resource->{'template'}, undef, 'ensure template is set.' );
    #FIXME this is poor quality.

    done_testing();
};

done_testing();
1;

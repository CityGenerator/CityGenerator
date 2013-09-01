#!/usr/bin/perl -wT
###############################################################################
#
package TestDeityFormatter;

use strict;
use warnings;

use DeityGenerator;
use Data::Dumper;
use Exporter;
use DeityFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Deity' => sub {
    my $deity = DeityGenerator::create( { seed => 1 } );
    my $deitytext = DeityFormatter::printSummary($deity);
    like($deitytext,"/.+ is .+ .+ who favors .+\.\n .+ controls .+\.\n .+ holy symbol is .+ .+ .+ and prefers .+ from .+ followers.\n .+ are the preferred weapon of .+\.\n/");

    done_testing();
};

done_testing();
1;

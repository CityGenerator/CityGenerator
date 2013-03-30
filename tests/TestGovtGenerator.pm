#!/usr/bin/perl -wT
###############################################################################
#
package TestGovtGenerator;

use strict;
use warnings;
use Test::More;
use GovtGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_govt' => sub {
    my $govt;
    set_seed(1);
    $govt=GovtGenerator::create_govt();
    is($govt->{'seed'},41630);

    set_seed(1);
    $govt=GovtGenerator::create_govt({'seed'=>12});
    is($govt->{'seed'},12);



    done_testing();
};

1;

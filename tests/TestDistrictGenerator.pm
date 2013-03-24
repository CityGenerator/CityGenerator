#!/usr/bin/perl -wT
###############################################################################
#
package TestDistrictGenerator;

use strict;
use warnings;
use Test::More;
use DistrictGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_district' => sub {
    my $district;
    set_seed(1);
    $district=DistrictGenerator::create_district();
    is($district->{'seed'},41630);

    set_seed(1);
    $district=DistrictGenerator::create_district({'seed'=>12});
    is($district->{'seed'},12);



    done_testing();
};

1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestRegionGenerator;

use strict;
use warnings;
use Test::More;
use RegionGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_region' => sub {
    my $region;
    $region=RegionGenerator::create_region({'seed'=>41630});
    is($region->{'seed'},41630);
    is($region->{'name'},'Nillkil Domain');

    $region=RegionGenerator::create_region({'seed'=>12345});
    is($region->{'seed'},12340);
    is($region->{'name'},'Nillsakor District');

    $region=RegionGenerator::create_region({'seed'=>12345, 'name'=>'test'  });
    is($region->{'seed'},12340);
    is($region->{'name'},'test');

    done_testing();
};





1;


#!/usr/bin/perl -wT
###############################################################################
#
package TestClimateGenerator;

use strict;
use warnings;
use Test::More;
use ClimateGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create_climate' => sub {
    my $climate;
    $climate=ClimateGenerator::create_climate( {'seed'=>1,'altitude'=>'-5','latitude'=>'-5','continentality'=>'-5','pressure'=>'105'});

    is($climate->{'altitude'},'0');
    is($climate->{'continentality'},'0');
    is($climate->{'latitude'},'0');
    is($climate->{'pressure'},'100');
    
    is($climate->{'temperature'},'100');
    is($climate->{'precipitation'},'100');
    
    is($climate->{'biomekey'},'AF');
    is($climate->{'name'},'Tropical Rainforest');
    is($climate->{'description'},'characterized by constant high temperatures and continual rain year-round, and has no natural season.');

    $climate=ClimateGenerator::create_climate( {'seed'=>1,'altitude'=>'50','latitude'=>'50','continentality'=>'50','pressure'=>'50'});

    is($climate->{'altitude'},'50');
    is($climate->{'continentality'},'50');
    is($climate->{'latitude'},'50');
    is($climate->{'pressure'},'50');
    
    is($climate->{'temperature'},'50');
    is($climate->{'precipitation'},'50');

    is($climate->{'biomekey'},'CW');
    is($climate->{'name'},'Temperate Deciduous Forest');


    $climate=ClimateGenerator::create_climate( {'seed'=>1,'altitude'=>'105','latitude'=>'105','continentality'=>'105','pressure'=>'-5'});

    is($climate->{'altitude'},'100');
    is($climate->{'continentality'},'100');
    is($climate->{'latitude'},'100');
    is($climate->{'pressure'},'0');
    
    is($climate->{'temperature'},'0');
    is($climate->{'precipitation'},'0');

    is($climate->{'biomekey'},'EF');
    is($climate->{'name'},'Ice Cap');

    $climate=ClimateGenerator::create_climate( {'seed'=>1,'altitude'=>'0','latitude'=>'0','continentality'=>'100','pressure'=>'0'});

    is($climate->{'altitude'},'0');
    is($climate->{'latitude'},'0');
    is($climate->{'continentality'},'100');
    is($climate->{'pressure'},'0');
    
    is($climate->{'temperature'},'100');
    is($climate->{'precipitation'},'0');

    is($climate->{'biomekey'},'BW');
    is($climate->{'name'},'Arid Desert');

    done_testing();
};


1;


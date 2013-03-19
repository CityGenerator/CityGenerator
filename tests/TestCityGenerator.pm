#!/usr/bin/perl -wT
###############################################################################
#
package TestCityGenerator;

use strict;
use Test::More;
use CityGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_city' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city();
    is($city->{'seed'},41630);
    is($city->{'original_seed'},41630);
    is($city->{'name'},'Port Janville');
    is($city->{'size'},'town');
    is($city->{'gplimit'},'3500');
    is($city->{'pop_estimate'},'3203');
    is($city->{'size_modifier'},'1');

    $city=CityGenerator::create_city({'seed'=>24,'dummy'=>'test'});
    is($city->{'seed'},24);
    is($city->{'dummy'},'test');
    is($city->{'name'},'Eisenbridge');

    $city=CityGenerator::create_city({'seed'=>24,'name'=>'foo','size'=>'Detroitish','gplimit'=>'12345','pop_estimate'=>'10102','size_modifier'=>'3'});
    is($city->{'seed'},24);
    is($city->{'name'},'foo');
    is($city->{'size'},'Detroitish');
    is($city->{'gplimit'},'12345');
    is($city->{'pop_estimate'},'10102');
    is($city->{'size_modifier'},'3');

    done_testing();
};


subtest 'test generate_city_name' => sub {
    my $city;
    set_seed(1);

    $city={};
    CityGenerator::generate_city_name($city);
    is($city->{'name'},'Port  Janville'); #FIXME spaces!

    $city={'seed'=>20, 'name'=>'foo'};
    CityGenerator::generate_city_name($city);
    is($city->{'name'},'foo');

    done_testing();
};

subtest 'test set_city_size' => sub {
    my $city;
    set_seed(1);

    $city={'seed'=>20};
    CityGenerator::set_city_size($city);
    is($city->{'size'},'small town');
    is($city->{'gplimit'},'1500');
    is($city->{'pop_estimate'},'1422');
    is($city->{'size_modifier'},'0');

    $city={'seed'=>24,'name'=>'foo','size'=>'Detroitish','gplimit'=>'12345','pop_estimate'=>'10102','size_modifier'=>'3'};
    CityGenerator::set_city_size($city);
    is($city->{'size'},'Detroitish');
    is($city->{'gplimit'},'12345');
    is($city->{'pop_estimate'},'10102');
    is($city->{'size_modifier'},'3');

    done_testing();
};

subtest 'test flesh_out_city' => sub {
    my $city;
    set_seed(1);

    $city={};
    CityGenerator::generate_city_name($city);
    CityGenerator::flesh_out_city($city);
    is($city->{'name'},'Port   Janville'); #FIXME spaces!
    is($city->{'region'}->{'name'}, 'Konsak Territory');
    is($city->{'continent'}->{'name'}, 'Asporek');


    done_testing();
};


subtest 'test set_city_type' => sub {
    my $city;
    set_seed(1);

    $city=CityGenerator::create_city();
    CityGenerator::set_city_type($city);
    is($city->{'name'},'Port    Janville'); #FIXME spaces!
    is($city->{'base_pop'},'basic');
    is($city->{'type'},'basic+1');
    is($city->{'description'},'fairly normal population (with one monstrous race)');
    is($city->{'add_other'},'true');
    $city={'base_pop'=>'foo1','type'=>'foo2','description'=>'foo3','add_other'=>'foo4', };
    CityGenerator::set_city_type($city);
    is($city->{'name'},undef);
    is($city->{'base_pop'},'foo1');
    is($city->{'type'},'foo2');
    is($city->{'description'},'foo3');
    is($city->{'add_other'},'foo4');


    done_testing();
};


subtest 'test generate_pop_type' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city();
    CityGenerator::generate_pop_type($city);
    is($city->{'popdensity'}->{'feetpercapita'}, '1500');
    is($city->{'poptype'}, 'quartered');
    is(scalar @{$city->{'races'}}, 4);

    set_seed(1);
    $city=CityGenerator::create_city({ 'popdensity'=>'foobard','poptype'=>'dumb', 'races'=>1    });
    CityGenerator::generate_pop_type($city);
    is($city->{'popdensity'}->{'feetpercapita'}, 1500);
    is($city->{'poptype'}, 'dumb' );
    is(scalar @{$city->{'races'}}, 4);

    set_seed(1);
    $city=CityGenerator::create_city({ 'popdensity'=>{'feetpercapita'=>2000},'poptype'=>'dumb', 'races'=>[1,2]    });
    CityGenerator::generate_pop_type($city);
    is($city->{'popdensity'}->{'feetpercapita'}, 2000);
    is($city->{'poptype'}, 'dumb' );
    is(scalar @{$city->{'races'}}, 2);

    done_testing();
};

subtest 'test generate_walls' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_walls($city);
    is($city->{'size_modifier'},'-5');
    is($city->{'wall_chance_roll'},'109');
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'content'},'none');
    is($city->{'walls'}->{'height'},'0');

    $city=CityGenerator::create_city({'seed'=>'2'});
    CityGenerator::generate_walls($city);
    is($city->{'size_modifier'},'8');
    is($city->{'wall_chance_roll'},'18');
    is($city->{'wall_size_roll'},'89');
    is($city->{'walls'}->{'content'},'thick marble enclosure');
    is($city->{'walls'}->{'height'},'41');

    $city={};
    $city=CityGenerator::create_city({'seed'=>'2'});
    $city->{'size_modifier'}=undef;
    CityGenerator::generate_walls($city);
    is($city->{'size_modifier'},undef);
    is($city->{'wall_chance_roll'},'58');
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'content'},'none');
    is($city->{'walls'}->{'height'},'0');

    done_testing();
};






1;

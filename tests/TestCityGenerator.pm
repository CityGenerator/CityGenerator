#!/usr/bin/perl -wT
###############################################################################
#
package TestCityGenerator;

use strict;
use warnings;
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
    is($city->{'name'},'Port Janville'); #FIXME spaces!

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
    is($city->{'name'},'Port Janville'); #FIXME spaces!
    is($city->{'region'}->{'name'}, 'Konsak Territory');
    is($city->{'continent'}->{'name'}, 'Asporek');


    done_testing();
};


subtest 'test set_pop_type' => sub {
    my $city;
    set_seed(1);

    $city=CityGenerator::create_city();
    CityGenerator::set_pop_type($city);
    is($city->{'name'},'Port Janville'); #FIXME spaces!
    is($city->{'base_pop'},'basic');
    is($city->{'type'},'basic+1');
    is($city->{'description'},'fairly normal population (with one monstrous race)');
    is($city->{'add_other'},'monster');
    $city={'base_pop'=>'foo1','type'=>'foo2','description'=>'foo3','add_other'=>'foo4', };
    CityGenerator::set_pop_type($city);
    is($city->{'name'},undef);
    is($city->{'base_pop'},'foo1');
    is($city->{'type'},'foo2');
    is($city->{'description'},'foo3');
    is($city->{'add_other'},'foo4');


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

subtest 'test set_laws' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::set_laws($city);
    is($city->{'laws'}->{'punishment'}, 'fines');
    is($city->{'laws'}->{'enforcement'}, 'but are loosely enforced');
    is($city->{'laws'}->{'trial'}, 'without trial');
    is($city->{'laws'}->{'enforcer'}, 'city guard');
    is($city->{'laws'}->{'commoncrime'}, 'petty theft');

    $city=CityGenerator::create_city({'seed'=>'1', 'laws'=>{'punishment' => 'a','enforcement' => 'b','trial' => 'c','enforcer' => 'd','commoncrime' => 'e'}} );
    CityGenerator::set_laws($city);
    is($city->{'laws'}->{'punishment'}, 'a');
    is($city->{'laws'}->{'enforcement'}, 'b');
    is($city->{'laws'}->{'trial'}, 'c');
    is($city->{'laws'}->{'enforcer'}, 'd');
    is($city->{'laws'}->{'commoncrime'}, 'e');


    done_testing();
};

subtest 'test set_age' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::set_age($city);
    is($city->{'age_description'}, 'old');
    is($city->{'age_mod'}, '-5');
    is($city->{'age_roll'}, '79');

    $city=CityGenerator::create_city({'seed'=>'1', 'age_description'=>'foo','age_mod'=>12, 'age_roll'=>'1'   } );
    CityGenerator::set_age($city);
    is($city->{'age_description'}, 'foo');
    is($city->{'age_mod'}, '12');
    is($city->{'age_roll'}, '1');

    done_testing();
};


subtest 'test generate_resources' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 1);
    is(@{$city->{'resources'}}, 1);

    $city=CityGenerator::create_city({'seed'=>'1', 'economy'=>20});
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 1);
    is(@{$city->{'resources'}}, 1);

    $city=CityGenerator::create_city({'seed'=>'1', 'economy'=>20});
    $city->{'economy'}=undef;
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 1);
    is(@{$city->{'resources'}}, 1);

    $city=CityGenerator::create_city({'seed'=>'2'  } );
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 6);
    is(@{$city->{'resources'}}, 6);

    $city=CityGenerator::create_city({'seed'=>'1', 'resourcecount'=>4   } );
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 4);
    is(@{$city->{'resources'}}, 4);

    $city=CityGenerator::create_city({'seed'=>'1', 'resourcecount'=>4, 'resources'=>1   } );
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 4);
    is(@{$city->{'resources'}}, 4);

    $city=CityGenerator::create_city({'seed'=>'1', 'resourcecount'=>4, 'resources'=>[]   } );
    CityGenerator::generate_resources($city);
    is($city->{'resourcecount'}, 4);
    is(@{$city->{'resources'}}, 0);


    done_testing();
};

subtest 'test generate_city_crest' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_city_crest($city);
    is(Dumper($city->{'crest'}), Dumper({}));

    done_testing();
};


subtest 'test generate_base_stats' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_base_stats($city);
    is($city->{'education'}, -4);
    is($city->{'authority'}, 0);
    is($city->{'magic'}    , 5);
    is($city->{'military'} , -1);
    is($city->{'tolerance'}, 2);
    is($city->{'economy'}  , -4);

    done_testing();
};


subtest 'test generate_shape' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_shape($city);
    is($city->{'shape'},'a circular');

    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1','shape'=>'fool'});
    CityGenerator::generate_shape($city);
    is($city->{'shape'},'fool');

    done_testing();
};

subtest 'test generate_city_age' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_city_age($city);
    is($city->{'city_age'}->{'content'},'young');

    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1','city_age'=>{ 'content'=>'new'   }});
    CityGenerator::generate_city_age($city);
    is($city->{'city_age'}->{'content'},'new');

    done_testing();
};

subtest 'test set_available_races' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'monster'});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available races'}}), 13);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'basic'});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available races'}}), 8);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'mixed'});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available races'}}), 23);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'mixed', 'available races'=>[2,2,2]});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available races'}}), 3);

    done_testing();
};


subtest 'test generate_race_percentages' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'monster'});
    CityGenerator::generate_race_percentages($city);
    is(scalar(@{$city->{'race percentages'}}), 6);

    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'3', 'base_pop'=>'monster'});
    CityGenerator::generate_race_percentages($city);
    is(scalar(@{$city->{'race percentages'}}), 6);

    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'monster', 'race percentages'=>[75,20,4]});
    CityGenerator::generate_race_percentages($city);
    is(scalar(@{$city->{'race percentages'}}), 3);








    done_testing();
};


1;

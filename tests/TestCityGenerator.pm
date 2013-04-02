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

#TODO have a test that does an is_deeply on an entire structure.
#TODO any test where I'm setting $city->{} values should me moved to create_city()
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

    $city=CityGenerator::create_city({});
    CityGenerator::generate_city_name($city);
    is($city->{'name'},'Port Janville');

    $city=CityGenerator::create_city({'seed'=>20, 'name'=>'foo'});
    CityGenerator::generate_city_name($city);
    is($city->{'name'},'foo');

    done_testing();
};

subtest 'test set_city_size' => sub {
    my $city;
    set_seed(1);

    $city=CityGenerator::create_city({'seed'=>20});
    CityGenerator::set_city_size($city);
    is($city->{'size'},'small town');
    is($city->{'gplimit'},'1500');
    is($city->{'pop_estimate'},'1422');
    is($city->{'size_modifier'},'0');

    $city=CityGenerator::create_city({'seed'=>24,'name'=>'foo','size'=>'Detroitish','gplimit'=>'12345','pop_estimate'=>'10102','size_modifier'=>'3'});
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

    $city=CityGenerator::create_city({'seed'=>100});
    is($city->{'seed'}, '100');
    is($city->{'name'},'Bedhead Lock');
    is($city->{'stats'}->{'economy'},0);
    is($city->{'stats'}->{'education'},-2);
    is($city->{'stats'}->{'tolerance'},0);
    is($city->{'stats'}->{'authority'},-2);
    is($city->{'stats'}->{'magic'},6);
    is($city->{'stats'}->{'military'},0);
    is($city->{'order'},26);
    is($city->{'moral'},21);
    is($city->{'size'},'hamlet');
    is($city->{'gplimit'},500);
    is($city->{'pop_estimate'},185);
    is($city->{'size_modifier'},-4);
    is($city->{'region'}->{'name'}, undef);
    is($city->{'continent'}->{'name'}, undef);
    is($city->{'base_pop'},undef);
    is($city->{'type'},undef);
    is($city->{'description'},undef);
    is($city->{'add_other'},undef);
    is($city->{'wall_chance_roll'},undef);
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'height'},undef);
    is($city->{'walls'}->{'content'},undef);
    is($city->{'laws'}->{'enforcer'},undef);
    is($city->{'laws'}->{'enforcement'},undef);
    is($city->{'laws'}->{'punishment'},undef);
    is($city->{'laws'}->{'commoncrime'},undef);
    is($city->{'laws'}->{'trial'},undef);
    is($city->{'age_roll'},undef);
    is($city->{'age_description'},undef);
    is($city->{'age_mod'},undef);
    is($city->{'resourcecount'},undef);
    is($city->{'resources'},undef);
    is($city->{'crest'},undef);
    is($city->{'shape'},undef);
    is($city->{'city_age'},undef);
    is($city->{'available_races'},undef);
    is($city->{'race percentages'},undef);
    is($city->{'economy_description'},undef);
    is($city->{'education_description'},undef);
    is($city->{'tolerance_description'},undef);
    is($city->{'authority_description'},undef);
    is($city->{'magic_description'},undef);
    is($city->{'military_description'},undef);
    is($city->{'population_total'},undef);
    is($city->{'races'},undef);
    is($city->{'streets'}->{'content'},undef);
    is($city->{'streets'}->{'mainroads'},undef);
    is($city->{'streets'}->{'roads'},undef);
    is($city->{'area'},undef);
    is($city->{'density'},undef);
    is($city->{'feetpercapita'},undef);

    CityGenerator::flesh_out_city($city);

    #FIXME seeds for region and continent aren't right
    is($city->{'seed'}, '100');
    is($city->{'name'},'Bedhead Lock');
    is($city->{'stats'}->{'economy'},0);
    is($city->{'stats'}->{'education'},-2);
    is($city->{'stats'}->{'tolerance'},5);
    is($city->{'stats'}->{'authority'},-4);
    is($city->{'stats'}->{'magic'},1);
    is($city->{'stats'}->{'military'},5);
    is($city->{'order'},23);
    is($city->{'moral'},40);
    is($city->{'size'},'hamlet');
    is($city->{'gplimit'},500);
    is($city->{'pop_estimate'},185);
    is($city->{'size_modifier'},-4);
    is($city->{'region'}->{'name'}, 'Moolborak Region');
    is($city->{'continent'}->{'name'}, 'Mongar');
    is($city->{'base_pop'},'basic');
    is($city->{'type'},'basic');
    is($city->{'description'},'normal population');
    is($city->{'add_other'},'');
    is($city->{'wall_chance_roll'},89);
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'height'},0);
    is($city->{'walls'}->{'content'},'none');
    is_deeply($city->{'laws'},{ 'enforcer'=>'city guard', 
                                'enforcement'=>'but are loosely enforced', 
                                'punishment'=>'community service', 
                                'trial'=>'without trial','commoncrime'=>'petty theft'   });
    is($city->{'age_roll'},88);
    is($city->{'age_description'},'elderly');
    is($city->{'age_mod'},-8);
    is($city->{'resourcecount'},1);
    is($city->{'resources'}->[0]->{'content'},'timid caterpillar');
    is_deeply($city->{'crest'},{});
    is($city->{'shape'},'a circular');
    is($city->{'city_age'}->{'content'},'youthful');
    is_deeply($city->{'available_races'},[ 'human','half-elf','elf','halfling','half-orc','half-dwarf','gnome','dwarf']);
    is_deeply($city->{'race percentages'},[ 1,'11.9','32.8','37.9','6.1','6.9']);
    is($city->{'economy_description'},'stable');
    is($city->{'education_description'},'mocked');
    is($city->{'tolerance_description'},'is accepting of');
    is($city->{'authority_description'},'is chaotic');
    is($city->{'magic_description'},'instutionalized');
    is($city->{'military_description'},'positive');
    is($city->{'population_total'},185);
    is(scalar(@{$city->{'races'}}),7);
    is($city->{'streets'}->{'content'},'muddy cobblestone streets in a fragmented parallel pattern');
    is($city->{'streets'}->{'mainroads'},1);
    is($city->{'streets'}->{'roads'},2);
    is($city->{'area'},7.22);
    is($city->{'density_description'},'sparsely');
    is($city->{'feetpercapita'},4200);

    done_testing();
};


subtest 'test set_pop_type' => sub {
    my $city;
    set_seed(1);

    $city=CityGenerator::create_city();
    CityGenerator::set_pop_type($city);
    is($city->{'name'},'Port Janville');
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
    is($city->{'resourcecount'}, 8);
    is(@{$city->{'resources'}}, 8);

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
    is_deeply($city->{'crest'}, {});

    done_testing();
};


subtest 'test generate_base_stats' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_base_stats($city);
    is($city->{'stats'}->{'education'}, -4);
    is($city->{'stats'}->{'authority'}, 0);
    is($city->{'stats'}->{'magic'}    , 5);
    is($city->{'stats'}->{'military'} , -1);
    is($city->{'stats'}->{'tolerance'}, 2);
    is($city->{'stats'}->{'economy'}  , -4);


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
    is(scalar(@{$city->{'available_races'}}), 13);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'basic'});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available_races'}}), 8);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'mixed'});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available_races'}}), 23);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'mixed', 'available_races'=>[2,2,2]});
    CityGenerator::set_available_races($city);
    is(scalar(@{$city->{'available_races'}}), 3);

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


subtest 'test set_stat_descriptions' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({});
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'flourishing');
    is($city->{'authority_description'}, 'is very strict');
    is($city->{'magic_description'}    , 'flourishing');
    is($city->{'military_description'} , 'laid back');
    is($city->{'tolerance_description'}, 'loves');
    is($city->{'economy_description'}  , 'resiliant');

    set_seed(1);
    $city=CityGenerator::create_city({ 'stats'=>{ 'education'=>0, 'authority'=>0, 'magic'=>0,
                                        'military'=>0,  'tolerance'=>0, 'economy'=>0}});
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'mediocre');
    is($city->{'authority_description'}, 'ignores');
    is($city->{'magic_description'}    , 'allowed');
    is($city->{'military_description'} , 'laid back');
    is($city->{'tolerance_description'}, 'ignores');
    is($city->{'economy_description'}  , 'resiliant');

    set_seed(1);
    $city=CityGenerator::create_city({  'education_description'=>'foo1','authority_description'=>'foo2','magic_description'=>'foo3',
                                        'military_description'=>'foo4','tolerance_description'=>'foo5','economy_description'=>'foo6'});
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'foo1');
    is($city->{'authority_description'}, 'foo2');
    is($city->{'magic_description'}    , 'foo3');
    is($city->{'military_description'} , 'foo4');
    is($city->{'tolerance_description'}, 'foo5');
    is($city->{'economy_description'}  , 'foo6');

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'} = undef;
    $city->{'stats'}->{'authority'} = undef;
    $city->{'stats'}->{'magic'}     = undef;
    $city->{'stats'}->{'military'}  = undef;
    $city->{'stats'}->{'tolerance'} = undef;
    $city->{'stats'}->{'economy'}   = undef;
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'mediocre');
    is($city->{'authority_description'}, 'ignores');
    is($city->{'magic_description'}    , 'allowed');
    is($city->{'military_description'} , 'laid back');
    is($city->{'tolerance_description'}, 'ignores');
    is($city->{'economy_description'}  , 'resiliant');

    done_testing();
};


subtest 'test set_races' => sub {
    my $city;
    $city=CityGenerator::create_city({ 'seed'=>1,
                                        'available_races'=>['dwarf','human','halfling'],
                                        'race percentages'=>[85,10,3], 
                                        'pop_estimate'=>100   });
    CityGenerator::set_races($city);
    is_deeply($city->{'races'},[ 
                                    { 'race' => 'human',    'percent' => 85, 'population' => 85 },
                                    { 'race' => 'halfling', 'percent' => 10, 'population' => 10 },
                                    { 'race' => 'dwarf',    'percent' => 3,  'population' => 3 },
                                    { 'race' => 'other',    'percent' => 2,  'population' => 2 }
                                ] );
    
    
    $city=CityGenerator::create_city({'seed'=>1,'races'=> [ 
                         { 'race' => 'human',    'percent' => 85, 'population' => 85 },
                         { 'race' => 'halfling', 'percent' => 10, 'population' => 10 },
                         { 'race' => 'dwarf',    'percent' => 3,  'population' => 3 },
                         { 'race' => 'other',    'percent' => 2,  'population' => 2 }
                       ]});
    CityGenerator::set_races($city);
    is_deeply($city->{'races'},[ 
                                    { 'race' => 'human',    'percent' => 85, 'population' => 85 },
                                    { 'race' => 'halfling', 'percent' => 10, 'population' => 10 },
                                    { 'race' => 'dwarf',    'percent' => 3,  'population' => 3 },
                                    { 'race' => 'other',    'percent' => 2,  'population' => 2 }
                                ] );


    $city=CityGenerator::create_city({ 'seed'=>1,
                                        'available_races'=>['dwarf','human','halfling','half-orc'],
                                        'race percentages'=>[30,30,20,15], 
                                        'pop_estimate'=>100   });

    CityGenerator::set_races($city);
    is_deeply($city->{'races'},[ 
                                    { 'race' => 'human',    'percent' => 30, 'population' => 30 },
                                    { 'race' => 'halfling', 'percent' => 30, 'population' => 30 },
                                    { 'race' => 'dwarf',    'percent' => 20, 'population' => 20 },
                                    { 'race' => 'half-orc', 'percent' => 15, 'population' => 15 },
                                    { 'race' => 'other',    'percent' =>  5, 'population' =>  5 }
                                ] );

    done_testing();
};

subtest 'test assign_race_stats' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({ 'stats'=>{   'education'=>0, 'authority'=>0, 'magic'=>0,
                                                    'military'=>0,  'tolerance'=>0, 'economy'=>0},
                                        'races' => [ 
                                             { 'race' => 'human',    'percent' => 85, 'population' => 85 },
                                             { 'race' => 'halfling', 'percent' => 10, 'population' => 10 },
                                             { 'race' => 'dwarf',    'percent' => 3,  'population' => 3 },
                                             { 'race' => 'other',    'percent' => 2,  'population' => 2 }
                                        ]}); 
    CityGenerator::assign_race_stats($city);
    
    is($city->{'races'}->[0]->{'race'}, 'human');
    is($city->{'races'}->[0]->{'education'}, 2);
    is($city->{'races'}->[0]->{'authority'}, 1);
    is($city->{'races'}->[0]->{'magic'},     0);
    is($city->{'races'}->[0]->{'military'},  1);
    is($city->{'races'}->[0]->{'tolerance'}, 3);
    is($city->{'races'}->[0]->{'economy'},   1);



    is($city->{'races'}->[1]->{'race'}, 'halfling');
    is($city->{'races'}->[2]->{'race'}, 'dwarf');
    is($city->{'races'}->[3]->{'race'}, 'other');
    is($city->{'stats'}->{'education'}, 3);
    is($city->{'stats'}->{'authority'}, 1);
    is($city->{'stats'}->{'magic'},     -3);
    is($city->{'stats'}->{'military'},  3);
    is($city->{'stats'}->{'tolerance'}, 5);
    is($city->{'stats'}->{'economy'},   3);

    is($city->{'moral'}, 98);
    is($city->{'order'}, 77);

    done_testing();
};

subtest 'test generate_alignment' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>'1'});
    is($city->{'order'}, 5);
    is($city->{'moral'}  , 46);

    $city=CityGenerator::create_city({'seed'=>'1','order'=>50,'moral'=>50});
    is($city->{'order'}, 50);
    is($city->{'moral'}  , 50);

    $city=CityGenerator::create_city({'seed'=>'1','order'=>-14,'moral'=>-12});
    is($city->{'order'}, 0);
    is($city->{'moral'}  , 0);

    $city=CityGenerator::create_city({'seed'=>'1','order'=>114,'moral'=>112});
    is($city->{'order'}, 100);
    is($city->{'moral'}  , 100);

    done_testing();
};


subtest 'test recalculate_populations' => sub {
    my $city;
    $city=CityGenerator::create_city({ 'seed'=>1,
                                        'available_races'=>['dwarf','human','halfling'],
                                        'race percentages'=>[85,10,3], 
                                        'pop_estimate'=>93   });
    CityGenerator::set_races($city);
    is_deeply($city->{'races'},[ 
                                    { 'race' => 'human',    'percent' => 85, 'population' => 79 },
                                    { 'race' => 'halfling', 'percent' => 10, 'population' => 9 },
                                    { 'race' => 'dwarf',    'percent' => 3,  'population' => 2 },
                                    { 'race' => 'other',    'percent' => 2,  'population' => 3 }
                                ] );
    CityGenerator::recalculate_populations($city);
    
    is($city->{'population_total'}, 93);
    is_deeply($city->{'races'},[ 
                                    { 'race' => 'human',    'percent' => 84.9,  'population' => 79 },
                                    { 'race' => 'halfling', 'percent' => 9.6,    'population' => 9 },
                                    { 'race' => 'dwarf',    'percent' => 2.1,   'population' => 2 },
                                    { 'race' => 'other',    'percent' => 3.2,   'population' => 3 }
                                ] );

    done_testing();
};

subtest 'test generate_streets' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>4});
    CityGenerator::generate_streets($city);

    is($city->{'streets'}->{'content'}, 'rough dirt tracks in an irregular pattern');
    is($city->{'streets'}->{'mainroads'}, 1);
    is($city->{'streets'}->{'roads'}, 2);

    $city=CityGenerator::create_city({'seed'=>1,'streets'=>{'content'=>'foo','mainroads'=>-1,'roads'=>-1}});
    CityGenerator::generate_streets($city);
    is($city->{'streets'}->{'content'}, 'foo');
    is($city->{'streets'}->{'mainroads'}, 0);
    is($city->{'streets'}->{'roads'}, 1);

    $city=CityGenerator::create_city({'seed'=>1,'streets'=>{'content'=>'foo','mainroads'=>-1,'roads'=>-1}});
    CityGenerator::generate_streets($city);
    is($city->{'streets'}->{'content'}, 'foo');
    is($city->{'streets'}->{'mainroads'}, 0);
    is($city->{'streets'}->{'roads'}, 1);

    $city=CityGenerator::create_city({'seed'=>1,'streets'=>{'content'=>'foo','mainroads'=>5,'roads'=>5}});
    CityGenerator::generate_streets($city);
    is($city->{'streets'}->{'content'}, 'foo');
    is($city->{'streets'}->{'mainroads'}, 5);
    is($city->{'streets'}->{'roads'}, 5);

    done_testing();
};

subtest 'test generate_area feet' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'population_total'=>1000,'feetpercapita'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 9.29);
    is($city->{'support_area'}, 4.78);
    is($city->{'arable_percentage'}, 65);
    is($city->{'people_per_square_mile'}, 209);

    set_seed(1);
    $city=CityGenerator::create_city({'population_total'=>1000,'feetpercapita'=>1500,'arable_percentage'=>100,'people_per_square_mile'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 13.94);
    is($city->{'arable_percentage'}, 100);
    is($city->{'people_per_square_mile'}, 1000);
    is($city->{'support_area'}, '1.00');

    set_seed(1);
    $city=CityGenerator::create_city({'population_total'=>1000,'feetpercapita'=>3000, 'support_area'=>100});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 27.87);
    is($city->{'support_area'}, 100);

    done_testing();
};

subtest 'test generate_area poptool' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'population_total'=>1000,'feetpercapita'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 9.29);
    is($city->{'support_area'}, 4.78);

    set_seed(1);
    $city=CityGenerator::create_city({'population_total'=>2000,'feetpercapita'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 18.58);
    is($city->{'support_area'}, 9.57);

    set_seed(1);
    $city=CityGenerator::create_city({'population_total'=>3000,'feetpercapita'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 27.87);
    is($city->{'support_area'}, 14.35);

    done_testing();
};

subtest 'test generate_popdensity' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({});
    CityGenerator::generate_popdensity($city);
    is($city->{'density_description'}, 'lightly');
    is($city->{'feetpercapita'}, '3200');

    set_seed(1);
    $city=CityGenerator::create_city({'density_description'=>'nominally'});
    CityGenerator::generate_popdensity($city);
    is($city->{'density_description'}, 'nominally');
    is($city->{'feetpercapita'}, '3200');

    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>2,'density_description'=>'lightly', 'feetpercapita'=>1233});
    CityGenerator::generate_popdensity($city);
    is($city->{'density_description'}, 'lightly');
    is($city->{'feetpercapita'}, '1233');

    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>2, 'feetpercapita'=>1233});
    CityGenerator::generate_popdensity($city);
    is($city->{'density_description'}, 'densely');
    is($city->{'feetpercapita'}, '1233');


    done_testing();
};


subtest 'test generate_citizens' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 7);
    is(scalar(@{$city->{'citizens'}}), 7);
    is($city->{'citizens'}->[0]->{'race'}, 'drow');
    is($city->{'citizens'}->[1]->{'race'}, 'ogre');
    is($city->{'citizens'}->[2]->{'race'}, 'half-dwarf');

    $city=CityGenerator::create_city({'size_modifier'=>-5});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 5);
    is(scalar(@{$city->{'citizens'}}), 5);
    is($city->{'citizens'}->[0]->{'race'}, 'minotaur');
    is($city->{'citizens'}->[1]->{'race'}, 'half-elf');
    is($city->{'citizens'}->[2]->{'race'}, 'half-elf');

    $city=CityGenerator::create_city({'size_modifier'=>12});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 13);
    is(scalar(@{$city->{'citizens'}}), 13);
    is($city->{'citizens'}->[0]->{'race'}, 'half-orc');
    is($city->{'citizens'}->[1]->{'race'}, 'minotaur');
    is($city->{'citizens'}->[2]->{'race'}, 'dwarf');

    $city=CityGenerator::create_city({'size_modifier'=>12, 'citizen_count'=>2});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 2);
    is(scalar(@{$city->{'citizens'}}), 2);
    is($city->{'citizens'}->[0]->{'race'}, 'goblin');
    is($city->{'citizens'}->[1]->{'race'}, 'human');
    is($city->{'citizens'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'size_modifier'=>12, 'citizen_count'=>2, 'citizens'=>[] });
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 2);
    is(scalar(@{$city->{'citizens'}}), 0);

#TODO test if they're a specialist, once I add specialists
    done_testing();
};


subtest 'test generate_travelers' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 9);
    is(scalar(@{$city->{'travelers'}}), 9);
    is($city->{'travelers'}->[0]->{'race'}, 'drow');
    is($city->{'travelers'}->[1]->{'race'}, 'ogre');
    is($city->{'travelers'}->[2]->{'race'}, 'half-dwarf');

    set_seed(1);
    $city=CityGenerator::create_city({'stats'=>{'tolerance'=>-5}});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 0);
    is(scalar(@{$city->{'travelers'}}), 0);
    is($city->{'travelers'}->[0]->{'race'}, undef);

    set_seed(1);
    $city=CityGenerator::create_city({'stats'=>{'tolerance'=>0}});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 5);
    is(scalar(@{$city->{'travelers'}}), 5);
    is($city->{'travelers'}->[0]->{'race'}, 'drow');
    is($city->{'travelers'}->[1]->{'race'}, 'ogre');
    is($city->{'travelers'}->[2]->{'race'}, 'half-dwarf');

    set_seed(1);
    $city=CityGenerator::create_city({'stats'=>{'tolerance'=>0}});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 5);
    is(scalar(@{$city->{'travelers'}}), 5);
    is($city->{'travelers'}->[0]->{'race'}, 'drow');
    is($city->{'travelers'}->[1]->{'race'}, 'ogre');
    is($city->{'travelers'}->[2]->{'race'}, 'half-dwarf');

    set_seed(1);
    $city=CityGenerator::create_city({'size_modifier'=>12, 'traveler_count'=>2});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 2);
    is(scalar(@{$city->{'travelers'}}), 2);
    is($city->{'travelers'}->[0]->{'race'}, 'drow');
    is($city->{'travelers'}->[1]->{'race'}, 'ogre');
    is($city->{'travelers'}->[2]->{'race'}, undef);

    set_seed(1);
    $city=CityGenerator::create_city({'size_modifier'=>12, 'traveler_count'=>2, 'stats'=>{'tolerance'=>5}});
    CityGenerator::generate_travelers($city);
    is_deeply($city->{'available_traveler_races'}, [ 'human', 'bugbear', 'mindflayer', 'lizardfolk', 'minotaur', 'half-elf', 'hobgoblin', 'elf', 'troglodyte', 'drow', 'lycanthrope', 'halfling', 'half-orc', 'kobold', 'any', 'deep dwarf', 'half-dwarf', 'orc', 'gnome', 'other', 'goblin', 'dwarf', 'ogre']);

    set_seed(1);
    $city=CityGenerator::create_city({'size_modifier'=>12, 'traveler_count'=>2, 'stats'=>{'tolerance'=>-5}, 'available_races'=>[ 'human','half-elf','elf','halfling','half-orc','half-dwarf','gnome','dwarf']});
    CityGenerator::generate_travelers($city);
    is_deeply($city->{'available_traveler_races'},[ 'human','half-elf','elf','halfling','half-orc','half-dwarf','gnome','dwarf']);


    set_seed(1);
    $city=CityGenerator::create_city({'size_modifier'=>12, 'traveler_count'=>2, 'travelers'=>[] });
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 2);
    is(scalar(@{$city->{'travelers'}}), 0);


    set_seed(1);
    $city=CityGenerator::create_city({'size_modifier'=>12, 'traveler_count'=>6, 'available_traveler_races'=>['human'] });
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 6);
    is($city->{'travelers'}->[0]->{'race'}, 'human');
    is($city->{'travelers'}->[1]->{'race'}, 'human');
    is($city->{'travelers'}->[2]->{'race'}, 'human');
    is($city->{'travelers'}->[3]->{'race'}, 'human');
    is($city->{'travelers'}->[4]->{'race'}, 'human');
    is($city->{'travelers'}->[5]->{'race'}, 'human');


#TODO test if they're a specialist, once I add specialists
    done_testing();
};


subtest 'test generate_crime' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({});
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 64);
    is($city->{'crime_description'}, 'unusual');

    set_seed(1);
    $city=CityGenerator::create_city({'crime_roll'=>99});
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 99);
    is($city->{'crime_description'}, 'unheard of');

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'}=0;
    $city->{'stats'}->{'authority'}=0;
    $city->{'moral'}=50;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 59);
    is($city->{'crime_description'}, 'unusual');

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'}=0;
    $city->{'stats'}->{'authority'}=0;
    $city->{'moral'}=100;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 64);

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'}=5;
    $city->{'stats'}->{'authority'}=0;
    $city->{'moral'}=50;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 54);

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'}=0;
    $city->{'stats'}->{'authority'}=5;
    $city->{'moral'}=50;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 64);

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'}=5;
    $city->{'stats'}->{'authority'}=-5;
    $city->{'moral'}=0;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 44);

    set_seed(1);
    $city=CityGenerator::create_city();
    $city->{'stats'}->{'education'}=-5;
    $city->{'stats'}->{'authority'}=5;
    $city->{'moral'}=100;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 74);

    set_seed(1);
    $city=CityGenerator::create_city({'crime_description'=>'fun'});
    CityGenerator::generate_crime($city);
    is($city->{'crime_description'}, 'fun');

    done_testing();
};


subtest 'test set_dominance' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({});
    $city->{'available_races'}= ['dwarf','human','halfling'];
    $city->{'race percentages'}= [85,10,3];

    $city->{'pop_estimate'}=93;
    CityGenerator::set_races($city);
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, 76);
    is($city->{'dominant_race'}, undef);
    is($city->{'dominance_level'}, undef);
    is($city->{'dominance_description'}, undef);

    $city->{'dominance_chance'}     =1;
    $city->{'dominant_race'}        =undef;
    $city->{'dominance_level'}      =undef;
    $city->{'dominance_description'}=undef;
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, 1);
    is($city->{'dominant_race'}, 'dwarf');
    is($city->{'dominance_level'}, 87);
    is($city->{'dominance_description'}, 'brutally oppressive');

    $city->{'dominance_chance'}     =90;
    $city->{'dominant_race'}        =undef;
    $city->{'dominance_level'}      =undef;
    $city->{'dominance_description'}=undef;
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, '90');
    is($city->{'dominant_race'}, undef);
    is($city->{'dominance_level'}, undef);
    is($city->{'dominance_description'}, undef);

    $city->{'dominance_chance'}     =5;
    $city->{'dominant_race'}        =undef;
    $city->{'dominance_level'}      =50;
    $city->{'dominance_description'}=undef;
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, 5);
    is($city->{'dominant_race'}, 'dwarf');
    is($city->{'dominance_level'}, 50);
    is($city->{'dominance_description'}, 'cruel');

    $city->{'dominance_chance'}     =5;
    $city->{'dominant_race'}        ='human';
    $city->{'dominance_level'}      =50;
    $city->{'dominance_description'}='smelly';
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, 5);
    is($city->{'dominant_race'}, 'human');
    is($city->{'dominance_level'}, 50);
    is($city->{'dominance_description'}, 'smelly');

    done_testing();
};


subtest 'test generate_children' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>0});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'33.00','population'=>'330'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'38.00','population'=>'380'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'children'=>{'population'=>400}});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'40.00','population'=>'400'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'children'=>{'percent'=>25, }});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'25','population'=>'380'});

    done_testing();
};

subtest 'test generate_elderly' => sub {
    my $city;
    set_seed(1);
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>0});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'11.00','population'=>'110'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'16.00','population'=>'160'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'elderly'=>{'population'=>400}});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'40.00','population'=>'400'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'elderly'=>{'percent'=>25, }});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'25','population'=>'160'});

    done_testing();
};




1;


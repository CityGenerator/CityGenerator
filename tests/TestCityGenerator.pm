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
#TODO consider die statements if requirements are no defined; die 'foo requires poptotal' if (!defined poptotal);
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
    is($city->{'min_density'},'100');
    is($city->{'max_density'},'9000');

    $city=CityGenerator::create_city({'seed'=>24,'dummy'=>'test'});
    is($city->{'seed'},24);
    is($city->{'dummy'},'test');
    is($city->{'name'},'Eisenbridge');

    $city=CityGenerator::create_city({'seed'=>24,'name'=>'foo','size'=>'Detroitish','gplimit'=>'12345','pop_estimate'=>'10102','size_modifier'=>'3', 'min_density'=>30, 'max_density'=>'3000'});
    is($city->{'seed'},24);
    is($city->{'name'},'foo');
    is($city->{'size'},'Detroitish');
    is($city->{'gplimit'},'12345');
    is($city->{'pop_estimate'},'10102');
    is($city->{'size_modifier'},'3');
    is($city->{'min_density'},'30');
    is($city->{'max_density'},'3000');

    done_testing();
};


subtest 'test generate_city_name' => sub {
    my $city;

    $city=CityGenerator::create_city({'seed'=>1});
    CityGenerator::generate_city_name($city);
    is($city->{'name'},'Grisnow');

    $city=CityGenerator::create_city({'seed'=>20, 'name'=>'foo'});
    CityGenerator::generate_city_name($city);
    is($city->{'name'},'foo');

    done_testing();
};

subtest 'test set_city_size' => sub {
    my $city;

    $city=CityGenerator::create_city({'seed'=>20});
    CityGenerator::set_city_size($city);
    is($city->{'size'},'small town');
    is($city->{'gplimit'},'1500');
    is($city->{'pop_estimate'},'1422');
    is($city->{'size_modifier'},'0');
    is($city->{'age_roll'},59);
    is($city->{'age_description'},'modern');
    is($city->{'age_mod'},0);

    $city=CityGenerator::create_city({'seed'=>24,'name'=>'foo','size'=>'Detroitish','gplimit'=>'12345','pop_estimate'=>'10102','size_modifier'=>'3'});
    CityGenerator::set_city_size($city);
    is($city->{'size'},'Detroitish');
    is($city->{'gplimit'},'12345');
    is($city->{'pop_estimate'},'10102');
    is($city->{'size_modifier'},'3');
    is($city->{'age_roll'},11);
    is($city->{'age_description'},'youthful');
    is($city->{'age_mod'},8);

    done_testing();
};

subtest 'test flesh_out_city' => sub {
    my $city;

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
    is($city->{'density_description'},undef);
    is($city->{'population_density'},undef);

    CityGenerator::flesh_out_city($city);

    #FIXME seeds for region and continent aren't right
    is($city->{'seed'}, '100');
    is($city->{'name'},'Bedhead Lock');
    is($city->{'stats'}->{'economy'},0);
    is($city->{'stats'}->{'education'},-1);
    is($city->{'stats'}->{'tolerance'},5);
    is($city->{'stats'}->{'authority'},-5);
    is($city->{'stats'}->{'magic'},5);
    is($city->{'stats'}->{'military'},5);
    is($city->{'order'},24);
    is($city->{'moral'},47);
    is($city->{'size'},'hamlet');
    is($city->{'gplimit'},500);
    is($city->{'pop_estimate'},185);
    is($city->{'size_modifier'},-4);
    is($city->{'region'}->{'name'}, 'Marran Region');
    is($city->{'continent'}->{'name'}, 'Anbel');
    is($city->{'base_pop'},'basic');
    is($city->{'type'},'basic');
    is($city->{'description'},'normal population');
    is($city->{'add_other'},'');
    is($city->{'wall_chance_roll'},46);
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'height'},0);
    is($city->{'walls'}->{'content'},'none');
    is_deeply($city->{'laws'},{ 'enforcer'=>'neighborhood watch', 
                                'enforcement'=>'who can be bribed', 
                                'punishment'=>'an eye for an eye', 
                                'trial'=>'by a kangaroo court','commoncrime'=>'fraud'   });
    is($city->{'age_roll'},22);
    is($city->{'age_description'},'new');
    is($city->{'age_mod'},5);
    is($city->{'resourcecount'},1);
    is($city->{'resources'}->[0]->{'content'},'timid caterpillar');
    is_deeply($city->{'crest'},{});
    is($city->{'shape'},'an oval');
    is($city->{'city_age'}->{'content'},'new');
    is_deeply($city->{'available_races'},[ 'human','half-elf','elf','halfling','half-orc','half-dwarf','gnome','dwarf']);
    is_deeply($city->{'race percentages'},[ 1,'1.5','15.6','25.1','55.7']);
    is($city->{'economy_description'},'insulated');
    is($city->{'education_description'},'allowed, but not enforced');
    is($city->{'tolerance_description'},'accepts');
    is($city->{'authority_description'},'is chaotic');
    is($city->{'magic_description'},'accepted');
    is($city->{'military_description'},'positive');
    is($city->{'population_total'},185);
    is(scalar(@{$city->{'races'}}),6);
    is($city->{'streets'}->{'content'},'pristine cobblestone paths in a looped pattern');
    is($city->{'streets'}->{'mainroads'},1);
    is($city->{'streets'}->{'roads'},2);
    is($city->{'area'},0.36);
    is($city->{'density_description'},'lightly');
    is($city->{'population_density'},518);

    done_testing();
};


subtest 'test set_pop_type' => sub {
    my $city;

    $city=CityGenerator::create_city({'seed'=>1});
    CityGenerator::set_pop_type($city);
    is($city->{'name'},'Grisnow');
    is($city->{'base_pop'},'basic');
    is($city->{'type'},'basic');
    is($city->{'description'},'normal population');
    is($city->{'add_other'},'');
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
    $city=CityGenerator::create_city({'seed'=>'1','area'=>1.9});
    CityGenerator::generate_walls($city);
    is($city->{'size_modifier'},'-5');
    is($city->{'wall_chance_roll'},'30');
    is($city->{'wall_size_roll'},41);
    is($city->{'walls'}->{'content'},'massive wood rampart');
    is($city->{'walls'}->{'height'},'24');

    $city=CityGenerator::create_city({'seed'=>'2', 'area'=>1.9});
    CityGenerator::generate_walls($city);
    is($city->{'size_modifier'},'8');
    is($city->{'wall_chance_roll'},'52');
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'content'},'none');
    is($city->{'walls'}->{'height'},'0');
#FIXME  this should use wall_size_roll to test rather than seed=>2
    $city={};
    $city=CityGenerator::create_city({'seed'=>'2', 'size_modifier'=>'0', 'area'=>1.9});
    CityGenerator::generate_walls($city);
    is($city->{'size_modifier'},0); # FIXME originally set to undef, was I testing an if?
    is($city->{'wall_chance_roll'},'92');
    is($city->{'wall_size_roll'},undef);
    is($city->{'walls'}->{'content'},'none');
    is($city->{'walls'}->{'height'},'0');


    done_testing();
};

subtest 'test generate_watchtowers' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>'1', 'walls'=>{'length'=> 1.9 }});
    CityGenerator::generate_watchtowers($city);
    is($city->{'watchtowers'}->{'count'},5);


    done_testing();
};

subtest 'test set_laws' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::set_laws($city);
    is($city->{'laws'}->{'punishment'}, 'fines');
    is($city->{'laws'}->{'enforcement'}, 'who can be bribed');
    is($city->{'laws'}->{'trial'}, 'by a magistrate');
    is($city->{'laws'}->{'enforcer'}, 'city watch');
    is($city->{'laws'}->{'commoncrime'}, 'murder');

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
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::set_age($city);
    is($city->{'age_description'}, 'young');
    is($city->{'age_mod'}, '10');
    is($city->{'age_roll'}, '0');

    $city=CityGenerator::create_city({'seed'=>'1', 'age_description'=>'foo','age_mod'=>12, 'age_roll'=>'1'   } );
    CityGenerator::set_age($city);
    is($city->{'age_description'}, 'foo');
    is($city->{'age_mod'}, '12');
    is($city->{'age_roll'}, '1');

    done_testing();
};


subtest 'test generate_resources' => sub {
    my $city;
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
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_city_crest($city);
    is_deeply($city->{'crest'}, {});

    done_testing();
};


subtest 'test generate_base_stats' => sub {
    my $city;
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
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_shape($city);
    is($city->{'shape'},'a circular');

    $city=CityGenerator::create_city({'seed'=>'1','shape'=>'fool'});
    CityGenerator::generate_shape($city);
    is($city->{'shape'},'fool');

    done_testing();
};

subtest 'test generate_city_age' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>'1'});
    CityGenerator::generate_city_age($city);
    is($city->{'city_age'}->{'content'},'young');

    $city=CityGenerator::create_city({'seed'=>'1','city_age'=>{ 'content'=>'new'   }});
    CityGenerator::generate_city_age($city);
    is($city->{'city_age'}->{'content'},'new');

    done_testing();
};

subtest 'test set_available_races' => sub {
    my $city;
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
    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'monster'});
    CityGenerator::generate_race_percentages($city);
    is(scalar(@{$city->{'race percentages'}}), 6);

    $city=CityGenerator::create_city({'seed'=>'3', 'base_pop'=>'monster'});
    CityGenerator::generate_race_percentages($city);
    is(scalar(@{$city->{'race percentages'}}), 3);

    $city=CityGenerator::create_city({'seed'=>'1', 'base_pop'=>'monster', 'race percentages'=>[75,20,4]});
    CityGenerator::generate_race_percentages($city);
    is(scalar(@{$city->{'race percentages'}}), 3);

    done_testing();
};


subtest 'test set_stat_descriptions' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1});
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'rare');
    is($city->{'authority_description'}, 'is neutral towards');
    is($city->{'magic_description'}    , 'plentiful');
    is($city->{'military_description'} , 'laid back');
    is($city->{'tolerance_description'}, 'is accepting of');
    is($city->{'economy_description'}  , 'shaky');

    $city=CityGenerator::create_city({ 'seed'=>1, 'stats'=>{ 'education'=>0, 'authority'=>0, 'magic'=>0,
                                        'military'=>0,  'tolerance'=>0, 'economy'=>0}});
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'allowed, but not enforced');
    is($city->{'authority_description'}, 'is neutral towards');
    is($city->{'magic_description'}    , 'rare but accepted');
    is($city->{'military_description'} , 'laid back');
    is($city->{'tolerance_description'}, 'is neutral towards');
    is($city->{'economy_description'}  , 'unwavering');

    $city=CityGenerator::create_city({'seed'=>1,  'education_description'=>'foo1','authority_description'=>'foo2','magic_description'=>'foo3',
                                        'military_description'=>'foo4','tolerance_description'=>'foo5','economy_description'=>'foo6'});
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'foo1');
    is($city->{'authority_description'}, 'foo2');
    is($city->{'magic_description'}    , 'foo3');
    is($city->{'military_description'} , 'foo4');
    is($city->{'tolerance_description'}, 'foo5');
    is($city->{'economy_description'}  , 'foo6');

    $city=CityGenerator::create_city({'seed'=>1});
    $city->{'stats'}->{'education'} = undef;
    $city->{'stats'}->{'authority'} = undef;
    $city->{'stats'}->{'magic'}     = undef;
    $city->{'stats'}->{'military'}  = undef;
    $city->{'stats'}->{'tolerance'} = undef;
    $city->{'stats'}->{'economy'}   = undef;
    CityGenerator::set_stat_descriptions($city);
    is($city->{'education_description'}, 'allowed, but not enforced');
    is($city->{'authority_description'}, 'is neutral towards');
    is($city->{'magic_description'}    , 'rare but accepted');
    is($city->{'military_description'} , 'laid back');
    is($city->{'tolerance_description'}, 'is neutral towards');
    is($city->{'economy_description'}  , 'unwavering');

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
                                    { 'race' => 'dwarf',    'percent' => 85, 'population' => 85 },
                                    { 'race' => 'halfling', 'percent' => 10, 'population' => 10 },
                                    { 'race' => 'human',    'percent' => 3,  'population' => 3 },
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
                                    { 'race' => 'dwarf',    'percent' => 30, 'population' => 30 },
                                    { 'race' => 'human', 'percent' => 30, 'population' => 30 },
                                    { 'race' => 'halfling',    'percent' => 20, 'population' => 20 },
                                    { 'race' => 'half-orc', 'percent' => 15, 'population' => 15 },
                                    { 'race' => 'other',    'percent' =>  5, 'population' =>  5 }
                                ] );

    done_testing();
};

subtest 'test assign_race_stats' => sub {
    my $city;
    $city=CityGenerator::create_city({ 'seed'=>1,
                                        'stats'=>{   'education'=>0, 'authority'=>0, 'magic'=>0,
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

    is($city->{'moral'}, 58);
    is($city->{'order'}, 14);

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
                                    { 'race' => 'dwarf',    'percent' => 85, 'population' => 79 },
                                    { 'race' => 'halfling', 'percent' => 10, 'population' => 9 },
                                    { 'race' => 'human',    'percent' => 3,  'population' => 2 },
                                    { 'race' => 'other',    'percent' => 2,  'population' => 3 }
                                ] );
    CityGenerator::recalculate_populations($city);
    
    is($city->{'population_total'}, 93);
    is_deeply($city->{'races'},[ 
                                    { 'race' => 'dwarf',    'percent' => 84.9,  'population' => 79 },
                                    { 'race' => 'halfling', 'percent' => 9.6,    'population' => 9 },
                                    { 'race' => 'human',    'percent' => 2.1,   'population' => 2 },
                                    { 'race' => 'other',    'percent' => 3.2,   'population' => 3 }
                                ] );

    done_testing();
};

subtest 'test generate_streets' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>4});
    CityGenerator::generate_streets($city);

    is($city->{'streets'}->{'content'}, 'even dirt roads in an organic pattern');
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

subtest 'test generate_area' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>1000,'population_density'=>100});
    CityGenerator::generate_area($city);
    is($city->{'area'}, '10.00');
    is($city->{'arable_percentage'}, 2);
    is($city->{'arable_description'}, 'desolate');

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>1000,'population_density'=>100, protected_percent=>'100', 'protected_area'=>9.29});
    #FIXME Why is the support area different? between this and the one above?
    CityGenerator::generate_area($city);
    is($city->{'area'}, '10.00');
    is($city->{'arable_percentage'}, 2);
    is($city->{'arable_description'}, 'desolate');


    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>1000,'population_density'=>150,'arable_percentage'=>100,'arable_description'=>'meh'});
    CityGenerator::generate_area($city);
    is($city->{'area'}, 6.67);
    is($city->{'arable_percentage'}, 100);
    is($city->{'arable_description'}, 'meh');

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>1000,'population_density'=>300, });
    CityGenerator::generate_area($city);
    is($city->{'area'}, 3.33);

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>1000,'population_density'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, '1.00');

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>2000,'population_density'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, '2.00');

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>3000,'population_density'=>1000});
    CityGenerator::generate_area($city);
    is($city->{'area'}, '3.00');

    done_testing();
};

subtest 'test generate_popdensity' => sub {
    my $city;
    $city=CityGenerator::create_city({ 'seed'=>1,  'population_total'=>'10000' });
    CityGenerator::generate_popdensity($city);
    is($city->{'population_density'}, 27);
    is($city->{'density_description'}, 'sparsely');

    $city=CityGenerator::create_city({ 'seed'=>1,  'population_total'=>'10000', 'population_density'=>20000 });
    CityGenerator::generate_popdensity($city);
    is($city->{'population_density'}, 20000);
    is($city->{'density_description'}, 'densely');

    $city=CityGenerator::create_city({ 'seed'=>1,  'population_total'=>'10000', 'population_density'=>10000, 'density_description'=>'dovey' });
    CityGenerator::generate_popdensity($city);
    is($city->{'population_density'}, 10000);
    is($city->{'density_description'}, 'dovey');

    done_testing();
};


subtest 'test generate_citizens' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, });
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 5);
    is(scalar(@{$city->{'citizens'}}), 5);
    isnt($city->{'citizens'}->[0]->{'race'}, undef);
    isnt($city->{'citizens'}->[1]->{'race'}, undef);
    isnt($city->{'citizens'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'size_modifier'=>-5});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 5);
    is(scalar(@{$city->{'citizens'}}), 5);
    isnt($city->{'citizens'}->[0]->{'race'}, undef);
    isnt($city->{'citizens'}->[1]->{'race'}, undef);
    isnt($city->{'citizens'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'size_modifier'=>12});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 13);
    is(scalar(@{$city->{'citizens'}}), 13);
    isnt($city->{'citizens'}->[0]->{'race'}, undef);
    isnt($city->{'citizens'}->[1]->{'race'}, undef);
    isnt($city->{'citizens'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'size_modifier'=>12, 'citizen_count'=>2});
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 2);
    is(scalar(@{$city->{'citizens'}}), 2);
    isnt($city->{'citizens'}->[0]->{'race'}, undef);
    isnt($city->{'citizens'}->[1]->{'race'}, undef);
    is($city->{'citizens'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'size_modifier'=>12, 'citizen_count'=>2, 'citizens'=>[] });
    CityGenerator::generate_citizens($city);
    is($city->{'citizen_count'}, 2);
    is(scalar(@{$city->{'citizens'}}), 0);

#TODO test if they're a specialist, once I add specialists
    done_testing();
};


subtest 'test generate_travelers' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1,});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 7);
    is(scalar(@{$city->{'travelers'}}), 7);
    isnt($city->{'travelers'}->[0]->{'race'}, undef);
    isnt($city->{'travelers'}->[1]->{'race'}, undef);
    isnt($city->{'travelers'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'stats'=>{'tolerance'=>-5}});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 0);
    is(scalar(@{$city->{'travelers'}}), 0);
    is($city->{'travelers'}->[0]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'stats'=>{'tolerance'=>5}});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 10);
    is(scalar(@{$city->{'travelers'}}), 10);
    isnt($city->{'travelers'}->[0]->{'race'}, undef);
    isnt($city->{'travelers'}->[1]->{'race'}, undef);
    isnt($city->{'travelers'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'stats'=>{'tolerance'=>0}});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 5);
    is(scalar(@{$city->{'travelers'}}), 5);
    isnt($city->{'travelers'}->[0]->{'race'}, undef);
    isnt($city->{'travelers'}->[1]->{'race'}, undef);
    isnt($city->{'travelers'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1, 'size_modifier'=>12, 'traveler_count'=>2});
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 2);
    is(scalar(@{$city->{'travelers'}}), 2);
    isnt($city->{'travelers'}->[0]->{'race'}, undef);
    isnt($city->{'travelers'}->[1]->{'race'}, undef);
    is($city->{'travelers'}->[2]->{'race'}, undef);

    $city=CityGenerator::create_city({'seed'=>1,'size_modifier'=>12, 'traveler_count'=>2, 'stats'=>{'tolerance'=>5}});
    CityGenerator::generate_travelers($city);
    is_deeply($city->{'available_traveler_races'}, [ 'human', 'bugbear', 'mindflayer', 'lizardfolk', 'minotaur', 'half-elf', 'hobgoblin', 'elf', 'troglodyte', 'drow', 'lycanthrope', 'halfling', 'half-orc', 'kobold', 'any', 'deep dwarf', 'half-dwarf', 'orc', 'gnome', 'other', 'goblin', 'dwarf', 'ogre']);

    $city=CityGenerator::create_city({'seed'=>1,'size_modifier'=>12, 'traveler_count'=>2, 'stats'=>{'tolerance'=>-5}, 'available_races'=>[ 'human','half-elf','elf','halfling','half-orc','half-dwarf','gnome','dwarf']});
    CityGenerator::generate_travelers($city);
    is_deeply($city->{'available_traveler_races'},[ 'human','half-elf','elf','halfling','half-orc','half-dwarf','gnome','dwarf']);


    $city=CityGenerator::create_city({'seed'=>1, 'size_modifier'=>12, 'traveler_count'=>2, 'travelers'=>[] });
    CityGenerator::generate_travelers($city);
    is($city->{'traveler_count'}, 2);
    is(scalar(@{$city->{'travelers'}}), 0);


    $city=CityGenerator::create_city({'seed'=>1,'size_modifier'=>12, 'traveler_count'=>6, 'available_traveler_races'=>['human'] });
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
    $city=CityGenerator::create_city({'seed'=>1,});
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 9);
    is($city->{'crime_description'}, 'rampant');

    $city=CityGenerator::create_city({'seed'=>1,'crime_roll'=>99});
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 99);
    is($city->{'crime_description'}, 'unheard of');

    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'stats'}->{'education'}=0;
    $city->{'stats'}->{'authority'}=0;
    $city->{'moral'}=50;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 5);
    is($city->{'crime_description'}, 'rampant');

    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'stats'}->{'education'}=0;
    $city->{'stats'}->{'authority'}=0;
    $city->{'moral'}=100;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 10);

    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'stats'}->{'education'}=5;
    $city->{'stats'}->{'authority'}=0;
    $city->{'moral'}=50;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 0);

    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'stats'}->{'education'}=0;
    $city->{'stats'}->{'authority'}=5;
    $city->{'moral'}=50;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 10);

    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'stats'}->{'education'}=5;
    $city->{'stats'}->{'authority'}=-5;
    $city->{'moral'}=0;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, -10);

    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'stats'}->{'education'}=-5;
    $city->{'stats'}->{'authority'}=5;
    $city->{'moral'}=100;
    CityGenerator::generate_crime($city);
    is($city->{'crime_roll'}, 20);

    $city=CityGenerator::create_city({'seed'=>1,'crime_description'=>'fun'});
    CityGenerator::generate_crime($city);
    is($city->{'crime_description'}, 'fun');

    done_testing();
};


subtest 'test set_dominance' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1,});
    $city->{'available_races'}= ['dwarf','human','halfling'];
    $city->{'race percentages'}= [85,10,3];

    $city->{'pop_estimate'}=93;
    CityGenerator::set_races($city);
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, 5);
    is($city->{'dominant_race'}, 'halfling');
    is($city->{'dominance_level'}, 82);
    is($city->{'dominance_description'}, 'brutally oppressive');

    $city->{'dominance_chance'}     =1;
    $city->{'dominant_race'}        =undef;
    $city->{'dominance_level'}      =undef;
    $city->{'dominance_description'}=undef;
    CityGenerator::set_dominance($city);
    is($city->{'dominance_chance'}, 1);
    is($city->{'dominant_race'}, 'dwarf');
    is($city->{'dominance_level'}, 44);
    is($city->{'dominance_description'}, 'cruel');

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
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>0});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'21.00','population'=>'210'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'26.00','population'=>'260'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'children'=>{'population'=>400}});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'40.00','population'=>'400'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1207', 'age_mod'=>5, 'children'=>{'percent'=>25, }});
    CityGenerator::generate_children($city);
    is_deeply($city->{'children'}, {'percent'=>'24.94','population'=>'301'});

    done_testing();
};

subtest 'test generate_elderly' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>0});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'7.00','population'=>'70'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'12.00','population'=>'120'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'elderly'=>{'population'=>400}});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'40.00','population'=>'400'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'elderly'=>{'percent'=>25, }});
    CityGenerator::generate_elderly($city);
    is_deeply($city->{'elderly'}, {'percent'=>'25.00','population'=>'250'});

    done_testing();
};


subtest 'test generate_imprisonment_rate' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>0});
    CityGenerator::generate_imprisonment_rate($city);
    is_deeply($city->{'imprisonment_rate'}, {'percent'=>'0.20','population'=>'2'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'order'=>100});
    CityGenerator::generate_imprisonment_rate($city);
    is_deeply($city->{'imprisonment_rate'}, {'percent'=>'0.50','population'=>'5'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'order'=>0});
    CityGenerator::generate_imprisonment_rate($city);
    is_deeply($city->{'imprisonment_rate'}, {'percent'=>'0.10','population'=>'1'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'size_modifier'=>12});
    CityGenerator::generate_imprisonment_rate($city);
    is_deeply($city->{'imprisonment_rate'}, {'percent'=>'0.30','population'=>'3'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'imprisonment_rate'=>{'population'=>400}});
    CityGenerator::generate_imprisonment_rate($city);
    is_deeply($city->{'imprisonment_rate'}, {'percent'=>'40.00','population'=>'400'});

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'age_mod'=>5, 'imprisonment_rate'=>{'percent'=>25, }});
    CityGenerator::generate_imprisonment_rate($city);
    is_deeply($city->{'imprisonment_rate'}, {'percent'=>'25','population'=>'2'});

    done_testing();
};

subtest 'test generate_housing' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000',});
    CityGenerator::generate_housing($city);
    is_deeply($city->{'housing'}, {'poor'=>34,'wealthy'=>2, 'average'=>70, 'abandoned'=>20, 'total'=>106,
                                    'poor_population'=>500,'wealthy_population'=>10,'average_population'=>,490,
                                    'poor_percent'=>50,'wealthy_percent'=>1,'average_percent'=>,49, 'abandoned_percent'=>19});
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'1000', 'stats'=>{'economy'=>0}});
    CityGenerator::generate_housing($city);
    is_deeply($city->{'housing'}, {'poor'=>20,'wealthy'=>2, 'average'=>98, 'abandoned'=>13, 'total'=>120,
                                    'poor_population'=>300,'wealthy_population'=>10,'average_population'=>,690,
                                    'poor_percent'=>30,'wealthy_percent'=>1,'average_percent'=>,69, 'abandoned_percent'=>11});


    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'10000', 'stats'=>{'economy'=>0}, 'housing'=>
                                            {'poor'=>20,'wealthy'=>2, 'average'=>98, 'abandoned'=>13, 'total'=>120,
                                            'poor_population'=>300,'wealthy_population'=>10,'average_population'=>,690,
                                            'poor_percent'=>30,'wealthy_percent'=>1,'average_percent'=>,69, 'abandoned_percent'=>11}       });
    CityGenerator::generate_housing($city);
    is_deeply($city->{'housing'}, {'poor'=>20,'wealthy'=>2, 'average'=>98, 'abandoned'=>13, 'total'=>120,
                                    'poor_population'=>300,'wealthy_population'=>10,'average_population'=>,690,
                                    'poor_percent'=>30,'wealthy_percent'=>1,'average_percent'=>,69, 'abandoned_percent'=>11});
    done_testing();
};

subtest 'test generate_specialists' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'10000',});
    CityGenerator::generate_specialists($city);
    is($city->{'specialists'}->{'teacher'}->{'count'}, 50  );
    is($city->{'specialists'}->{'magic shop'}->{'count'}, undef  );
    is($city->{'specialists'}->{'porter'}->{'count'}, 5  );

    $city=CityGenerator::create_city({'seed'=>2, 'population_total'=>'50',});
    CityGenerator::generate_specialists($city);
    is($city->{'specialists'}->{'maidservant'}->{'count'}, 1  );
    is($city->{'specialists'}->{'magic shop'}->{'count'}, undef  );

    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'10000', 'specialists'=>{'porter'=>{'count'=>10}}});
    CityGenerator::generate_specialists($city);
    is($city->{'specialists'}->{'porter'}->{'count'}, 10  );

    done_testing();
};

subtest 'test generate_businesses' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'10000',});
    CityGenerator::generate_specialists($city);
    CityGenerator::generate_businesses($city);
    is($city->{'specialists'}->{'teacher'}->{'count'}, 50  );
    is($city->{'businesses'}->{'school'}->{'count'}, 5  );
#TODO test hardcoded business counts regardless of specialists
    done_testing();
};

subtest 'test generate_districts' => sub {
    my $city;
    $city=CityGenerator::create_city({'seed'=>1, 'population_total'=>'10000',});
    CityGenerator::generate_specialists($city);
    CityGenerator::generate_businesses($city);
    CityGenerator::generate_districts($city);
    is($city->{'specialists'}->{'teacher'}->{'count'}, 50  );
    is($city->{'businesses'}->{'school'}->{'specialist_count'}, 50  );
    is($city->{'businesses'}->{'school'}->{'count'}, 5  );
    is($city->{'districts'}->{'market'}->{'business_count'}, 14  );

    done_testing();
};



1;


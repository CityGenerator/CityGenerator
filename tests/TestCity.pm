#!/usr/bin/perl -wT
###############################################################################
#
package TestCity;

use strict;
use warnings;
use Test::More;
use City;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );

my $xml = XML::Simple->new();
my $xml_data   = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );



subtest 'test set_city_size' => sub {
    my $result;
    set_seed(1);
    City::set_city_size();

    is($City::city->{'population'}->{'size'}, '52', 'test population');
    is($City::city->{'size'}, 'settlement',         'test settlement');
    is($City::city->{'size_modifier'}, '-5',        'test size_modifier');
    is($City::city->{'gplimit'}, '100',             'test gp_limit');

    set_seed(2);
    City::set_city_size();
    is($City::city->{'population'}->{'size'}, '16115',  'test population');
    is($City::city->{'size'}, 'large city',             'test settlement');
    is($City::city->{'size_modifier'}, '8',             'test size_modifier');
    is($City::city->{'gplimit'}, '22000',               'test gp_limit');
    done_testing();
};


subtest 'test set_city_type' => sub {
    my $result;
    set_seed(1);
    City::set_city_type();
    
    is($City::city->{'base_pop'}, 'basic'          );
    is($City::city->{'type'}, 'basic'              );
    is($City::city->{'description'}, 'normal population');
    is($City::city->{'add_other'}, 'false'         );
    done_testing();
};


subtest 'test generate_pop_type' => sub {
    my $result;
    set_seed(1);
    City::generate_pop_type();
    
    is($City::city->{'popdensity'}->{'type'}, 'sparsely'          );
    is($City::city->{'popdensity'}->{'feetpercapita'}, '5000'          );
    is($City::city->{'poptype'}, 'isolated'              );
    is($City::city->{'races'}->[0]->{'percent'}, '98');
    is($City::city->{'races'}->[0]->{'dominant'}, 'true');
    is($City::city->{'races'}->[1]->{'percent'}, '1');
    done_testing();
};


subtest 'test get_other_race' => sub {
    my $result;
    set_seed(1);
    $result=City::get_other_race('monster');
    is($result->{'magic'},   '-2');
    is($result->{'plural'},   'Dwarves');
    is($result->{'moral'},   '5');
    is($result->{'content'},   'Dwarf');
    is($result->{'auth'},   '2');
    is($result->{'econ'},   '1');
    is($result->{'edu'},   '0');
    is($result->{'travel'},   '-2');
    is($result->{'mil'},   '4');
    is($result->{'order'},   '5');
    is($result->{'article'},   'a');
    is($result->{'type'},   'basic');
    is($result->{'toler'},   '1');

    set_seed(3);
    $result=City::get_other_race('basic');
    is($result->{'magic'},   '1');
    is($result->{'plural'},   'Goblins');
    is($result->{'moral'},   '-5');
    is($result->{'content'},   'Goblin');
    is($result->{'auth'},   '-4');
    is($result->{'econ'},   '-3');
    is($result->{'edu'},   '-3');
    is($result->{'travel'},   '2');
    is($result->{'mil'},   '0');
    is($result->{'order'},   '-5');
    is($result->{'article'},   'a');
    is($result->{'type'},   'monster');
    is($result->{'toler'},   '1');
    done_testing();
};


subtest 'test get_races' => sub {
    my $result;
    set_seed(2);
    $result=City::get_races('monster');
    is($result->{'content'},   'Mindflayer');
    set_seed(2);
    $result=City::get_races('other');
    is($result->{'content'},   'other');
    set_seed(3);
    $result=City::get_races('mixed');
    is($result->{'content'},   'Minotaur');
    set_seed(3);
    $result=City::get_races('basic');
    is($result->{'content'},   'Half-orc');
    done_testing();
};



subtest 'add_race_features' => sub {
    my $result;
    set_seed(1);

    my $testrace={ 'percent'=>98, 'dominant'=>'true'};
    my $features={
          'magic' => '-2',
          'plural' => 'Half-orcs',
          'moral' => '-2',
          'content' => 'Half-orc',
          'auth' => '-1',
          'econ' => '-1',
          'edu' => '-2',
          'travel' => '1',
          'mil' => '2',
          'order' => '-2',
          'article' => 'a',
          'type' => 'basic',
          'toler' => '2'
    };
    $result=City::add_race_features($testrace,$features  );
    is($result->{'content'},   $features->{'content'} );
    is($result->{'authority'},  $features->{'auth'});
    is($result->{'economy'},    $features->{'econ'});
    is($result->{'education'},  $features->{'edu'});
    is($result->{'military'},   $features->{'mil'});
    is($result->{'tolerance'},  $features->{'toler'});
    is($City::city->{'dominant_race'}, $features->{'content'} );

    $testrace={ 'percent'=>1,};
    $result=City::add_race_features($testrace,$features  );
    is($City::city->{'dominant_race'}, $features->{'content'} );
    done_testing();
};



subtest 'test assign_races' => sub {
    my $result;
    set_seed(1);
    $City::city->{'base_pop'}='basic';
    $City::city->{'add_other'}='false';
    City::assign_races();
    my $races= $City::city->{'races'};
    foreach my $race (@$races){
        isnt($race->{'type'},'monster' );

    }

    $City::city->{'base_pop'}='basic';
    $City::city->{'add_other'}='true';
    City::assign_races();
    my $racesb= $City::city->{'races'};

    #NOTE: I can't test add_other=true ; or at least I don't know how.


    done_testing();
};


subtest 'test assign_races' => sub {
    my $result;
    set_seed(1);

    $City::city= {  'population'=>{'size'=>'1010'},
                    'races'=>[{'percent'=>98},{'percent'=>1},{'percent'=>1}],
                };
    City::generate_pop_counts();
    is($City::city->{'population'}->{'size'},1012, 'total is recalulated to get us close to percentages' );
    is($City::city->{'races'}[0]->{'count'},11 );
    is($City::city->{'races'}[1]->{'count'},11 );
    is($City::city->{'races'}[2]->{'count'},990);
    is($City::city->{'races'}[2]->{'percent'},'97.8', "percentage is recalculated" );

    done_testing();
};


subtest 'test generate_city_beliefs' => sub {
    my $result;
    $City::city->{'races'}=[
                            {'percent'=>98,'magic'=>'0','authority'=>'0','economy'=>'0','education'=>'0','travel'=>'0','tolerance'=>'0','military'=>'0'},
                            {'percent'=>1,'magic'=>'0','authority'=>'0','economy'=>'0','education'=>'0','travel'=>'0','tolerance'=>'0','military'=>'0'},
                            {'percent'=>1,'magic'=>'0','authority'=>'0','economy'=>'0','education'=>'0','travel'=>'0','tolerance'=>'0','military'=>'0'},
];
    set_seed(1);
    City::generate_city_beliefs();
    is($City::city->{'magic'},-2,'magic');
    is($City::city->{'authority'},-2);
    is($City::city->{'economy'},2);
    is($City::city->{'education'},0);
    is($City::city->{'travel'},-1);
    is($City::city->{'tolerance'},2);
    is($City::city->{'military'},1);
    set_seed(3);
    City::generate_city_beliefs();
    is($City::city->{'magic'},1,'magic');
    is($City::city->{'authority'},0);
    is($City::city->{'economy'},-1);
    is($City::city->{'education'},2);
    is($City::city->{'travel'},1);
    is($City::city->{'tolerance'},-1);
    is($City::city->{'military'},-2);

    $City::city->{'races'}=[
                            {'percent'=>98,'magic'=>'5','authority'=>'5','economy'=>'5','education'=>'5','travel'=>'5','tolerance'=>'5','military'=>'5'},
                            {'percent'=>1,'magic'=>'5','authority'=>'5','economy'=>'5','education'=>'5','travel'=>'5','tolerance'=>'5','military'=>'5'},
                            {'percent'=>1,'magic'=>'5','authority'=>'5','economy'=>'5','education'=>'5','travel'=>'5','tolerance'=>'5','military'=>'5'},
];
    set_seed(1);
    City::generate_city_beliefs();
    is($City::city->{'magic'},5,'magic');
    is($City::city->{'authority'},5);
    is($City::city->{'economy'},5);
    is($City::city->{'education'},5);
    is($City::city->{'travel'},5);
    is($City::city->{'tolerance'},5);
    is($City::city->{'military'},5);
    set_seed(3);
    City::generate_city_beliefs();
    is($City::city->{'magic'},5,'magic');
    is($City::city->{'authority'},5);
    is($City::city->{'economy'},5);
    is($City::city->{'education'},5);
    is($City::city->{'travel'},5);
    is($City::city->{'tolerance'},5);
    is($City::city->{'military'},5);

    $City::city->{'races'}=[
                            {'percent'=>98,'magic'=>'-5','authority'=>'-5','economy'=>'-5','education'=>'-5','travel'=>'-5','tolerance'=>'-5','military'=>'-5'},
                            {'percent'=>1,'magic'=>'-5','authority'=>'-5','economy'=>'-5','education'=>'-5','travel'=>'-5','tolerance'=>'-5','military'=>'-5'},
                            {'percent'=>1,'magic'=>'-5','authority'=>'-5','economy'=>'-5','education'=>'-5','travel'=>'-5','tolerance'=>'-5','military'=>'-5'},
];
    set_seed(1);
    City::generate_city_beliefs();
    is($City::city->{'magic'},-5,'magic');
    is($City::city->{'authority'},-5);
    is($City::city->{'economy'},-5);
    is($City::city->{'education'},-5);
    is($City::city->{'travel'},-5);
    is($City::city->{'tolerance'},-5);
    is($City::city->{'military'},-5);
    set_seed(3);
    City::generate_city_beliefs();
    is($City::city->{'magic'},-5,'magic');
    is($City::city->{'authority'},-5);
    is($City::city->{'economy'},-5);
    is($City::city->{'education'},-5);
    is($City::city->{'travel'},-5);
    is($City::city->{'tolerance'},-5);
    is($City::city->{'military'},-5);
    is(1,1 );
    done_testing();
};

subtest 'test generate_city_ethics' => sub {
    my $result;
    $City::city->{'races'}=[
                            {'percent'=>98,'moral'=>'0','order'=>'0'},
                            {'percent'=>1, 'moral'=>'0','order'=>'0'},
                            {'percent'=>1, 'moral'=>'0','order'=>'0'},
                        ];
    set_seed(1);
    City::generate_city_ethics();
    is($City::city->{'moral'},5);
    is($City::city->{'order'},16);
    City::generate_city_ethics();
    is($City::city->{'moral'},62);
    is($City::city->{'order'},22);
    $City::city->{'races'}=[
                            {'percent'=>98,'moral'=>'200','order'=>'200'},
                            {'percent'=>1, 'moral'=>'200','order'=>'200'},
                            {'percent'=>1, 'moral'=>'200','order'=>'200'},
                        ];
    set_seed(1);
    City::generate_city_ethics();
    is($City::city->{'moral'},100);
    is($City::city->{'order'},100);

    $City::city->{'races'}=[
                            {'percent'=>98,'moral'=>'-200','order'=>'-200'},
                            {'percent'=>1, 'moral'=>'-200','order'=>'-200'},
                            {'percent'=>1, 'moral'=>'-200','order'=>'-200'},
                        ];
    set_seed(1);
    City::generate_city_ethics();
    is($City::city->{'moral'},1);
    is($City::city->{'order'},1);

    done_testing();
};

subtest 'test set_laws' => sub {
    my $result;
    set_seed(1);
    City::set_laws();

    isnt($City::city->{'laws'}->{'punishment'}, undef );
    isnt($City::city->{'laws'}->{'trial'}, undef );
    isnt($City::city->{'laws'}->{'enforcement'}, undef );
    isnt($City::city->{'laws'}->{'enforcer'}, undef );
    isnt($City::city->{'laws'}->{'commoncrime'}, undef );

    done_testing();
};

subtest 'test set_govt_type' => sub {
    my $result;
    set_seed(1);
    is($City::city->{'govtype'}, undef );
    City::set_govt_type();
    isnt($City::city->{'govtype'}->{'approval_mod'}, undef );
    isnt($City::city->{'govtype'}->{'religion'}, undef );
    isnt($City::city->{'govtype'}->{'mil_mod'}, undef );
    isnt($City::city->{'govtype'}->{'orderalignment'}, undef );

    done_testing();
};

subtest 'test generate_secondary_power' => sub {
    my $result;
    set_seed(1);
    is($City::city->{'secondarypower'}, undef );
    City::generate_secondary_power();
    isnt($City::city->{'secondarypower'}->{'plot'}, undef );
    isnt($City::city->{'secondarypower'}->{'subplot'}, undef );

    $City::city->{'secondarypower'}=undef;
    set_seed(3);
    is($City::city->{'secondarypower'}, undef );
    City::generate_secondary_power();
    isnt($City::city->{'secondarypower'}->{'plot'}, undef );
    is($City::city->{'secondarypower'}->{'subplot'}, undef );
    done_testing();
};

subtest 'test generate_city_age' => sub {
    my $result;
    set_seed(1);
    is($City::city->{'cityage'}, undef );
    City::generate_city_age();
    isnt($City::city->{'cityage'}, undef );
    done_testing();
};

subtest 'test generate_children' => sub {
    my $result;
    set_seed(1);
    $City::city->{'population'}->{'size'}=1000;
    $City::city->{'cityage'}->{'agemod'}=10;
    
    is($City::city->{'population'}->{'children'}, undef );
    City::generate_children();
    is($City::city->{'population'}->{'children'}->{'percent'}, 31 );
    is($City::city->{'population'}->{'children'}->{'population'}, 310 );

    done_testing();
};


subtest 'test generate_elderly' => sub {
    my $result;
    set_seed(1);
    $City::city->{'population'}->{'size'}=1000;
    $City::city->{'cityage'}->{'agemod'}=10;
    
    is($City::city->{'population'}->{'elderly'}, undef );
    City::generate_elderly();
    is($City::city->{'population'}->{'elderly'}->{'percent'}, 1.5 );
    is($City::city->{'population'}->{'elderly'}->{'population'}, 15 );

    done_testing();
};


subtest 'test generate_imprisonment' => sub {
    my $result;
    set_seed(1);
    $City::city->{'population'}->{'size'}=1000;
    $City::city->{'cityage'}->{'agemod'}=10;
    $City::city->{'authority'}=10;
    $City::city->{'education'}=10;
    $City::city->{'size_modifier'}=10;
    $City::city->{'order'}=10;

    
    is($City::city->{'population'}->{'imprisonment'}, undef );
    City::generate_imprisonment_rate();
    is($City::city->{'population'}->{'imprisonment'}->{'percent'}, 0.4 );
    is($City::city->{'population'}->{'imprisonment'}->{'population'}, 4 );

    done_testing();
};

subtest 'test generate_imprisonment' => sub {
    my $result;
    set_seed(1);
    $City::city->{'education'}=5;
    $City::city->{'authority'}=5;
    $City::city->{'moral'}=100;
    is($City::city->{'crime'}, undef );
    City::generate_crime();
    is($City::city->{'crime'}->{'content'}, 'unheard of' );
    is($City::city->{'crime'}->{'roll'}, '2' );

    done_testing();
};




subtest 'test generate_location' => sub {
    my $result;
    set_seed(1);
    $City::city->{'location'}=undef;
    is($City::city->{'location'}, undef );
    City::generate_location();
    is($City::city->{'location'}->{'name'}, 'on the coast' );
    is($City::city->{'location'}->{'port'}, '1' );
    is($City::city->{'location'}->{'coastdirection'}, 'northwest' );
    is(scalar (@{$City::city->{'location'}->{'landmarks'}}) , 3  );

    done_testing();
};



subtest 'test generate_housing' => sub {
    my $result;
    set_seed(1);
    $City::city->{'housing'}=undef;
    is($City::city->{'housing'}, undef );
#    City::generate_location();
#    is($City::city->{'location'}->{'name'}, 'on the coast' );
#    is($City::city->{'location'}->{'port'}, '1' );
#    is($City::city->{'location'}->{'coastdirection'}, 'northwest' );
#    is(scalar (@{$City::city->{'location'}->{'landmarks'}}) , 3  );

    done_testing();
};

#
#
#    $city->{'population'}->{'wealthy'}=ceil( $city->{'population'}->{'size'} * $xml_data->{'housing'}->{'quality'}->{'wealthy'}->{'percent'}/100 );
#    $city->{'population'}->{'average'}=ceil( $city->{'population'}->{'size'} * $xml_data->{'housing'}->{'quality'}->{'average'}->{'percent'}/100 );
#    $city->{'population'}->{'poor'}= $city->{'population'}->{'size'} - $city->{'population'}->{'average'} - $city->{'population'}->{'wealthy'} ;
#
#    foreach my $housingquality ( @qualitylist ){
#
#        my $housingtype= $xml_data->{'housing'}->{'quality'}->{$housingquality};
#
#        # fractional housecount total, but you can't have .3 of a house... 
#        my $housecount= $city->{'population'}->{'size'}  *   $housingtype->{'percent'}/$housingtype->{'density'}/100;
#
#        # to ensure minimal housing, we require poor housing via ceil, so we always have 1.
#        if (defined $housingtype->{'required'}){
#            $city->{'housing'}->{$housingquality}        = ceil ($housecount); # ceil used because we want at least 1 poor house
#        }else{
#            $city->{'housing'}->{$housingquality}        = floor ($housecount);
#        }
#        $city->{'housing'}->{'total'}+=$city->{'housing'}->{$housingquality}
#
#    }
#
#    # Calculate abandoned by finding 11% of total and adjusting it by economy conditions (+/-10%), min of 1
#    $city->{'housing'}->{'abandoned'}   = ceil($city->{'housing'}->{'total'} *(11-($city->{'economy'})*2 )/100 );
#
#}








1;

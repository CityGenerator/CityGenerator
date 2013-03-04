#!/usr/bin/perl -wT
###############################################################################
#
package TestCity;

use strict;
use Test::More;
use City;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );

my $xml = new XML::Simple;
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


#sub assign_races {
#
#
#
#    # If the base_pop has an "off" race, add it.
#    if ( $city->{'add_other'} eq 'true' ) {
#        my $newrace              = get_other_race($base_pop);
#        my $replace_race_id      = &d( scalar @races ) - 1;
#        $races[$replace_race_id] = add_race_features( $races[$replace_race_id], $newrace );
#    }
#
#    # add the last percent of "others" because mrsassypants didn't grok that
#    # things added up to 99% for a reason.
#    push @races,add_race_features( {'percent'=>'1'}, get_races('other'));
#    for my $race ( @races ) {
#        $GenericGenerator::seed++;
#        my $roll= &d(10)-5 + $race->{'tolerance'} ;
#        my $tolerancetype = roll_from_array( $roll , $xml_data->{'tolerancealignment'}->{'option'} );
#        $race->{'tolerancedescription'}= rand_from_array( $tolerancetype->{'adjective'})->{'content'};
#    }
#    #replace race percentages with full race breakdowns.
#    $city->{'races'} = \@races;
#    set_seed($originalseed);
#}





1;

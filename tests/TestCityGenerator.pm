#!/usr/bin/perl -wT
###############################################################################
#
package TestCityGenerator;

use strict;
use warnings;
use CityGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use List::Util qw(sum);
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

#TODO any test where I'm setting $city->{} values should me moved to create_city()
#TODO consider die statements if requirements are no defined; die 'foo requires poptotal' if (!defined poptotal);
subtest 'test create_city' => sub {
    my $city;
    $city = CityGenerator::create_city();
    isnt( $city->{'seed'},          undef );

    my $presets={ 'seed' => 24, 'size_roll'=>'1', 'size'=>'test','gplimit'=>99,'pop_estimate'=>1001,'size_modifier'=>1,'min_density'=>100,'max_density'=>200, 'name'=>'bob'} ;

    $city = CityGenerator::create_city( $presets );
    foreach my $presetkey (keys %$presets ){
        is( $city->{$presetkey},  $presets->{$presetkey}, "$presetkey has a value of $presets->{$presetkey}" );
    }
    done_testing();
};

subtest 'test flesh_out_city' => sub {
    my $city;

    $city = CityGenerator::create_city( { 'seed' => 1 } );
    CityGenerator::flesh_out_city($city);
    isnt($city->{'region'}, undef, 'ensure a region is created');
    isnt($city->{'continent'}, undef, 'ensure a continent is created');

    $city = CityGenerator::create_city( { 'seed' => 1, 'continent'=>'bar', 'region'=>'baz' } );
    CityGenerator::flesh_out_city($city);
    is($city->{'region'},    'baz', 'ensure a region is created');
    is($city->{'continent'}, 'bar', 'ensure a continent is created');

    done_testing();
};


subtest 'test set_pop_type' => sub {
    my $city;

    $city = CityGenerator::create_city( { 'seed' => 1, 'poptype'=>'mixed', 'poptype_roll'=>100 , } );
    CityGenerator::flesh_out_city($city);
    is( $city->{'poptype'},      'mixed', 'poptype created' );
    is( $city->{'poptype_roll'}, 100,      'poptype_roll is created' );


    my $races=['human'];
    $city = CityGenerator::create_city( { 'seed' => 1, 'poptype'=>'mixed', 'poptype_roll'=>100 , 'available_races'=>$races} );
    CityGenerator::flesh_out_city($city);
    is( $city->{'poptype'},      'mixed', 'poptype created' );
    is( $city->{'poptype_roll'}, 100,     'poptype_roll is created' );
    is_deeply( $city->{'available_races'}, $races, 'available races are preset' );

    done_testing();
};

subtest 'test set_available_races' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'monster' } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 13 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'normal' } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 8 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'mixed' } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 23 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'monster', 'available_races'=>[1,2,3] } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 3 );

    done_testing();
};


subtest 'test generate_race_percentages' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'monster' } );
    CityGenerator::generate_race_percentages($city);
    ok( scalar( @{ $city->{'race percentages'} } )== $city->{'race_limit'}  ||   (sum(@{ $city->{'race percentages'} })>=98  && sum( @{ $city->{'race percentages'} })<=100),  
        sum( @{ $city->{'race percentages'} }).' ensure total race percentages are between 98 and 100% or '.scalar( @{ $city->{'race percentages'} } ).' is 6 races' );


    # ensure race percentages can be set
    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'monster', 'race percentages' => [ 75, 20, 4,1 ] } );
    CityGenerator::generate_race_percentages($city);

    is( scalar( @{ $city->{'race percentages'} } ), 4 );
    ok( scalar( @{ $city->{'race percentages'} } ) == $city->{'race_limit'}  ||   (sum(@{ $city->{'race percentages'} })>=98  && sum( @{ $city->{'race percentages'} })<=100),  
        sum( @{ $city->{'race percentages'} }).' ensure total race percentages are between 98 and 100% or '.scalar( @{ $city->{'race percentages'} } ).' is 6 races' );


    # ensure it will go over 98%
    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'monster', 'race_limit' =>'12' } );
    CityGenerator::generate_race_percentages($city);
    is( scalar( @{ $city->{'race percentages'} } ), 8 );
    ok( scalar( @{ $city->{'race percentages'} } )== $city->{'race_limit'}  ||   (sum(@{ $city->{'race percentages'} })>=98  && sum( @{ $city->{'race percentages'} })<=100),  
        sum( @{ $city->{'race percentages'} }).' ensure total race percentages are between 98 and 100% or '.scalar( @{ $city->{'race percentages'} } ).' is 6 races' );

    # ensure it cuts off at 1
    $city = CityGenerator::create_city( { 'seed' => '1', 'poptype' => 'monster', 'race_limit'=>1,  });
    CityGenerator::generate_race_percentages($city);
    is( scalar( @{ $city->{'race percentages'} } ), 1 );

    done_testing();
};

subtest 'test set_races' => sub {
    my $city;
    my $presets={
            'seed'             => 1,
            'available_races'  => [ 'dwarf', 'human', 'halfling' ],
            'race percentages' => [ 85, 10, 5 ],
            'pop_estimate'     => 100
        };
    $city = CityGenerator::create_city(  $presets   );
    CityGenerator::generate_race_percentages($city);
    CityGenerator::set_available_races($city);
    CityGenerator::set_races($city);

    foreach my $race (@{$city->{'races'}} ){
        isnt(   $race->{'race'}, undef,      'race is set.' );
        ok(     $race->{'percent'} < 100,    'percent is under 100' );
        ok(     $race->{'population'} < 100, 'pop is under 100' );
    }# note the initial total won't sum up exacty to 100%.
    is(scalar @{$city->{'races'}}, 4, 'three races plus other.');


    my $racestruct=[
                { 'race' => 'human',    'percent' => 85, 'population' => 85 },
                undef,
                undef,
                { 'race' => 'other',    'percent' => 10, 'population' => 10 },
            ];
    $presets->{'races'}=$racestruct;
    $city = CityGenerator::create_city( $presets );
    CityGenerator::set_races($city);
    CityGenerator::generate_race_percentages($city);
    CityGenerator::set_available_races($city);

    done_testing();
};

subtest 'test recalculate_populations' => sub {
    my $city;
    $city = CityGenerator::create_city(
        {
            'seed'             => 1,
            'available_races'  => [ 'dwarf', 'human', 'halfling' ],
            'race percentages' => [ 85, 10, 3 ],
            'pop_estimate'     => 93
        }
    );
    CityGenerator::set_races($city);

    is( $city->{'races'}->[3]->{'race'},'other' );
    is( $city->{'races'}->[3]->{'percent'}, 2 );
    is( $city->{'races'}->[3]->{'population'}, 1 );

    CityGenerator::recalculate_populations($city);

    is( $city->{'population_total'}, 94 );
    is( $city->{'races'}->[0]->{'percent'}, 85.1 );
    is( $city->{'races'}->[1]->{'percent'}, 10.6 );
    is( $city->{'races'}->[2]->{'percent'}, 3.1 );
    is( $city->{'races'}->[3]->{'percent'}, 1 );

    done_testing();
};

#subtest 'test generate_citizens' => sub {
#    my $city;
#    $city = CityGenerator::create_city( { 'seed' => 1, } );
#    CityGenerator::flesh_out_city($city);
#    ok( $city->{'citizen_count'}>= 8 && $city->{'citizen_count'} <=28 , " $city->{'citizen_count'} count falls within 8-28 range"   );
#    is( scalar( @{ $city->{'citizens'} } ), $city->{'citizen_count'} );
#
##    $city = CityGenerator::create_city( { 'seed' => 1, 'size_modifier' => -5 } );
##    CityGenerator::generate_citizens($city);
##    ok( $city->{'citizen_count'}>= 8 && $city->{'citizen_count'} <=28 , " $city->{'citizen_count'} count falls within 8-28 range"   );
##    is( scalar( @{ $city->{'citizens'} } ), $city->{'citizen_count'} );
##
##    $city = CityGenerator::create_city( { 'seed' => 1, 'size_modifier' => 12 } );
##    CityGenerator::generate_citizens($city);
##    ok( $city->{'citizen_count'}>= 8 && $city->{'citizen_count'} <=28 , " $city->{'citizen_count'} count falls within 8-28 range"   );
##    is( scalar( @{ $city->{'citizens'} } ), $city->{'citizen_count'} );
#
#
##    $city = CityGenerator::create_city( { 'seed' => 1,  'citizen_count' => 2   }  );
##    CityGenerator::generate_citizens($city);
##    is( $city->{'citizen_count'},           2 );
##    is( scalar( @{ $city->{'citizens'} } ), $city->{'citizen_count'} );
##
##
##    $city = CityGenerator::create_city( { 'seed' => 1, 'citizen_count' => 2, 'citizens' => [] } );
##    CityGenerator::generate_citizens($city);
##    is( $city->{'citizen_count'},           2 );
##    is( scalar( @{ $city->{'citizens'} } ), 0, 'intentionally mismatched' );
#
#    done_testing();
#};


subtest 'test generate_children' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000'  } );
    CityGenerator::generate_children($city);
    isnt( $city->{'children'}->{'percent'},     undef );
    isnt( $city->{'children'}->{'population'},     undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'stats'=>{'age'=>100} } );
    CityGenerator::generate_children($city);
    is( $city->{'children'}->{'percent'},     '10.00' );
    is( $city->{'children'}->{'population'},   100);

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'stats'=>{'age'=>1} } );
    CityGenerator::generate_children($city);
    is( $city->{'children'}->{'percent'},     '44.60' );
    is( $city->{'children'}->{'population'},   446);

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'children'=>{'percent'=>40,'population'=>200} } );
    CityGenerator::generate_children($city);
    is( $city->{'children'}->{'percent'},     40 );
    is( $city->{'children'}->{'population'},   200);

    done_testing();
};

subtest 'test generate_elderly' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000',  } );
    CityGenerator::generate_elderly($city);
    isnt( $city->{'elderly'}->{'percent'},     undef );
    isnt( $city->{'elderly'}->{'population'},     undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'stats'=>{'age'=>100} } );
    CityGenerator::generate_elderly($city);
    is( $city->{'elderly'}->{'percent'},     '26.00' );
    is( $city->{'elderly'}->{'population'},   260);

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'stats'=>{'age'=>1} } );
    CityGenerator::generate_elderly($city);
    is( $city->{'elderly'}->{'percent'},     '1.20' );
    is( $city->{'elderly'}->{'population'},   12);

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'elderly'=>{'percent'=>40,'population'=>200} } );
    CityGenerator::generate_elderly($city);
    is( $city->{'elderly'}->{'percent'},     40 );
    is( $city->{'elderly'}->{'population'},   200);

    done_testing();
};


subtest 'test generate_imprisonment_rate' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', } );
    CityGenerator::generate_imprisonment_rate($city);
    isnt( $city->{'imprisonment_rate'}->{'percent'},     undef );
    isnt( $city->{'imprisonment_rate'}->{'population'},     undef );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'population_total' => '1000',  'imprisonment_rate' => { 'percent' => 25, } } );
    CityGenerator::generate_imprisonment_rate($city);
    is( $city->{'imprisonment_rate'}->{'percent'},     25 );
    is( $city->{'imprisonment_rate'}->{'population'},   250);

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'population_total' => '1000',  'imprisonment_rate' => { 'percent' => 25, 'population'=>200} } );
    CityGenerator::generate_imprisonment_rate($city);
    is( $city->{'imprisonment_rate'}->{'percent'},     25 );
    is( $city->{'imprisonment_rate'}->{'population'},   200);

    done_testing();
};


subtest 'test generate_resources' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    CityGenerator::generate_resources($city);
    isnt( $city->{'resourcecount'},  undef );
    is( @{ $city->{'resources'} }, $city->{'resourcecount'});




    $city = CityGenerator::create_city( { 'seed' => '1', 'resourcecount' => 4 } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  4 );
    is( @{ $city->{'resources'} }, $city->{'resourcecount'} );

    $city = CityGenerator::create_city( { 'seed' => '1', 'resourcecount' => 4, 'resources' => [] } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  4 );
    is( @{ $city->{'resources'} }, 0, 'intentional mismatch' );

    done_testing();
};


subtest 'test generate_city_crest' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    CityGenerator::generate_city_crest($city);
    is_deeply( $city->{'crest'}, {} );

    done_testing();
};


subtest 'test generate_streets' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 4 } );
    CityGenerator::generate_streets($city);
    foreach my $value (qw( content mainroads roads )){
        isnt($city->{'streets'}->{$value}, undef, "ensure $value is defined");
    } 

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'streets' => { 'content'=>'fugly', 'mainroads' => 5, 'roads' => 5 } } );
    CityGenerator::generate_streets($city);
    is( $city->{'streets'}->{'mainroads'}, 5 );
    is( $city->{'streets'}->{'roads'},     5 );
    is( $city->{'streets'}->{'content'},   'fugly' );

    done_testing();
};

subtest 'test generate_popdensity' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000' } );
    CityGenerator::generate_popdensity($city);
    isnt( $city->{'population_density'},  undef );
    isnt( $city->{'density_description'}, undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', 'population_density' => 20000 } );
    CityGenerator::generate_popdensity($city);
    is( $city->{'population_density'},  20000 );
    is( $city->{'density_description'}, 'densely' );

    $city
        = CityGenerator::create_city(
        { 'seed' => 1, 'population_total' => '10000', 'population_density' => 10000, 'density_description' => 'dovey' }
        );
    CityGenerator::generate_popdensity($city);
    is( $city->{'population_density'},  10000 );
    is( $city->{'density_description'}, 'dovey' );

    done_testing();
};

###
###subtest 'test generate_walls' => sub {
###    #NOTE area is included because generate_walls requires it to mark protected areas
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1 } );
###    print STDERR Dumper $city;
###    CityGenerator::generate_walls($city);
###    isnt( $city->{'wall_chance_roll'},   undef, "ensure roll is created" );
###
###    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1, 'walls'=>{'material'=>'cloth', 'style'=>'mesh','height'=>99, 'condition'=>'buff'}, 'wall_chance_roll'=>2 } );
###    CityGenerator::generate_walls($city);
###    is( $city->{'wall_chance_roll'},   '2' );
###    is( $city->{'walls'}->{'material'},    'cloth' );
###    is( $city->{'walls'}->{'style'},       'mesh' );
###    is( $city->{'walls'}->{'height'},      '99' );
###    is( $city->{'walls'}->{'condition'},   'buff' );
###
###    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1,'protected_percent'=>10, 'protected_area'=>10 } );
###    CityGenerator::generate_walls($city);
###    is( $city->{'protected_percent'},   '10' );
###    is( $city->{'protected_area'},   '10' );
###
###    done_testing();
###};


###subtest 'test generate_watchtowers' => sub {
###    #NOTE area is included because generate_walls requires it to mark protected areas
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1,'walls' => { 'length' => 1.9 } } );
###    CityGenerator::generate_watchtowers($city);
###    is( $city->{'watchtowers'}->{'count'}, 5, "FIXME why is this hardcoded to 5? it's dumb. fix it." );
###
###    done_testing();
###};
###
###
###subtest 'test set_laws' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => '1' } );
###    CityGenerator::set_laws($city);
###    foreach my $value (qw( punishment enforcement trial enforcer commoncrime )){
###        isnt($city->{'laws'}->{$value}, undef, "ensure $value is defined");
###    } 
###
###    $city = CityGenerator::create_city(
###        {
###            'seed' => '1',
###            'laws' =>
###                { 'punishment' => 'a', 'enforcement' => 'b', 'trial' => 'c', 'enforcer' => 'd', 'commoncrime' => 'e' }
###        }
###    );
###    CityGenerator::set_laws($city);
###    is( $city->{'laws'}->{'punishment'},  'a' );
###    is( $city->{'laws'}->{'enforcement'}, 'b' );
###    is( $city->{'laws'}->{'trial'},       'c' );
###    is( $city->{'laws'}->{'enforcer'},    'd' );
###    is( $city->{'laws'}->{'commoncrime'}, 'e' );
###
###    done_testing();
###};
###
###
###subtest 'test generate_area' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 1000, 'population_density' => 100 } );
###    CityGenerator::generate_area($city);
###    isnt( $city->{'area'},               undef );
###    isnt( $city->{'arable_percentage'},  undef );
###    isnt( $city->{'arable_description'}, undef );
###
###    $city = CityGenerator::create_city(
###        {
###            'seed'               => 1,
###            'population_total'   => 1000,
###            'population_density' => 150,
###            'arable_percentage'  => 100,
###            'arable_description' => 'meh'
###        }
###    );
###    CityGenerator::generate_area($city);
###    is( $city->{'area'},               6.67 );
###    is( $city->{'arable_percentage'},  100 );
###    is( $city->{'arable_description'}, 'meh' );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 1000, 'population_density' => 300, } );
###    CityGenerator::generate_area($city);
###    is( $city->{'area'}, 3.33 );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 1000, 'population_density' => 1000 } );
###    CityGenerator::generate_area($city);
###    is( $city->{'area'}, '1.00' );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 2000, 'population_density' => 1000 } );
###    CityGenerator::generate_area($city);
###    is( $city->{'area'}, '2.00' );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 3000, 'population_density' => 1000 } );
###    CityGenerator::generate_area($city);
###    is( $city->{'area'}, '3.00' );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 3000, 'population_density' => 1000, 'area'=>22 } );
###    CityGenerator::generate_area($city);
###    is( $city->{'area'}, 22);
###
###    done_testing();
###};
###
###
###
###subtest 'test generate_travelers' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           6 );
###    is( scalar( @{ $city->{'travelers'} } ), $city->{'traveler_count'} );
###    foreach my $traveler ( @{ $city->{'travelers'} }) {
###        isnt( $traveler->{'race'}, undef );
###    }
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats' => { 'tolerance' => -5 } } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           0 );
###    is( scalar( @{ $city->{'travelers'} } ), $city->{'traveler_count'} );
###    is( $city->{'travelers'}->[0]->{'race'}, undef );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats' => { 'tolerance' => 5 } } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           10 );
###    is( scalar( @{ $city->{'travelers'} } ), $city->{'traveler_count'} );
###    foreach my $traveler ( @{ $city->{'travelers'} }) {
###        isnt( $traveler->{'race'}, undef );
###    }
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats' => { 'tolerance' => 0 } } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           5 );
###    is( scalar( @{ $city->{'travelers'} } ), $city->{'traveler_count'} );
###    foreach my $traveler ( @{ $city->{'travelers'} }) {
###        isnt( $traveler->{'race'}, undef );
###    }
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 2 } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           2 );
###    is( scalar( @{ $city->{'travelers'} } ), $city->{'traveler_count'} );
###    is( $city->{'travelers'}->[2], undef, 'ensure 3rd traveler is undefined' );
###
###    $city = CityGenerator::create_city(
###        { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 2, 'stats' => { 'tolerance' => 5 } } );
###    CityGenerator::generate_travelers($city);
###    is_deeply(
###        $city->{'available_traveler_races'},
###        [
###            'human',     'bugbear', 'mindflayer', 'lizardfolk', 'minotaur',    'half-elf',
###            'hobgoblin', 'elf',     'troglodyte', 'drow',       'lycanthrope', 'halfling',
###            'half-orc',  'kobold',  'any',        'deep dwarf', 'half-dwarf',  'orc',
###            'gnome',     'other',   'goblin',     'dwarf',      'ogre'
###        ]
###    );
###
###    my $races=[ 'human', 'half-elf', 'elf', 'halfling', 'half-orc', 'half-dwarf', 'gnome', 'dwarf' ];
###    $city = CityGenerator::create_city(
###        {
###            'seed'            => 1,
###            'size_modifier'   => 12,
###            'traveler_count'  => 2,
###            'stats'           => { 'tolerance' => -5 },
###            'available_races' =>$races,
###        }
###    );
###    CityGenerator::generate_travelers($city);
###    is_deeply( $city->{'available_traveler_races'}, $races );
###
###
###    $city = CityGenerator::create_city(
###        { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 2, 'travelers' => [] } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           2 );
###    is( scalar( @{ $city->{'travelers'} } ), 0 );
###
###
###    $city = CityGenerator::create_city(
###        { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 6, 'available_traveler_races' => ['human'] } );
###    CityGenerator::generate_travelers($city);
###    is( $city->{'traveler_count'},           6 );
###    foreach my $traveler (@{$city->{'travelers'}}){
###        is( $traveler->{'race'}, 'human' );
###    }
###
###    #TODO test if they're a specialist, once I add specialists
###    done_testing();
###};
###
###
###subtest 'test generate_crime' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, } );
###    CityGenerator::generate_crime($city);
###    isnt( $city->{'crime_roll'},        undef );
###    isnt( $city->{'crime_description'}, undef );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'crime_roll' => 99 } );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'},        99 );
###    is( $city->{'crime_description'}, 'unheard of' );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats'=>{'education'=>0, 'authority'=>0}, 'moral'=>50} );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'},        4 );
###    is( $city->{'crime_description'}, 'rampant' );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats'=>{'education'=>0, 'authority'=>0}, 'moral'=>100 } );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'}, 9 );
###
###    $city = CityGenerator::create_city( { 'seed' => 1,'stats'=>{'education'=>5, 'authority'=>0}, 'moral'=>50 } );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'}, 1 );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats'=>{'education'=>0, 'authority'=>5}, 'moral'=>50} );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'}, 9 );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats'=>{'education'=>5, 'authority'=>-5}, 'moral'=>0} );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'}, 1 );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'stats'=>{'education'=>-5, 'authority'=>5}, 'moral'=>100 } );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_roll'}, 19 );
###
###    $city = CityGenerator::create_city( { 'seed' => 1, 'crime_description' => 'fun' } );
###    CityGenerator::generate_crime($city);
###    is( $city->{'crime_description'}, 'fun' );
###
###    done_testing();
###};
###
###
####-------------------------------------------------------------------
####-----------------------Refactor after this ------------------------
####-------------------------------------------------------------------
###
###
###subtest 'test set_dominance' => sub {
###    #FIXME this whole section is garbage;
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, } );
###    $city->{'available_races'}  = [ 'dwarf', 'human', 'halfling' ];
###    $city->{'race percentages'} = [ 85,      10,      3 ];
###
###    $city->{'pop_estimate'} = 93;
###    CityGenerator::set_races($city);
###    CityGenerator::set_dominance($city);
###    foreach my $value (qw( dominant_race dominance_level dominance_description)){
###        is($city->{$value}, undef, "ensure $value is undefined");
###    }
###
###    $city->{'dominance_chance'}      = 1;
###    $city->{'dominant_race'}         = undef;
###    $city->{'dominance_level'}       = undef;
###    $city->{'dominance_description'} = undef;
###    CityGenerator::set_dominance($city);
###    foreach my $value (qw(dominance_chance dominant_race dominance_level dominance_description)){
###        isnt($city->{$value}, undef, "ensure $value is defined");
###    }
###
###    $city->{'dominance_chance'}      = 90;
###    $city->{'dominant_race'}         = undef;
###    $city->{'dominance_level'}       = undef;
###    $city->{'dominance_description'} = undef;
###    CityGenerator::set_dominance($city);
###    is( $city->{'dominance_chance'},      '90' );
###    foreach my $value (qw( dominant_race dominance_level dominance_description)){
###        is($city->{$value}, undef, "ensure $value is undefined");
###    }
###
###    $city->{'dominance_chance'}      = 5;
###    $city->{'dominant_race'}         = undef;
###    $city->{'dominance_level'}       = 50;
###    $city->{'dominance_description'} = undef;
###    CityGenerator::set_dominance($city);
###    foreach my $value (qw(dominance_chance dominant_race dominance_level dominance_description)){
###        isnt($city->{$value}, undef, "ensure $value is defined");
###    }
###
###    $city->{'dominance_chance'}      = 5;
###    $city->{'dominant_race'}         = 'human';
###    $city->{'dominance_level'}       = 50;
###    $city->{'dominance_description'} = 'smelly';
###    CityGenerator::set_dominance($city);
###    is( $city->{'dominance_chance'},      5 );
###    is( $city->{'dominant_race'},         'human' );
###    is( $city->{'dominance_level'},       50 );
###    is( $city->{'dominance_description'}, 'smelly' );
###
###    done_testing();
###};
###
###subtest 'test generate_housing' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', } );
###    CityGenerator::generate_housing($city);
###    foreach my $value ( qw( poor wealthy average abandoned total poor_population wealthy_population average_population poor_percent wealthy_percent average_percent abandoned_percent ) ){
###        isnt($city->{'housing'}->{$value}, undef, "ensure $value is defined");
###    }
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'stats' => { 'economy' => 0 } } );
###    CityGenerator::generate_housing($city);
###    foreach my $value ( qw( poor wealthy average abandoned total poor_population wealthy_population average_population poor_percent wealthy_percent average_percent abandoned_percent ) ){
###        isnt($city->{'housing'}->{$value}, undef, "ensure $value is defined");
###    }
###
###    my $housing={
###                'poor'               => 20,
###                'wealthy'            => 2,
###                'average'            => 98,
###                'abandoned'          => 13,
###                'total'              => 120,
###                'poor_population'    => 300,
###                'wealthy_population' => 10,
###                'average_population' =>,
###                690,
###                'poor_percent'    => 30,
###                'wealthy_percent' => 1,
###                'average_percent' =>,
###                69, 'abandoned_percent' => 11
###            };
###    $city = CityGenerator::create_city(
###        {
###            'seed'             => 1,
###            'population_total' => '10000',
###            'stats'            => { 'economy' => 0 },
###            'housing'          => $housing, 
###        }
###    );
###    CityGenerator::generate_housing($city);
###    is_deeply(
###        $city->{'housing'}, $housing, "ensure housing doesn't change when provided" );
###    done_testing();
###};
###
###subtest 'test generate_specialists' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', } );
###    CityGenerator::generate_specialists($city);
###    is( $city->{'specialists'}->{'teacher'}->{'count'},    50 );
###    is( $city->{'specialists'}->{'magic shop'}->{'count'}, undef );
###    is( $city->{'specialists'}->{'porter'}->{'count'},     5 );
###
###    $city = CityGenerator::create_city(
###        { 'seed' => 1, 'population_total' => '10000', 'specialists' => { 'porter' => { 'count' => 10 } } } );
###    CityGenerator::generate_specialists($city);
###    is( $city->{'specialists'}->{'porter'}->{'count'}, 10 );
###
###    done_testing();
###};
###
###subtest 'test generate_businesses' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', } );
###    CityGenerator::generate_specialists($city);
###    CityGenerator::generate_businesses($city);
###    is( $city->{'specialists'}->{'teacher'}->{'count'}, 50 );
###    is( $city->{'businesses'}->{'school'}->{'count'},   5 );
###
###    #TODO test hardcoded business counts regardless of specialists
###    done_testing();
###};
###
###subtest 'test generate_districts' => sub {
###    my $city;
###    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', } );
###    CityGenerator::generate_specialists($city);
###    CityGenerator::generate_businesses($city);
###    CityGenerator::generate_districts($city);
###    is( $city->{'specialists'}->{'teacher'}->{'count'},          50 );
###    is( $city->{'businesses'}->{'school'}->{'specialist_count'}, 50 );
###    is( $city->{'businesses'}->{'school'}->{'count'},            5 );
###
###    done_testing();
###};
###
subtest 'test generate_postings' => sub {
    my $city;
    my $count=3;

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000','postingcount'=>$count, 'postings'=>['dummy']} );
    CityGenerator::generate_postings($city);
    is(scalar(@{$city->{'postings'}}), 3);
    is( $city->{'postings'}->[0], 'dummy');

    done_testing();
};


1;


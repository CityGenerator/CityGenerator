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

#TODO have a test that does an is_deeply on an entire structure.
#TODO any test where I'm setting $city->{} values should me moved to create_city()
#TODO consider die statements if requirements are no defined; die 'foo requires poptotal' if (!defined poptotal);
subtest 'test create_city' => sub {
    my $city;
    $city = CityGenerator::create_city();
    isnt( $city->{'seed'},          undef );

    $city = CityGenerator::create_city( { 'seed' => 24, 'dummy' => 'test' } );
    is( $city->{'seed'},  24 );
    is( $city->{'dummy'}, 'test' );
    done_testing();
};



subtest 'test generate_city_name' => sub {
    my $city;

    $city = CityGenerator::create_city( { 'seed' => 1 } );
    is( $city->{'name'}, 'Grisnow' );

    $city = CityGenerator::create_city( { 'seed' => 20, 'name' => 'foo' } );
    is( $city->{'name'}, 'foo' );

    done_testing();
};

subtest 'test generate_base_stats' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    foreach my $stat ( qw( education authority magic military tolerance economy ) ){
        like( $city->{'stats'}->{$stat},qr/-?[0-5]/, "$stat is a number"  );
    }

    $city = CityGenerator::create_city( { 'seed' => '1', 'stats'=>{'education'=>0, 'authority'=>0, 'magic'=>0, 'military'=>0, 'tolerance'=>0, 'economy'=>0, }} );
    foreach my $stat ( qw( education authority magic military tolerance economy ) ){
        is( $city->{'stats'}->{$stat},0, "$stat is set to 0"  );
    }
    $city = CityGenerator::create_city( { 'seed' => '1', 'stats'=>{'education'=>10, 'authority'=>10, 'magic'=>10, 'military'=>10, 'tolerance'=>10, 'economy'=>10, }} );
    foreach my $stat ( qw( education authority magic military tolerance economy ) ){
        is( $city->{'stats'}->{$stat},5, "$stat is set max of 5"  );
    }
    $city = CityGenerator::create_city( { 'seed' => '1', 'stats'=>{'education'=>-10, 'authority'=>-10, 'magic'=>-10, 'military'=>-10, 'tolerance'=>-10, 'economy'=>-10, }} );
    foreach my $stat ( qw( education authority magic military tolerance economy ) ){
        is( $city->{'stats'}->{$stat},-5, "$stat is set min of -5"  );
    }

    done_testing();
};
subtest 'test generate_alignment' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    ok( $city->{'order'} >=1 && $city->{'order'} <=100,    "order is in range"  );
    ok( $city->{'moral'} >=1 && $city->{'moral'} <=100,    "order is in range"  );
    $city = CityGenerator::create_city( { 'seed' => '1',   'order'=>200, 'moral'=>-100} );
    ok( $city->{'order'} >=1 && $city->{'order'} <=100,    "order is in range"  );
    ok( $city->{'moral'} >=1 && $city->{'moral'} <=100,    "order is in range"  );

    done_testing();
};


subtest 'test set_city_size' => sub {
    my $city;

    $city = CityGenerator::create_city( { 'seed' => 1 } );
    CityGenerator::set_city_size($city);
    foreach my $value (qw(size gplimit pop_estimate size_modifier age_roll age_description age_mod min_density max_density) ){
        isnt($city->{$value}, undef);
    }

    $city = CityGenerator::create_city(
        {
            'seed'          => 24,
            'name'          => 'foo',
            'size'          => 'Detroitish',
            'gplimit'       => '12345',
            'pop_estimate'  => '10102',
            'size_modifier' => '3',
            'min_density'   => '4',
            'max_density'   => '100',
        }
    );
    CityGenerator::set_city_size($city);
    is( $city->{'size'},            'Detroitish' );
    is( $city->{'gplimit'},         '12345' );
    is( $city->{'pop_estimate'},    '10102' );
    is( $city->{'size_modifier'},   '3' );
    is( $city->{'min_density'},     '4' );
    is( $city->{'max_density'},     '100' );

    done_testing();
};


subtest 'test set_age' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    foreach my $stat ( qw( age_roll age_description age_mod ) ){
        isnt($city->{$stat}, undef);
    }

    $city = CityGenerator::create_city( { 'seed' => '1', 'age_description' => '10', 'age_mod' => '10', 'age_roll' => '10' } );
    foreach my $stat ( qw( age_roll age_description age_mod ) ){
        is($city->{$stat}, '10', "$stat overridden as 10");
    }
    done_testing();
};


subtest 'test flesh_out_city' => sub {
    my $city;

    $city = CityGenerator::create_city( { 'seed' => 100 } );
    CityGenerator::flesh_out_city($city);
    isnt($city->{'govt'}, undef);
    done_testing();
};


subtest 'test set_pop_type' => sub {
    my $city;

    $city = CityGenerator::create_city( { 'seed' => 1 } );
    CityGenerator::set_pop_type($city);
    foreach my $value (qw( base_pop type ) ){
        isnt($city->{$value}, undef, "$value is set");
    }
    $city = CityGenerator::create_city( { 'seed' => 1, 'base_pop' => 'foo', 'type' => 'foo', } );
    CityGenerator::set_pop_type($city);
    foreach my $value (qw( base_pop type ) ){
        is($city->{$value}, 'foo', "$value is set to foo");
    }

    done_testing();
};


subtest 'test set_available_races' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'monster' } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 13 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'normal' } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 8 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'mixed' } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 23 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'monster', 'available_races'=>[1,2,3] } );
    CityGenerator::set_available_races($city);
    is( scalar( @{ $city->{'available_races'} } ), 3 );

    done_testing();
};


subtest 'test generate_race_percentages' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'monster' } );
    CityGenerator::generate_race_percentages($city);
    is( scalar( @{ $city->{'race percentages'} } ), 6 );
    ok( sum( @{ $city->{'race percentages'} })>=98 && sum( @{ $city->{'race percentages'} })<=100,  'ensure race percentages are between 98 and 100%' );

    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'monster', 'race percentages' => [ 75, 20, 4 ] } );
    CityGenerator::generate_race_percentages($city);
    is( scalar( @{ $city->{'race percentages'} } ), 3 );
    ok( sum( @{ $city->{'race percentages'} })>=98 && sum( @{ $city->{'race percentages'} })<=100,  'ensure race percentages are between 98 and 100%' );

    $city = CityGenerator::create_city( { 'seed' => '1', 'base_pop' => 'monster', 'race_limit'=>2 });
    CityGenerator::generate_race_percentages($city);
    is( scalar( @{ $city->{'race percentages'} } ), 2 );

    done_testing();
};

subtest 'test set_races' => sub {
    my $city;
    $city = CityGenerator::create_city(
        {
            'seed'             => 1,
            'available_races'  => [ 'dwarf', 'human', 'halfling' ],
            'race percentages' => [ 85, 10, 5 ],
            'pop_estimate'     => 100
        }
    );
    CityGenerator::set_races($city);

    is( $city->{'races'}->[0]->{'race'},'dwarf' );
    is( $city->{'races'}->[0]->{'percent'}, 85 );
    is( $city->{'races'}->[0]->{'population'}, 85 );

    is( $city->{'races'}->[1]->{'race'},'halfling' );
    is( $city->{'races'}->[1]->{'percent'}, 10 );
    is( $city->{'races'}->[1]->{'population'}, 10 );

    is( $city->{'races'}->[2]->{'race'},'human' );
    is( $city->{'races'}->[2]->{'percent'}, 5 );
    is( $city->{'races'}->[2]->{'population'}, 5 );

    is( $city->{'races'}->[3]->{'race'},'other' );
    is( $city->{'races'}->[3]->{'percent'}, 1 ,     'other percent');
    is( $city->{'races'}->[3]->{'population'}, 1,   'other population' );

    my $racestruct=[
                { 'race' => 'human',    'percent' => 85, 'population' => 85 },
                { 'race' => 'halfling', 'percent' => 10, 'population' => 10 },
                { 'race' => 'dwarf',    'percent' => 3,  'population' => 3 },
                { 'race' => 'other',    'percent' => 2,  'population' => 2 }
            ];

    $city = CityGenerator::create_city( { 'seed'  => 1, 'races' =>$racestruct } );
    CityGenerator::set_races($city);
    is_deeply( $city->{'races'}, $racestruct);

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

subtest 'test generate_citizens' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, } );
    CityGenerator::generate_citizens($city);
    is( $city->{'citizen_count'},           8 );
    is( scalar( @{ $city->{'citizens'} } ), 8 );

    $city = CityGenerator::create_city( { 'seed' => 1, 'size_modifier' => -5 } );
    CityGenerator::generate_citizens($city);
    is( $city->{'citizen_count'},           8 );
    is( scalar( @{ $city->{'citizens'} } ), 8 );

    $city = CityGenerator::create_city( { 'seed' => 1, 'size_modifier' => 12 } );
    CityGenerator::generate_citizens($city);
    is( $city->{'citizen_count'},           28 );
    is( scalar( @{ $city->{'citizens'} } ), 28 );


    $city = CityGenerator::create_city( { 'seed' => 1,  'citizen_count' => 2   }  );
    CityGenerator::generate_citizens($city);
    is( $city->{'citizen_count'},           2 );
    is( scalar( @{ $city->{'citizens'} } ), 2 );


    $city = CityGenerator::create_city( { 'seed' => 1, 'citizen_count' => 2, 'citizens' => [] } );
    CityGenerator::generate_citizens($city);
    is( $city->{'citizen_count'},           2 );
    is( scalar( @{ $city->{'citizens'} } ), 0 );

    done_testing();
};



subtest 'test generate_children' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000'  } );
    CityGenerator::generate_children($city);
    isnt( $city->{'children'}->{'percent'},     undef );
    isnt( $city->{'children'}->{'population'},     undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'age_mod' => 0, 'children'=>{ 'population'=>200} } );
    CityGenerator::generate_children($city);
    is( $city->{'children'}->{'percent'},     '20.00' );
    is( $city->{'children'}->{'population'},   200);

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

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'age_mod' => 0, 'elderly'=>{ 'population'=>200} } );
    CityGenerator::generate_elderly($city);
    is( $city->{'elderly'}->{'percent'},     '20.00' );
    is( $city->{'elderly'}->{'population'},   200);

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'elderly'=>{'percent'=>40,'population'=>200} } );
    CityGenerator::generate_elderly($city);
    is( $city->{'elderly'}->{'percent'},     40 );
    is( $city->{'elderly'}->{'population'},   200);

    done_testing();
};


subtest 'test generate_imprisonment_rate' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'age_mod' => 0 } );
    CityGenerator::generate_imprisonment_rate($city);
    isnt( $city->{'imprisonment_rate'}->{'percent'},     undef );
    isnt( $city->{'imprisonment_rate'}->{'population'},     undef );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'population_total' => '1000', 'age_mod' => 5, 'imprisonment_rate' => { 'percent' => 25, } } );
    CityGenerator::generate_imprisonment_rate($city);
    is( $city->{'imprisonment_rate'}->{'percent'},     25 );
    is( $city->{'imprisonment_rate'}->{'population'},   3);

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'population_total' => '1000', 'age_mod' => 5, 'imprisonment_rate' => { 'percent' => 25, 'population'=>200} } );
    CityGenerator::generate_imprisonment_rate($city);
    is( $city->{'imprisonment_rate'}->{'percent'},     25 );
    is( $city->{'imprisonment_rate'}->{'population'},   200);

    done_testing();
};

#-------------------------------------------------------------------
#-----------------------Refactor after this ------------------------
#-------------------------------------------------------------------
subtest 'test generate_resources' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  1 );
    is( @{ $city->{'resources'} }, 1 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'economy' => 20 } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  1 );
    is( @{ $city->{'resources'} }, 1 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'economy' => 20 } );
    $city->{'economy'} = undef;
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  1 );
    is( @{ $city->{'resources'} }, 1 );

    $city = CityGenerator::create_city( { 'seed' => '2' } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  8 );
    is( @{ $city->{'resources'} }, 8 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'resourcecount' => 4 } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  4 );
    is( @{ $city->{'resources'} }, 4 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'resourcecount' => 4, 'resources' => 1 } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  4 );
    is( @{ $city->{'resources'} }, 4 );

    $city = CityGenerator::create_city( { 'seed' => '1', 'resourcecount' => 4, 'resources' => [] } );
    CityGenerator::generate_resources($city);
    is( $city->{'resourcecount'},  4 );
    is( @{ $city->{'resources'} }, 0 );


    done_testing();
};

subtest 'test generate_city_crest' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    CityGenerator::generate_city_crest($city);
    is_deeply( $city->{'crest'}, {} );

    done_testing();
};



subtest 'test generate_shape' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    CityGenerator::generate_shape($city);
    is( $city->{'shape'}, 'a circular' );

    $city = CityGenerator::create_city( { 'seed' => '1', 'shape' => 'fool' } );
    CityGenerator::generate_shape($city);
    is( $city->{'shape'}, 'fool' );

    done_testing();
};

subtest 'test generate_streets' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 4 } );
    CityGenerator::generate_streets($city);

    is( $city->{'streets'}->{'content'},   'even dirt roads in an organic pattern' );
    is( $city->{'streets'}->{'mainroads'}, 1 );
    is( $city->{'streets'}->{'roads'},     2 );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'streets' => { 'content' => 'foo', 'mainroads' => -1, 'roads' => -1 } } );
    CityGenerator::generate_streets($city);
    is( $city->{'streets'}->{'content'},   'foo' );
    is( $city->{'streets'}->{'mainroads'}, 0 );
    is( $city->{'streets'}->{'roads'},     1 );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'streets' => { 'content' => 'foo', 'mainroads' => -1, 'roads' => -1 } } );
    CityGenerator::generate_streets($city);
    is( $city->{'streets'}->{'content'},   'foo' );
    is( $city->{'streets'}->{'mainroads'}, 0 );
    is( $city->{'streets'}->{'roads'},     1 );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'streets' => { 'content' => 'foo', 'mainroads' => 5, 'roads' => 5 } } );
    CityGenerator::generate_streets($city);
    is( $city->{'streets'}->{'content'},   'foo' );
    is( $city->{'streets'}->{'mainroads'}, 5 );
    is( $city->{'streets'}->{'roads'},     5 );

    done_testing();
};

subtest 'test set_stat_descriptions' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1 } );
    CityGenerator::set_stat_descriptions($city);
    is( $city->{'education_description'}, 'rare' );
    is( $city->{'authority_description'}, 'is neutral towards' );
    is( $city->{'magic_description'},     'plentiful' );
    is( $city->{'military_description'},  'laid back' );
    is( $city->{'tolerance_description'}, 'is accepting of' );
    is( $city->{'economy_description'},   'shaky' );

    $city = CityGenerator::create_city(
        {
            'seed'  => 1,
            'stats' => {
                'education' => 0,
                'authority' => 0,
                'magic'     => 0,
                'military'  => 0,
                'tolerance' => 0,
                'economy'   => 0
            }
        }
    );
    CityGenerator::set_stat_descriptions($city);
    is( $city->{'education_description'}, 'allowed, but not enforced' );
    is( $city->{'authority_description'}, 'is neutral towards' );
    is( $city->{'magic_description'},     'rare but accepted' );
    is( $city->{'military_description'},  'laid back' );
    is( $city->{'tolerance_description'}, 'is neutral towards' );
    is( $city->{'economy_description'},   'unwavering' );

    $city = CityGenerator::create_city(
        {
            'seed'                  => 1,
            'education_description' => 'foo1',
            'authority_description' => 'foo2',
            'magic_description'     => 'foo3',
            'military_description'  => 'foo4',
            'tolerance_description' => 'foo5',
            'economy_description'   => 'foo6'
        }
    );
    CityGenerator::set_stat_descriptions($city);
    is( $city->{'education_description'}, 'foo1' );
    is( $city->{'authority_description'}, 'foo2' );
    is( $city->{'magic_description'},     'foo3' );
    is( $city->{'military_description'},  'foo4' );
    is( $city->{'tolerance_description'}, 'foo5' );
    is( $city->{'economy_description'},   'foo6' );

    $city = CityGenerator::create_city( { 'seed' => 1 } );
    $city->{'stats'}->{'education'} = undef;
    $city->{'stats'}->{'authority'} = undef;
    $city->{'stats'}->{'magic'}     = undef;
    $city->{'stats'}->{'military'}  = undef;
    $city->{'stats'}->{'tolerance'} = undef;
    $city->{'stats'}->{'economy'}   = undef;
    CityGenerator::set_stat_descriptions($city);
    is( $city->{'education_description'}, 'allowed, but not enforced' );
    is( $city->{'authority_description'}, 'is neutral towards' );
    is( $city->{'magic_description'},     'rare but accepted' );
    is( $city->{'military_description'},  'laid back' );
    is( $city->{'tolerance_description'}, 'is neutral towards' );
    is( $city->{'economy_description'},   'unwavering' );

    done_testing();
};




subtest 'test generate_walls' => sub {
    #NOTE area is included because generate_walls requires it to mark protected areas
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1 } );
    CityGenerator::generate_walls($city);
    is( $city->{'wall_chance_roll'},   '30' );
    is( $city->{'walls'}->{'material'},    'brick' );
    is( $city->{'walls'}->{'style'},       'rampart' );
    is( $city->{'walls'}->{'height'},      '6' );
    is( $city->{'walls'}->{'condition'},   'flimsy' );

    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1, 'walls'=>{'material'=>'cloth', 'style'=>'mesh','height'=>99, 'condition'=>'buff'}, 'wall_chance_roll'=>2 } );
    CityGenerator::generate_walls($city);
    is( $city->{'wall_chance_roll'},   '2' );
    is( $city->{'walls'}->{'material'},    'cloth' );
    is( $city->{'walls'}->{'style'},       'mesh' );
    is( $city->{'walls'}->{'height'},      '99' );
    is( $city->{'walls'}->{'condition'},   'buff' );

    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1,'protected_percent'=>10, 'protected_area'=>10 } );
    CityGenerator::generate_walls($city);
    is( $city->{'protected_percent'},   '10' );
    is( $city->{'protected_area'},   '10' );

    done_testing();
};

subtest 'test generate_watchtowers' => sub {
    #NOTE area is included because generate_walls requires it to mark protected areas
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1', 'area'=>1,'walls' => { 'length' => 1.9 } } );
    CityGenerator::generate_watchtowers($city);
    is( $city->{'watchtowers'}->{'count'}, 5 );


    done_testing();
};

subtest 'test set_laws' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => '1' } );
    CityGenerator::set_laws($city);
    is( $city->{'laws'}->{'punishment'},  'fines' );
    is( $city->{'laws'}->{'enforcement'}, 'who can be bribed' );
    is( $city->{'laws'}->{'trial'},       'by a magistrate' );
    is( $city->{'laws'}->{'enforcer'},    'city watch' );
    is( $city->{'laws'}->{'commoncrime'}, 'murder' );

    $city = CityGenerator::create_city(
        {
            'seed' => '1',
            'laws' =>
                { 'punishment' => 'a', 'enforcement' => 'b', 'trial' => 'c', 'enforcer' => 'd', 'commoncrime' => 'e' }
        }
    );
    CityGenerator::set_laws($city);
    is( $city->{'laws'}->{'punishment'},  'a' );
    is( $city->{'laws'}->{'enforcement'}, 'b' );
    is( $city->{'laws'}->{'trial'},       'c' );
    is( $city->{'laws'}->{'enforcer'},    'd' );
    is( $city->{'laws'}->{'commoncrime'}, 'e' );


    done_testing();
};




subtest 'test generate_area' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 1000, 'population_density' => 100 } );
    CityGenerator::generate_area($city);
    is( $city->{'area'},               '10.00' );
    is( $city->{'arable_percentage'},  2 );
    is( $city->{'arable_description'}, 'desolate' );

    $city = CityGenerator::create_city(
        {
            'seed'               => 1,
            'population_total'   => 1000,
            'population_density' => 100,
            protected_percent    => '100',
            'protected_area'     => 9.29
        }
    );

    #FIXME Why is the support area different? between this and the one above?
    CityGenerator::generate_area($city);
    is( $city->{'area'},               '10.00' );
    is( $city->{'arable_percentage'},  2 );
    is( $city->{'arable_description'}, 'desolate' );


    $city = CityGenerator::create_city(
        {
            'seed'               => 1,
            'population_total'   => 1000,
            'population_density' => 150,
            'arable_percentage'  => 100,
            'arable_description' => 'meh'
        }
    );
    CityGenerator::generate_area($city);
    is( $city->{'area'},               6.67 );
    is( $city->{'arable_percentage'},  100 );
    is( $city->{'arable_description'}, 'meh' );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 1000, 'population_density' => 300, } );
    CityGenerator::generate_area($city);
    is( $city->{'area'}, 3.33 );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 1000, 'population_density' => 1000 } );
    CityGenerator::generate_area($city);
    is( $city->{'area'}, '1.00' );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 2000, 'population_density' => 1000 } );
    CityGenerator::generate_area($city);
    is( $city->{'area'}, '2.00' );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 3000, 'population_density' => 1000 } );
    CityGenerator::generate_area($city);
    is( $city->{'area'}, '3.00' );

    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => 3000, 'population_density' => 1000, 'area'=>22 } );
    CityGenerator::generate_area($city);
    is( $city->{'area'}, 22);

    done_testing();
};

subtest 'test generate_popdensity' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000' } );
    CityGenerator::generate_popdensity($city);
    is( $city->{'population_density'},  27 );
    is( $city->{'density_description'}, 'sparsely' );

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


subtest 'test generate_travelers' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           7 );
    is( scalar( @{ $city->{'travelers'} } ), 7 );
    isnt( $city->{'travelers'}->[0]->{'race'}, undef );
    isnt( $city->{'travelers'}->[1]->{'race'}, undef );
    isnt( $city->{'travelers'}->[2]->{'race'}, undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'stats' => { 'tolerance' => -5 } } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           0 );
    is( scalar( @{ $city->{'travelers'} } ), 0 );
    is( $city->{'travelers'}->[0]->{'race'}, undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'stats' => { 'tolerance' => 5 } } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           10 );
    is( scalar( @{ $city->{'travelers'} } ), 10 );
    isnt( $city->{'travelers'}->[0]->{'race'}, undef );
    isnt( $city->{'travelers'}->[1]->{'race'}, undef );
    isnt( $city->{'travelers'}->[2]->{'race'}, undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'stats' => { 'tolerance' => 0 } } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           5 );
    is( scalar( @{ $city->{'travelers'} } ), 5 );
    isnt( $city->{'travelers'}->[0]->{'race'}, undef );
    isnt( $city->{'travelers'}->[1]->{'race'}, undef );
    isnt( $city->{'travelers'}->[2]->{'race'}, undef );

    $city = CityGenerator::create_city( { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 2 } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           2 );
    is( scalar( @{ $city->{'travelers'} } ), 2 );
    isnt( $city->{'travelers'}->[0]->{'race'}, undef );
    isnt( $city->{'travelers'}->[1]->{'race'}, undef );
    is( $city->{'travelers'}->[2]->{'race'}, undef );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 2, 'stats' => { 'tolerance' => 5 } } );
    CityGenerator::generate_travelers($city);
    is_deeply(
        $city->{'available_traveler_races'},
        [
            'human',     'bugbear', 'mindflayer', 'lizardfolk', 'minotaur',    'half-elf',
            'hobgoblin', 'elf',     'troglodyte', 'drow',       'lycanthrope', 'halfling',
            'half-orc',  'kobold',  'any',        'deep dwarf', 'half-dwarf',  'orc',
            'gnome',     'other',   'goblin',     'dwarf',      'ogre'
        ]
    );

    $city = CityGenerator::create_city(
        {
            'seed'            => 1,
            'size_modifier'   => 12,
            'traveler_count'  => 2,
            'stats'           => { 'tolerance' => -5 },
            'available_races' => [ 'human', 'half-elf', 'elf', 'halfling', 'half-orc', 'half-dwarf', 'gnome', 'dwarf' ]
        }
    );
    CityGenerator::generate_travelers($city);
    is_deeply( $city->{'available_traveler_races'},
        [ 'human', 'half-elf', 'elf', 'halfling', 'half-orc', 'half-dwarf', 'gnome', 'dwarf' ] );


    $city = CityGenerator::create_city(
        { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 2, 'travelers' => [] } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           2 );
    is( scalar( @{ $city->{'travelers'} } ), 0 );


    $city = CityGenerator::create_city(
        { 'seed' => 1, 'size_modifier' => 12, 'traveler_count' => 6, 'available_traveler_races' => ['human'] } );
    CityGenerator::generate_travelers($city);
    is( $city->{'traveler_count'},           6 );
    is( $city->{'travelers'}->[0]->{'race'}, 'human' );
    is( $city->{'travelers'}->[1]->{'race'}, 'human' );
    is( $city->{'travelers'}->[2]->{'race'}, 'human' );
    is( $city->{'travelers'}->[3]->{'race'}, 'human' );
    is( $city->{'travelers'}->[4]->{'race'}, 'human' );
    is( $city->{'travelers'}->[5]->{'race'}, 'human' );


    #TODO test if they're a specialist, once I add specialists
    done_testing();
};


subtest 'test generate_crime' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, } );
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'},        5 );
    is( $city->{'crime_description'}, 'rampant' );

    $city = CityGenerator::create_city( { 'seed' => 1, 'crime_roll' => 99 } );
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'},        99 );
    is( $city->{'crime_description'}, 'unheard of' );

    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'stats'}->{'education'} = 0;
    $city->{'stats'}->{'authority'} = 0;
    $city->{'moral'}                = 50;
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'},        5 );
    is( $city->{'crime_description'}, 'rampant' );

    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'stats'}->{'education'} = 0;
    $city->{'stats'}->{'authority'} = 0;
    $city->{'moral'}                = 100;
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'}, 10 );

    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'stats'}->{'education'} = 5;
    $city->{'stats'}->{'authority'} = 0;
    $city->{'moral'}                = 50;
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'}, 0 );

    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'stats'}->{'education'} = 0;
    $city->{'stats'}->{'authority'} = 5;
    $city->{'moral'}                = 50;
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'}, 10 );

    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'stats'}->{'education'} = 5;
    $city->{'stats'}->{'authority'} = -5;
    $city->{'moral'}                = 0;
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'}, -10 );

    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'stats'}->{'education'} = -5;
    $city->{'stats'}->{'authority'} = 5;
    $city->{'moral'}                = 100;
    CityGenerator::generate_crime($city);
    is( $city->{'crime_roll'}, 20 );

    $city = CityGenerator::create_city( { 'seed' => 1, 'crime_description' => 'fun' } );
    CityGenerator::generate_crime($city);
    is( $city->{'crime_description'}, 'fun' );

    done_testing();
};


subtest 'test set_dominance' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, } );
    $city->{'available_races'}  = [ 'dwarf', 'human', 'halfling' ];
    $city->{'race percentages'} = [ 85,      10,      3 ];

    $city->{'pop_estimate'} = 93;
    CityGenerator::set_races($city);
    CityGenerator::set_dominance($city);
    is( $city->{'dominance_chance'},      5 );
    is( $city->{'dominant_race'},         'halfling' );
    is( $city->{'dominance_level'},       82 );
    is( $city->{'dominance_description'}, 'brutally oppressive' );

    $city->{'dominance_chance'}      = 1;
    $city->{'dominant_race'}         = undef;
    $city->{'dominance_level'}       = undef;
    $city->{'dominance_description'} = undef;
    CityGenerator::set_dominance($city);
    is( $city->{'dominance_chance'},      1 );
    is( $city->{'dominant_race'},         'dwarf' );
    is( $city->{'dominance_level'},       44 );
    is( $city->{'dominance_description'}, 'cruel' );

    $city->{'dominance_chance'}      = 90;
    $city->{'dominant_race'}         = undef;
    $city->{'dominance_level'}       = undef;
    $city->{'dominance_description'} = undef;
    CityGenerator::set_dominance($city);
    is( $city->{'dominance_chance'},      '90' );
    is( $city->{'dominant_race'},         undef );
    is( $city->{'dominance_level'},       undef );
    is( $city->{'dominance_description'}, undef );

    $city->{'dominance_chance'}      = 5;
    $city->{'dominant_race'}         = undef;
    $city->{'dominance_level'}       = 50;
    $city->{'dominance_description'} = undef;
    CityGenerator::set_dominance($city);
    is( $city->{'dominance_chance'},      5 );
    is( $city->{'dominant_race'},         'dwarf' );
    is( $city->{'dominance_level'},       50 );
    is( $city->{'dominance_description'}, 'cruel' );

    $city->{'dominance_chance'}      = 5;
    $city->{'dominant_race'}         = 'human';
    $city->{'dominance_level'}       = 50;
    $city->{'dominance_description'} = 'smelly';
    CityGenerator::set_dominance($city);
    is( $city->{'dominance_chance'},      5 );
    is( $city->{'dominant_race'},         'human' );
    is( $city->{'dominance_level'},       50 );
    is( $city->{'dominance_description'}, 'smelly' );

    done_testing();
};

subtest 'test generate_housing' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', } );
    CityGenerator::generate_housing($city);
    is_deeply(
        $city->{'housing'},
        {
            'poor'               => 34,
            'wealthy'            => 2,
            'average'            => 70,
            'abandoned'          => 20,
            'total'              => 106,
            'poor_population'    => 500,
            'wealthy_population' => 10,
            'average_population' =>,
            490,
            'poor_percent'    => 50,
            'wealthy_percent' => 1,
            'average_percent' =>,
            49, 'abandoned_percent' => 19
        }
    );
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '1000', 'stats' => { 'economy' => 0 } } );
    CityGenerator::generate_housing($city);
    is_deeply(
        $city->{'housing'},
        {
            'poor'               => 20,
            'wealthy'            => 2,
            'average'            => 98,
            'abandoned'          => 13,
            'total'              => 120,
            'poor_population'    => 300,
            'wealthy_population' => 10,
            'average_population' =>,
            690,
            'poor_percent'    => 30,
            'wealthy_percent' => 1,
            'average_percent' =>,
            69, 'abandoned_percent' => 11
        }
    );


    $city = CityGenerator::create_city(
        {
            'seed'             => 1,
            'population_total' => '10000',
            'stats'            => { 'economy' => 0 },
            'housing'          => {
                'poor'               => 20,
                'wealthy'            => 2,
                'average'            => 98,
                'abandoned'          => 13,
                'total'              => 120,
                'poor_population'    => 300,
                'wealthy_population' => 10,
                'average_population' =>,
                690,
                'poor_percent'    => 30,
                'wealthy_percent' => 1,
                'average_percent' =>,
                69, 'abandoned_percent' => 11
            }
        }
    );
    CityGenerator::generate_housing($city);
    is_deeply(
        $city->{'housing'},
        {
            'poor'               => 20,
            'wealthy'            => 2,
            'average'            => 98,
            'abandoned'          => 13,
            'total'              => 120,
            'poor_population'    => 300,
            'wealthy_population' => 10,
            'average_population' =>,
            690,
            'poor_percent'    => 30,
            'wealthy_percent' => 1,
            'average_percent' =>,
            69, 'abandoned_percent' => 11
        }
    );
    done_testing();
};

subtest 'test generate_specialists' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', } );
    CityGenerator::generate_specialists($city);
    is( $city->{'specialists'}->{'teacher'}->{'count'},    50 );
    is( $city->{'specialists'}->{'magic shop'}->{'count'}, undef );
    is( $city->{'specialists'}->{'porter'}->{'count'},     5 );

    $city = CityGenerator::create_city( { 'seed' => 2, 'population_total' => '50', } );
    CityGenerator::generate_specialists($city);
    is( $city->{'specialists'}->{'maidservant'}->{'count'}, 1 );
    is( $city->{'specialists'}->{'magic shop'}->{'count'},  undef );

    $city = CityGenerator::create_city(
        { 'seed' => 1, 'population_total' => '10000', 'specialists' => { 'porter' => { 'count' => 10 } } } );
    CityGenerator::generate_specialists($city);
    is( $city->{'specialists'}->{'porter'}->{'count'}, 10 );

    done_testing();
};

subtest 'test generate_businesses' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', } );
    CityGenerator::generate_specialists($city);
    CityGenerator::generate_businesses($city);
    is( $city->{'specialists'}->{'teacher'}->{'count'}, 50 );
    is( $city->{'businesses'}->{'school'}->{'count'},   5 );

    #TODO test hardcoded business counts regardless of specialists
    done_testing();
};

subtest 'test generate_districts' => sub {
    my $city;
    $city = CityGenerator::create_city( { 'seed' => 1, 'population_total' => '10000', } );
    CityGenerator::generate_specialists($city);
    CityGenerator::generate_businesses($city);
    CityGenerator::generate_districts($city);
    is( $city->{'specialists'}->{'teacher'}->{'count'},          50 );
    is( $city->{'businesses'}->{'school'}->{'specialist_count'}, 50 );
    is( $city->{'businesses'}->{'school'}->{'count'},            5 );

    done_testing();
};


1;


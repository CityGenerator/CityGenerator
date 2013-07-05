#!/usr/bin/perl -wT
###############################################################################
#
package TestWorldGenerator;

use strict;
use warnings;
use Test::More;
use WorldGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_world' => sub {
    my $world;
    $world=WorldGenerator::create_world();
    is($world->{'seed'},41630);

    $world=WorldGenerator::create_world({'seed'=>12345});
    is($world->{'seed'},12345);
    is($world->{'name'},'Earth');

    $world=WorldGenerator::create_world({'seed'=>12345, 'name'=>'test'});
    is($world->{'seed'},12345);
    is($world->{'name'},'test');

    done_testing();
};



subtest 'test generate_starsystem' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>12345});
    is($world->{'seed'},12345);
    is($world->{'star'}[0]->{'name'}, 'Wocel'   );
    is($world->{'star'}[0]->{'size'}, 'average' );
    is($world->{'star'}[0]->{'color'}, 'red'    );
    $world=WorldGenerator::create_world({'seed'=>765379, 'starsystem_roll'=>98});
    is($world->{'seed'},765379);

    is($world->{'star'}[0]->{'name'}, 'Krolay'  );
    is($world->{'star'}[1]->{'name'}, 'Cek'     );
    is($world->{'star'}[2]->{'name'}, 'Abak'    );

    is($world->{'star'}[0]->{'size'}, 'average' );
    is($world->{'star'}[1]->{'size'}, 'average' );
    is($world->{'star'}[2]->{'size'}, 'average' );

    is($world->{'star'}[0]->{'color'}, 'red'    );
    is($world->{'star'}[1]->{'color'}, 'yellow' );
    is($world->{'star'}[2]->{'color'}, 'orange' );
    done_testing();
};
subtest 'test generate_moons' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379, 'moons_roll'=>"96" });
    is($world->{'seed'},765379);
    is($world->{'moon'}[0]->{'name'}, 'Prolatheus'     );
    is($world->{'moon'}[1]->{'name'}, 'Spota'     );
    is($world->{'moon'}[2]->{'name'}, 'Theme' );

    is($world->{'moon'}[0]->{'size'}, "average" );
    is($world->{'moon'}[1]->{'size'}, "average" );
    is($world->{'moon'}[2]->{'size'}, "average" );

    done_testing();
};

subtest 'test generate_atmosphere' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'atmosphere'}->{'color'}, "blue" );
    is($world->{'atmosphere'}->{'reason'}, "water vapor" );
    $world=WorldGenerator::create_world({'seed'=>765373, 'atmosphere'=>{'reason_roll'=>90}});
    is($world->{'atmosphere'}->{'color'}, "blue" );
    is($world->{'atmosphere'}->{'reason'}, undef );

    done_testing();
};

subtest 'test generate_basetemp' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'basetemp'}, "cold" );
    is($world->{'basetemp_modifier'}, "0.95" );


    done_testing();
};

subtest 'test generate_air' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'air'}, "dense" );

    done_testing();
};

subtest 'test generate_wind' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'wind'}, "incredibly strong" );

    done_testing();
};

subtest 'test generate_celetial_objects' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'celestial_count'}, "2" );
    is($world->{'celestial_roll'}, "85" );
    is($world->{'celestial_name'}, "two celestial objects" );
    is($world->{'celestial'}[0]->{'name'}, "supernova" );
    is($world->{'celestial'}[0]->{'size'}, "imposing" );
    is($world->{'celestial'}[0]->{'age'},  "decades" );

    is($world->{'celestial'}[1]->{'name'}, "nebula" );
    is($world->{'celestial'}[1]->{'size'}, "imposing" );
    is($world->{'celestial'}[1]->{'age'},  "all eternity" );

    is($world->{'celestial'}[2],  undef );

    $world=WorldGenerator::create_world({'seed'=>765373, 'celestial_roll'=>1});
    is($world->{'celestial_count'}, "0" );
    is($world->{'celestial_roll'}, "1" );
    is($world->{'celestial_name'}, "nothing unusual" );
    is($world->{'celestial'}[0],  undef );
    done_testing();

};


subtest 'test generate_year' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'year_roll'}, "72" );
    is($world->{'year'}, "580" );

    $world=WorldGenerator::create_world({'seed'=>765373, 'year_roll'=>1});
    is($world->{'year_roll'}, "1" );
    is($world->{'year'}, "8" );

    done_testing();
};


subtest 'test generate_day' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'day_roll'}, "59" );
    is($world->{'day'}, "32" );

    $world=WorldGenerator::create_world({'seed'=>765373, 'day_roll'=>1});
    is($world->{'day_roll'}, "1" );
    is($world->{'day'}, "12" );

    done_testing();
};


subtest 'test generate_plates' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'plates_roll'}, "46" );
    is($world->{'plates'}, "14" );
    is($world->{'continent_count'}, "4" );

    $world=WorldGenerator::create_world({'seed'=>765373, 'plates_roll'=>1});
    is($world->{'plates_roll'}, "1" );
    is($world->{'plates'}, "8" );
    is($world->{'continent_count'}, "2" );

    done_testing();
};


subtest 'test generate_surface' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'surface_roll'}, "33" );
    is($world->{'surface'}, "504624530" );
    is($world->{'size'}, "average" );
    is($world->{'radius'}, "6336" );
    is($world->{'circumfrence'}, "39810" );

    $world=WorldGenerator::create_world({'seed'=>765373, 'surface_roll'=>1});
    is($world->{'surface_roll'}, "1" );
    is($world->{'surface'}, "71500874" );
    is($world->{'size'}, "tiny" );
    is($world->{'radius'}, "2385" );
    is($world->{'circumfrence'}, "14985" );

    $world=WorldGenerator::create_world({'seed'=>765373, 'surface'=>100000});
    is($world->{'surface_roll'}, "33" );
    is($world->{'surface'}, "100000" );
    is($world->{'size'}, "average" );
    is($world->{'radius'}, "89" );
    is($world->{'circumfrence'}, "559" );

    done_testing();
};


subtest 'test generate_surfacewater' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379});
    is($world->{'seed'},765379);
    is($world->{'surfacewater_percent'}, '43'     );
    is($world->{'surfacewater_description'}, 'common' );

    $world=WorldGenerator::create_world({'seed'=>765379, 'smallstorms_percent'=>1});
    is($world->{'seed'},765379);
    is($world->{'smallstorms_percent'}, '1'     );
    is($world->{'smallstorms_description'}, 'scarce' );
    done_testing();
};

subtest 'test generate_freshwater' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379});
    is($world->{'seed'},765379);
    is($world->{'freshwater_percent'}, '30'     );
    is($world->{'freshwater_description'}, 'rare' );
    $world=WorldGenerator::create_world({'seed'=>765379, 'freshwater_percent'=>1});
    is($world->{'seed'},765379);
    is($world->{'freshwater_percent'}, '1'     );
    is($world->{'freshwater_description'}, 'scarce' );

    done_testing();
};

subtest 'test generate_civilization' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379});
    is($world->{'seed'},765379);
    is($world->{'civilization_percent'}, '17'     );
    is($world->{'civilization_description'}, 'scattered' );
    is($world->{'civilization_modifier'}, '-3' );

    $world=WorldGenerator::create_world({'seed'=>765379, 'civilization_percent'=>1});
    is($world->{'seed'},765379);
    is($world->{'civilization_percent'}, '1'     );
    is($world->{'civilization_description'}, 'crude' );
    is($world->{'civilization_modifier'}, '-5' );

    done_testing();
};

subtest 'test generate_smallstorms' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379});
    is($world->{'seed'},765379);
    is($world->{'smallstorms_percent'}, '4'     );
    is($world->{'smallstorms_description'}, 'scarce' );
    $world=WorldGenerator::create_world({'seed'=>765379, 'smallstorms_percent'=>1});
    is($world->{'seed'},765379);
    is($world->{'smallstorms_percent'}, '1'     );
    is($world->{'smallstorms_description'}, 'scarce' );

    done_testing();
};

subtest 'test generate_precipitation' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379});
    is($world->{'seed'},765379);
    is($world->{'precipitation_percent'}, '91'     );
    is($world->{'precipitation_description'}, 'abundant' );
    $world=WorldGenerator::create_world({'seed'=>765379, 'precipitation_percent'=>1});
    is($world->{'seed'},765379);
    is($world->{'precipitation_percent'}, '1'     );
    is($world->{'precipitation_description'}, 'scarce' );

    done_testing();
};

subtest 'test generate_clouds' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765379});
    is($world->{'seed'},765379);
    is($world->{'clouds_percent'}, '78'     );
    is($world->{'clouds_description'}, 'plentiful' );
    $world=WorldGenerator::create_world({'seed'=>765379, 'clouds_percent'=>1});
    is($world->{'seed'},765379);
    is($world->{'clouds_percent'}, '1'     );
    is($world->{'clouds_description'}, 'scarce' );

    done_testing();
};




1;


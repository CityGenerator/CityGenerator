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
    $world=WorldGenerator::create_world({'seed'=>765379});
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
    is($world->{'atmosphere'}->{'color'}, "yellow" );
    is($world->{'atmosphere'}->{'reason'}, "pollution" );
    $world=WorldGenerator::create_world({'seed'=>765373, 'atmosphere'=>{'reason_roll'=>90}});
    is($world->{'atmosphere'}->{'color'}, "yellow" );
    is($world->{'atmosphere'}->{'reason'}, undef );

    done_testing();
};

subtest 'test generate_basetemp' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'basetemp'}, "warm" );
    is($world->{'basetemp_modifier'}, "1.00" );


    done_testing();
};

subtest 'test generate_air' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'air'}, "humid" );

    done_testing();
};

subtest 'test generate_wind' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'wind'}, "strong" );

    done_testing();
};

subtest 'test generate_celetial_objects' => sub {
    my $world;
    $world=WorldGenerator::create_world({'seed'=>765373});
    is($world->{'celestial_count'}, "2" );
    is($world->{'celestial'}[0]->{'name'}, "supernova" );
    is($world->{'celestial'}[0]->{'size'}, "imposing" );
    is($world->{'celestial'}[0]->{'age'},  "decades" );

    is($world->{'celestial'}[1]->{'name'}, "nebula" );
    is($world->{'celestial'}[1]->{'size'}, "imposing" );
    is($world->{'celestial'}[1]->{'age'},  "all eternity" );

    is($world->{'celestial'}[2],  undef );
    done_testing();

};


1;


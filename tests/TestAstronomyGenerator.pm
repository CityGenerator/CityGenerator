#!/usr/bin/perl -wT
###############################################################################
#
package TestAstronomyGenerator;

use strict;
use warnings;
use Test::More;
use AstronomyGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_astronomy' => sub {
    my $astronomy;
    $astronomy=AstronomyGenerator::create_astronomy();
    is($astronomy->{'seed'},865653);

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>12345});
    is($astronomy->{'seed'},12345);

    done_testing();
};



subtest 'test generate_starsystem' => sub {
    my $astronomy;
    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>12345});
    is($astronomy->{'seed'},12345);
    is($astronomy->{'star'}[0]->{'name'}, 'Krojol'   );
    is($astronomy->{'star'}[0]->{'size'}, 'average' );
    is($astronomy->{'star'}[0]->{'color'}, 'white'    );
    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765379, 'starsystem_roll'=>98});
    is($astronomy->{'seed'},765379);

    is($astronomy->{'star'}[0]->{'name'}, 'Abakel'  );
    is($astronomy->{'star'}[1]->{'name'}, 'Uuror'     );
    is($astronomy->{'star'}[2]->{'name'}, 'Sirek'    );

    is($astronomy->{'star'}[0]->{'size'}, 'average' );
    is($astronomy->{'star'}[1]->{'size'}, 'average' );
    is($astronomy->{'star'}[2]->{'size'}, 'average' );

    is($astronomy->{'star'}[0]->{'color'}, 'white'    );
    is($astronomy->{'star'}[1]->{'color'}, 'yellow' );
    is($astronomy->{'star'}[2]->{'color'}, 'brown' );
    done_testing();
};
subtest 'test generate_moons' => sub {
    my $astronomy;
    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765379, 'moons_roll'=>"96" });
    is($astronomy->{'seed'},765379);
    is($astronomy->{'moon'}[0]->{'name'}, 'Theletheus'     );
    is($astronomy->{'moon'}[1]->{'name'}, 'Elamemos'     );
    is($astronomy->{'moon'}[2]->{'name'}, 'Himaka' );

    is($astronomy->{'moon'}[0]->{'size'}, "large" );
    is($astronomy->{'moon'}[1]->{'size'}, "average" );
    is($astronomy->{'moon'}[2]->{'size'}, "average" );

    done_testing();
};

subtest 'test generate_celetial_objects' => sub {
    my $astronomy;
    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765373, 'celestial_roll'=>70 });
    is($astronomy->{'celestial_count'}, "2" );
    is($astronomy->{'celestial_roll'}, "70" );
    is($astronomy->{'celestial_name'}, "two celestial objects" );
    is($astronomy->{'celestial'}[0]->{'name'}, "pulsar" );
    is($astronomy->{'celestial'}[0]->{'size'}, "massive" );
    is($astronomy->{'celestial'}[0]->{'age'},  "only a few years" );

    is($astronomy->{'celestial'}[1]->{'name'}, "galaxy" );
    is($astronomy->{'celestial'}[1]->{'size'}, "imposing" );
    is($astronomy->{'celestial'}[1]->{'age'},  "time immemorial" );

    is($astronomy->{'celestial'}[2],  undef );

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765373, 'celestial_roll'=>1});
    is($astronomy->{'celestial_count'}, "0" );
    is($astronomy->{'celestial_roll'}, "1" );
    is($astronomy->{'celestial_name'}, "nothing unusual" );
    is($astronomy->{'celestial'}[0],  undef );
    done_testing();

};


1;


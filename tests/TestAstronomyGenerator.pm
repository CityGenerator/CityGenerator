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

    foreach my $fieldname (qw( name size color) ){
        foreach my $id (qw( 0 1 2 ) ){
            isnt($astronomy->{'star'}[$id]->{$fieldname},  undef, " $fieldname for $id" );
        }
    }

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>12345, 'star'=>[{'name'=>'foo', 'size'=>'bar', 'color'=>'baz'}], 'star_description'=>['blah blah']   });

    is($astronomy->{'star'}[0]->{'name'},  'foo' );
    is($astronomy->{'star'}[0]->{'size'},  'bar' );
    is($astronomy->{'star'}[0]->{'color'}, 'baz' );
    is($astronomy->{'star_description'}[0], 'blah blah' );

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>12345, 'star'=>[{'name'=>'foo', 'size_roll'=>50, 'color_roll'=>50}], 'star_description'=>['blah blah']   });

    is($astronomy->{'star'}[0]->{'name'},  'foo' );
    is($astronomy->{'star'}[0]->{'size'},  'average' );
    is($astronomy->{'star'}[0]->{'color'}, 'yellow' );
    is($astronomy->{'star_description'}[0], 'blah blah' );

    done_testing();
};
subtest 'test generate_moons' => sub {
    my $astronomy;
    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765379, 'moons_roll'=>"96" });
    is($astronomy->{'seed'},765379);
    foreach my $fieldname (qw( name size ) ){
        foreach my $id (qw( 0 1 2 ) ){
            isnt($astronomy->{'moon'}[$id]->{$fieldname},  undef, " $fieldname for $id" );
        }
    }

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>12345, 'moon'=>[{'name'=>'foo', 'size'=>'bar', 'color'=>'baz'}], 'moon_description'=>['blah blah']   });

    is($astronomy->{'moon'}[0]->{'name'},  'foo' );
    is($astronomy->{'moon'}[0]->{'size'},  'bar' );
    is($astronomy->{'moon'}[0]->{'color'}, 'baz' );
    is($astronomy->{'moon_description'}[0], 'blah blah' );

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>12345, 'moon'=>[{'name'=>'foo', 'size_roll'=>50, 'color_roll'=>50}], 'moon_description'=>['blah blah']   });

    is($astronomy->{'moon'}[0]->{'name'},  'foo' );
    is($astronomy->{'moon'}[0]->{'size'},  'average' );
    is($astronomy->{'moon'}[0]->{'color'}, 'bone white' );
    is($astronomy->{'moon_description'}[0], 'blah blah' );

    done_testing();
};

subtest 'test generate_celetial_objects' => sub {
    my $astronomy;
    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765373, 'celestial_roll'=>70 });
    is($astronomy->{'celestial_count'}, "2" );
    is($astronomy->{'celestial_roll'}, "70" );
    is($astronomy->{'celestial_name'}, "two celestial objects" );

    foreach my $fieldname (qw( name size ) ){
        foreach my $id (qw( 0 1 ) ){
            isnt($astronomy->{'celestial'}[$id]->{$fieldname},  undef, " $fieldname for $id" );
        }
    }

    is($astronomy->{'celestial'}[2],  undef );

    $astronomy=AstronomyGenerator::create_astronomy({'seed'=>765373, 'celestial_roll'=>1});
    is($astronomy->{'celestial_count'}, "0" );
    is($astronomy->{'celestial_roll'}, "1" );
    is($astronomy->{'celestial_name'}, "nothing unusual" );
    is($astronomy->{'celestial'}[0],  undef );

    done_testing();
};


1;


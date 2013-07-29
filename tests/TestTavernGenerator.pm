#!/usr/bin/perl -wT
###############################################################################
#
package TestTavernGenerator;

use strict;
use warnings;
use Test::More;
use TavernGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_tavern' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Ruby Thug');
    is($tavern->{'stats'}->{'cost'},86);
    is($tavern->{'stats'}->{'popularity'},6);
    is($tavern->{'stats'}->{'size'},46);
    is($tavern->{'stats'}->{'reputation'},95);

    $tavern=TavernGenerator::create_tavern({'seed'=>41630, 'name'=>'test', 'stats'=>{'cost'=>11, 'popularity'=>11, 'size'=>11, 'reputation'=>11}  });
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'test');
    is($tavern->{'stats'}->{'cost'},11);
    is($tavern->{'stats'}->{'popularity'},11);
    is($tavern->{'stats'}->{'size'},11);
    is($tavern->{'stats'}->{'reputation'},11);


    done_testing();
};

subtest 'test generate_bartender' => sub {
    my $tavern;

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    is($tavern->{'bartender'}->{'race'},'orc');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'bartender'=>{'race'=>'dwarf'}});
    is($tavern->{'bartender'}->{'race'},'dwarf');

    done_testing();
};
subtest 'test generate_amenities' => sub {
    my $tavern;

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    is($tavern->{'amenity_count'} ,1);
    is(scalar(@{$tavern->{'amenity'} }) ,1);

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'amenity_count'=>'2'  });
    is($tavern->{'amenity_count'} ,2);
    is(scalar(@{$tavern->{'amenity'} }) ,2);

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'amenity_count'=>'1', 'amenity'=>['grapejuice']  });
    is($tavern->{'amenity_count'} ,1);
    is(scalar(@{$tavern->{'amenity'} }) ,1);
    is($tavern->{'amenity'}->[0]  ,'grapejuice');

    done_testing();
};

subtest 'test generate_violence' => sub {
    my $tavern;

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    is($tavern->{'violence'} ,'swift justice');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'violence'=>'nothing'});
    is($tavern->{'violence'} ,'nothing');

    done_testing();
};
subtest 'test generate_law' => sub {
    my $tavern;

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    is($tavern->{'law'} ,'harasses');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'law'=>'does nothing'});
    is($tavern->{'law'} ,'does nothing');

    done_testing();
};


1;


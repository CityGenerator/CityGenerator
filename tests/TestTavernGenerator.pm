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
    is($tavern->{'name'},'Hungry Bag Roadhouse');

    $tavern=TavernGenerator::create_tavern({'seed'=>12345});
    is($tavern->{'seed'},12345);
    is($tavern->{'name'},'Black Urchin Alehouse');

    $tavern=TavernGenerator::create_tavern({'seed'=>12345, 'name'=>'test'  });
    is($tavern->{'seed'},12345);
    is($tavern->{'name'},'test');

    done_testing();
};

subtest 'test generate_size' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    TavernGenerator::generate_size($tavern);
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Hungry Bag Roadhouse');
    is($tavern->{'size'},'average');
    is($tavern->{'cost_mod'}->{'size'}, '0');
    is($tavern->{'size_cost_mod'},'0');
    is($tavern->{'pop_mod'}->{'size'}, '2');
    is($tavern->{'size_pop_mod'},'2');

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    TavernGenerator::generate_size($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'size'},'average');
    is($tavern->{'cost_mod'}->{'size'}, '0');
    is($tavern->{'size_cost_mod'},'0');
    is($tavern->{'pop_mod'}->{'size'}, '2');
    is($tavern->{'size_pop_mod'},'2');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'size'=>'small'});
    TavernGenerator::generate_size($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'size'},'small');
    is($tavern->{'cost_mod'}->{'size'}, '2');
    is($tavern->{'size_cost_mod'},'2');
    is($tavern->{'pop_mod'}->{'size'}, '1');
    is($tavern->{'size_pop_mod'},'1');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'size'=>'small', 'size_cost_mod'=>'6','size_pop_mod'=>5, 'cost_mod'=>{'size'=>'foo'}, 'pop_mod'=>{'size'=>'bar'},    });
    TavernGenerator::generate_size($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'size'},'small');
    is($tavern->{'cost_mod'}->{'size'}, 'foo');
    is($tavern->{'size_cost_mod'},'6');
    is($tavern->{'pop_mod'}->{'size'}, 'bar');
    is($tavern->{'size_pop_mod'},'5');

    done_testing();
};

subtest 'test generate_condition' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    TavernGenerator::generate_condition($tavern);
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Hungry Bag Roadhouse');
    is($tavern->{'condition'},'poor');
    is($tavern->{'cost_mod'}->{'condition'}, '-2');
    is($tavern->{'condition_cost_mod'},'-2');

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    TavernGenerator::generate_condition($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'condition'},'filthy');
    is($tavern->{'cost_mod'}->{'condition'}, '-3');
    is($tavern->{'condition_cost_mod'},'-3');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'condition'=>'dirty'});
    TavernGenerator::generate_condition($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'condition'},'dirty');
    is($tavern->{'cost_mod'}->{'condition'}, '-2');
    is($tavern->{'condition_cost_mod'},'-2');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'condition'=>'dirty', 'condition_cost_mod'=>'6','condition_pop_mod'=>5, 'cost_mod'=>{'condition'=>'foo'},    });
    TavernGenerator::generate_condition($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'condition'},'dirty');
    is($tavern->{'cost_mod'}->{'condition'}, 'foo');
    is($tavern->{'condition_cost_mod'},'6');

    done_testing();
};

subtest 'test generate_violence' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    TavernGenerator::generate_violence($tavern);
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Hungry Bag Roadhouse');
    is($tavern->{'violence'},'swift justice');

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    TavernGenerator::generate_violence($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'violence'},'calling the city watch');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'violence'=>'dirty'});
    TavernGenerator::generate_violence($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'violence'},'dirty');

    done_testing();
};

subtest 'test generate_law' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    TavernGenerator::generate_law($tavern);
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Hungry Bag Roadhouse');
    is($tavern->{'law'},'accepts bribes from');

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    TavernGenerator::generate_law($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'law'},'protects');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'law'=>'dirty'});
    TavernGenerator::generate_law($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'law'},'dirty');

    done_testing();
};

subtest 'test generate_entertainment' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    TavernGenerator::generate_entertainment($tavern);
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Hungry Bag Roadhouse');
    is($tavern->{'entertainment'},'blackjack');

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    TavernGenerator::generate_entertainment($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'entertainment'},'dice');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'entertainment'=>'dirty'});
    TavernGenerator::generate_entertainment($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'entertainment'},'dirty');

    done_testing();
};

subtest 'test generate_bartender' => sub {
    my $tavern;
    $tavern=TavernGenerator::create_tavern({'seed'=>41630});
    TavernGenerator::generate_bartender($tavern);
    is($tavern->{'seed'},41630);
    is($tavern->{'name'},'Hungry Bag Roadhouse');
    is($tavern->{'bartender'}->{'race'},'goblin');

    $tavern=TavernGenerator::create_tavern({'seed'=>22});
    TavernGenerator::generate_bartender($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'bartender'}->{'race'},'elf');

    $tavern=TavernGenerator::create_tavern({'seed'=>22, 'bartender'=>{'race'=>'dwarf'}});
    TavernGenerator::generate_bartender($tavern);
    is($tavern->{'seed'},22);
    is($tavern->{'name'},'White Urchin Bar');
    is($tavern->{'bartender'}->{'race'},'dwarf');

    done_testing();
};



1;


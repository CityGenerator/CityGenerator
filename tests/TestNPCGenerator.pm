#!/usr/bin/perl -wT
###############################################################################
#
package TestNPCGenerator;

use strict;
use warnings;
use Test::More;
use Pod::Coverage;

use NPCGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );

my $xml = XML::Simple->new();

subtest 'test set_sex' => sub {
    my $npc;
    GenericGenerator::set_seed(1);
    $npc=NPCGenerator::create_npc();
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'she');

    $npc=NPCGenerator::create_npc({'seed'=>4});
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'it');

    $npc=NPCGenerator::create_npc({'seed'=>5});
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'he');

    $npc=NPCGenerator::create_npc({'seed'=>1});
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'he');
    $npc->{'sex'}->{'pronoun'}='she';
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'she');

    done_testing();
};

subtest 'test set_level' => sub {
    my $npc;

    $npc=NPCGenerator::create_npc({'seed'=>5});
    NPCGenerator::set_level($npc);
    is($npc->{'level'},'7');

    $npc=NPCGenerator::create_npc({'seed'=>5,'size_modifier'=>12});
    NPCGenerator::set_level($npc);
    is($npc->{'level'},'19');

    $npc=NPCGenerator::create_npc({seed=>5,'size_modifier'=>20});
    NPCGenerator::set_level($npc);
    is($npc->{'level'},'20');

    $npc=NPCGenerator::create_npc({seed=>5,'size_modifier'=>-20});
    NPCGenerator::set_level($npc);
    is($npc->{'level'},'1');

    $npc=NPCGenerator::create_npc({'seed'=>1});
    $npc->{'level'}=4;
    NPCGenerator::set_level($npc);
    is($npc->{'level'},'4');

    done_testing();
};


subtest 'test create_npc' => sub {
    subtest 'test create_npc race and seed' => sub {
	    my $npc;
	
	    $npc=NPCGenerator::create_npc({'seed'=>1});
	    is($npc->{'race'},'human' );
	
	    $npc=NPCGenerator::create_npc({'seed'=>41630,'race'=>'orc'});
	    is($npc->{'race'},'orc' );
	
	    $npc=NPCGenerator::create_npc({'seed'=>1,'race'=>'elf'});
	    is($npc->{'race'},'elf' , "race is elf when set" );
	    is($npc->{'seed'}, 1 , "seed is 1 when set." );
	
	    done_testing();
    };
    subtest 'test create_npc_acceptable_races' => sub {
	    my $npc;

	    $npc=NPCGenerator::create_npc({'seed'=>41630});
	    is($npc->{'race'},'deep dwarf',  );
	
	    $npc=NPCGenerator::create_npc({'seed'=>1,'available_races'=>['deep dwarf']});
	    is($npc->{'race'},'deep dwarf',  );

	    $npc=NPCGenerator::create_npc({'seed'=>41630,'available_races'=>['deep dwarf','human','halfling']});
	    is_deeply($npc->{'available_races'},['deep dwarf','human','halfling'] );
	    is($npc->{'race'},'halfling'  );

	    done_testing();
    };

    subtest 'test create_npc name' => sub {
        my $npc;
        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
	    is($npc->{'race'},'elf' , "race is elf when set" );
	    is($npc->{'seed'}, 1 , "seed is 1 when set." );
	    is($npc->{'name'}, 'Abaartlleu Heartwing' , "name is set" );
	    done_testing();
    };
    subtest 'test create_npc profession' => sub {
        my $npc;

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'cobbler'  );
        is($npc->{'profession'},'cobbler');
        is($npc->{'business'},'cobblershop');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'priest', 'cobbler'  );
        is($npc->{'profession'},'cobbler');
        is($npc->{'business'},'cobblershop');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'cobbler', 'priest'  );
        is($npc->{'profession'},'priest');
        is($npc->{'business'},'church');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'cobblerone', 'churchle'  );
        is($npc->{'profession'},'churchle');
        is($npc->{'business'},'churchle');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc,  );
        is($npc->{'profession'},'furrier');
        is($npc->{'business'},'furtrade');

	    done_testing();
    };

    subtest 'test create_npc attitudes' => sub {
        my $npc;
        my $tempdata=$NPCGenerator::xml_data;

        $npc={'seed'=>1};
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Anger' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},'Rage' ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  'Hostility' ,   "emotional state" );

	    done_testing();
    };
	done_testing();
};

subtest 'test get_races' => sub {

    my $races=NPCGenerator::get_races();

    is(scalar(@$races),23, "Total of 23 races allowed.");

    done_testing();
};

subtest 'test generate_npc_names' => sub {
    GenericGenerator::set_seed(1);
    my $names=NPCGenerator::generate_npc_names('human',2);
    is(scalar(@$names),2);
    $names=NPCGenerator::generate_npc_names('any',2);
    is(scalar(@$names),2);
    $names=NPCGenerator::generate_npc_names('any','ef');
    is(scalar(@$names),10);
    $names=NPCGenerator::generate_npc_names('any',);
    is(scalar(@$names),10);
    $names=NPCGenerator::generate_npc_names('fakerace',);
    is(scalar(@$names),10);
    done_testing();
};

subtest 'test generate_npc_name' => sub {

    subtest 'test generating Mutt Race' => sub {
        GenericGenerator::set_seed(1);
        my $name=NPCGenerator::generate_npc_name('any');
        is($name,'Doney Blackan');

        for (my $i = 0 ; $i <10 ; $i++){
            GenericGenerator::set_seed(2+$i);
            $name=NPCGenerator::generate_npc_name('half-orc');
            #like($name, qr/(\(orc\)|\(human\))/, "should be human or orc" );
        }
        done_testing();
    };
    subtest 'test generating unknown race' => sub {
        GenericGenerator::set_seed(1);
        my $name=NPCGenerator::generate_npc_name('CongressCritter');
        is($name,'unnamed congresscritter');
        done_testing();
    };





    done_testing();
};


1;

#!/usr/bin/perl -wT
###############################################################################
#
package TestNPCGenerator;

use strict;
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

my $xml = new XML::Simple;
our $names_data = $xml->XMLin( "xml/npcnames.xml", ForceContent => 1, ForceArray => ['allow'] );
our $xml_data = $xml->XMLin( "xml/data.xml", ForceContent => 1, ForceArray => [] );

my $pod=Pod::Coverage->new(package => 'NPCGenerator');


subtest 'test set_sex' => sub {
    my $npc;
    GenericGenerator::set_seed(1);
    $npc=NPCGenerator::create_npc();
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'she');

    GenericGenerator::set_seed(4);
    $npc=NPCGenerator::create_npc();
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'it');

    GenericGenerator::set_seed(5);
    $npc=NPCGenerator::create_npc();
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'he');

    GenericGenerator::set_seed(1);
    $npc=NPCGenerator::create_npc();
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'she');
    $npc->{'sex'}->{'pronoun'}='he';
    NPCGenerator::set_sex($npc);
    is($npc->{'sex'}->{'pronoun'},'he');

    done_testing();
};


subtest 'test create_npc' => sub {
    subtest 'test create_npc race and seed' => sub {
	    my $npc;
	
	    GenericGenerator::set_seed(1);
	    $npc=NPCGenerator::create_npc();
	    is($npc->{'race'},'deep dwarf', "deep dwarf if random race when seed is 1"  );
	    is($npc->{'seed'}, 41630, "random seed selected when set_seed is at 1"  );
	
	    GenericGenerator::set_seed(1);
	    $npc=NPCGenerator::create_npc({'seed'=>1});
	    is($npc->{'race'},'human', "human if random race when seed is 1 regardless of source"  );
	    is($npc->{'seed'}, 1, "random seed selected when set_seed is at 1"  );
	
	    GenericGenerator::set_seed(1);
	    $npc=NPCGenerator::create_npc({'race'=>'orc'});
	    is($npc->{'race'},'orc' , "race is set to orc despite random seed status" );
	    is($npc->{'seed'}, 41630, "random seed selected when set_seed is at 1"  );
	
	    GenericGenerator::set_seed(2);
	    $npc=NPCGenerator::create_npc();
	    is($npc->{'race'},'bugbear', "random race is bugbear when set_seed is at 2"  );
	    is($npc->{'seed'}, 912432, "This is the random seed selected when set_seed is at 2"  );
	    
	    $npc=NPCGenerator::create_npc({'seed'=>1,'race'=>'elf'});
	    is($npc->{'race'},'elf' , "race is elf when set" );
	    is($npc->{'seed'}, 1 , "seed is 1 when set." );
	    GenericGenerator::set_seed();
	
	    done_testing();
    };
    subtest 'test create_npc name' => sub {
        my $npc;
        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
	    is($npc->{'race'},'elf' , "race is elf when set" );
	    is($npc->{'seed'}, 1 , "seed is 1 when set." );
	    is($npc->{'fullname'}, 'Abaartlleu Heartwing' , "fullname is set" );
	    done_testing();
    };
    subtest 'test create_npc profession' => sub {
        my $npc;

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'cobbler'  );
        is($npc->{'profession'},'cobbler');
        is($npc->{'business'},'cobbler');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'church', 'cobbler'  );
        is($npc->{'profession'},'cobbler');
        is($npc->{'business'},'cobbler');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'cobbler', 'church'  );
        is($npc->{'profession'},'priest');
        is($npc->{'business'},'church');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc, 'cobblerone', 'churchle'  );
        is($npc->{'profession'},'churchle');
        is($npc->{'business'},'churchle');

        $npc=NPCGenerator::create_npc({'seed'=>'1', 'race'=>'elf'});
        NPCGenerator::set_profession($npc,  );
        is($npc->{'profession'},'furrier');
        is($npc->{'business'},'furrier');
	    done_testing();
    };

    subtest 'test create_npc attitudes' => sub {
        my $npc;

        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Love' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},'Affection' ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  'Adoration' ,   "emotional state" );


        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>[{'option' => [{ 'option' => [  {'type' => 'Astonishment' }], 'type' => 'Surprise' }],  'type' => 'Shock'}, ] } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Shock' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},'Surprise' ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  'Astonishment' ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>[{'option' => [{  'type' => 'Surprise' }],  'type' => 'Shock'}, ] } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Shock' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},'Surprise' ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>[{'option' => [{ 'option' => 1, 'type' => 'Surprise' }],  'type' => 'Shock'}, ] } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Shock' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},'Surprise' ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>[{'option' => 1,  'type' => 'Shock'}, ] } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Shock' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>[{}, ] } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  undef ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>[{'option' => {},  'type' => 'Shock'}, ] } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  'Shock' ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{'option'=>1  } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  undef ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={ 'attitude'=>{ } };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  undef ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );
        
        $NPCGenerator::xml_data={ 'attitude'=>1 };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  undef ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );

        $NPCGenerator::xml_data={  };
        $npc={};
	    GenericGenerator::set_seed(1);
        NPCGenerator::set_attitudes($npc);
	    is($npc->{'primary_attitude'},  undef ,        "emotional state" );
	    is($npc->{'secondary_attitude'},undef ,   "emotional state" );
	    is($npc->{'ternary_attitude'},  undef ,   "emotional state" );
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
    subtest 'test generating race with no first name' => sub {
        GenericGenerator::set_seed(1);
        my $names_data= {
                            'race' => {
                                        'lamo' => {
                                                    'lastname' => {
                                                                    'post' => [
                                                                                {'content' => 'ey'},
                                                                                {'content' => 'bee'},
                                                                                {'content' => 'sea'},
                                                                            ]
                                           }                                    }                }       };

        $NPCGenerator::names_data=$names_data;
        is(NPCGenerator::generate_npc_name('lamo'),'ey');

        done_testing();
    };
    subtest 'test generating race with no last name' => sub {

        GenericGenerator::set_seed(1);
        my $names_data= {
                            'race' => {
                                        'lamo' => {
                                                    'firstname' => {
                                                                    'post' => [
                                                                                {'content' => 'dee'},
                                                                                {'content' => 'ee'},
                                                                                {'content' => 'ef'},
                                                                            ]
                                           }                                    }                }       };

        $NPCGenerator::names_data=$names_data;
        is(NPCGenerator::generate_npc_name('lamo'),'dee');


        done_testing();
    };








    subtest 'test generating race with full name' => sub {

        GenericGenerator::set_seed(1);
        my $names_data= {
                            'race' => {
                                        'lamo' => {
                                                    'firstname' => {
                                                                    'post' => [
                                                                                {'content' => ''},
                                                                                {'content' => 'ee'},
                                                                                {'content' => 'ef'},
                                                                            ]
                                                                    },
                                                    'lastname' => {
                                                                    'post' => [
                                                                                {'content' => 'aye'},
                                                                                {'content' => 'be'},
                                                                                {'content' => 'sea'},
                                                                            ]
                                                                    }                                    
                                                    }                
                    }       };

        $NPCGenerator::names_data=$names_data;
        is(NPCGenerator::generate_npc_name('lamo'),'sea');


        GenericGenerator::set_seed(1);
        $names_data= {
                            'race' => {
                                        'lamo' => {
                                                    'firstname' => {
                                                                    'post' => [
                                                                                {'content' => 'dee'},
                                                                                {'content' => 'ee'},
                                                                                {'content' => 'ef'},
                                                                            ]
                                                                    },
                                                    'lastname' => {
                                                                    'post' => [
                                                                                {'content' => 'aye'},
                                                                                {'content' => 'be'},
                                                                                {'content' => ''},
                                                                            ]
                                                                    }                                    
                                                    }                
                    }       };

        $NPCGenerator::names_data=$names_data;
        is(NPCGenerator::generate_npc_name('lamo'),'dee');


        done_testing();
    };

    done_testing();
};


1;

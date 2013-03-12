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
our $names_data = $xml->XMLin( "xml/names.xml", ForceContent => 1, ForceArray => ['allow'] );
our $xml_data = $xml->XMLin( "xml/data.xml", ForceContent => 1, ForceArray => [] );

my $pod=Pod::Coverage->new(package => 'NPCGenerator');



subtest 'test get_races' => sub {

    my $races=NPCGenerator::get_races();

    is(scalar(@$races),16, "Total of 16 races allowed.");

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
        is($name,'Doney Blackan   (human)');

        for (my $i = 0 ; $i <10 ; $i++){
            GenericGenerator::set_seed(2+$i);
            $name=NPCGenerator::generate_npc_name('half-orc');
            like($name, qr/(\(orc\)|\(human\))/, "should be human or orc" );
        }
        done_testing();
    };
    subtest 'test generating unknown race' => sub {
        GenericGenerator::set_seed(1);
        my $name=NPCGenerator::generate_npc_name('CongressCritter');
        is($name,'unnamed congresscritter   (congresscritter)');
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
        is(NPCGenerator::generate_npc_name('lamo'),'ey   (lamo)');

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
        is(NPCGenerator::generate_npc_name('lamo'),'dee   (lamo)');


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
        is(NPCGenerator::generate_npc_name('lamo'),'sea   (lamo)');


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
        is(NPCGenerator::generate_npc_name('lamo'),'dee   (lamo)');


        done_testing();
    };

    done_testing();
};


1;

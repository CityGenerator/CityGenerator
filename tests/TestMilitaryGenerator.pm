#!/usr/bin/perl -wT
###############################################################################
#
package TestMilitaryGenerator;

use strict;
use warnings;
use Test::More;
use MilitaryGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_military' => sub {
    my $military;
    set_seed(1);
    $military=MilitaryGenerator::create_military();
    is($military->{'seed'},41630);
    is($military->{'original_seed'},41630);

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    is($military->{'seed'},22);
    is($military->{'original_seed'},22);

    done_testing();
};

subtest 'test generate_preparation' => sub {
    my $military;
    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},41630);
    is($military->{'preparation_roll'},'68');
    is($military->{'preparation'},'properly');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'preparation'}='foo';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'5');
    is($military->{'preparation'},'foo');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'preparation_roll'}='100';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'100');
    is($military->{'preparation'},'perfectly');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'preparation_roll'}='0';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'0');
    is($military->{'preparation'},'abysmally');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'mil_mod'}='-5';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'2');
    is($military->{'preparation'},'abysmally');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'mil_mod'}='-3';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'2');
    is($military->{'preparation'},'abysmally');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'mil_mod'}='1';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'5');
    is($military->{'preparation'},'abysmally');

    set_seed(1);
    $military=MilitaryGenerator::create_military({'seed'=>22});
    $military->{'mil_mod'}='2';
    $military=MilitaryGenerator::generate_preparation($military);
    is($military->{'seed'},22);
    is($military->{'preparation_roll'},'58');
    is($military->{'preparation'},'reasonably well');

    done_testing();
};


subtest 'test generate_favored_tactic' => sub {
    my $military;
    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military=MilitaryGenerator::generate_favored_tactic($military);
    is($military->{'seed'},41630);
    is($military->{'favored tactic'},'guerrilla warfare');

    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military->{'favored tactic'}="spitwads";
    $military=MilitaryGenerator::generate_favored_tactic($military);
    is($military->{'seed'},41630);
    is($military->{'favored tactic'},'spitwads');

    done_testing();
};

subtest 'test generate_reputation' => sub {
    my $military;
    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military=MilitaryGenerator::generate_reputation($military);
    is($military->{'seed'},41630);
    is($military->{'reputation'},'praised');

    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military->{'reputation'}="spitwads";
    $military=MilitaryGenerator::generate_reputation($military);
    is($military->{'seed'},41630);
    is($military->{'reputation'},'spitwads');

    done_testing();
};

subtest 'test generate_favored_weapon' => sub {
    my $military;
    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military=MilitaryGenerator::generate_favored_weapon($military);
    is($military->{'seed'},41630);
    is($military->{'favored weapon'},'slings');

    set_seed(1);
    $military=MilitaryGenerator::create_military();
    $military->{'favored weapon'}="shoes";
    $military=MilitaryGenerator::generate_favored_weapon($military);
    is($military->{'seed'},41630);
    is($military->{'favored weapon'},'shoes');

    done_testing();
};




1;

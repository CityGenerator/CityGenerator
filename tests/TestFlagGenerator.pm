#!/usr/bin/perl -wT
###############################################################################
#
package TestFlagGenerator;

use strict;
use warnings;
use Test::More;
use FlagGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_flag' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    $flag->{'colors'}=undef;
    FlagGenerator::generate_colors($flag);
    is($flag->{'seed'},41630);
    is(@{$flag->{'colors'}},5);
    is($flag->{'colors'}[0]->{'meaning'},undef);
    is($flag->{'colors'}[1]->{'meaning'},'happiness');


    $flag=FlagGenerator::create_flag({'seed'=>12345});
    is($flag->{'seed'},12345);
    is(@{$flag->{'colors'}},5);

    done_testing();
};


subtest 'test generate_shape' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_shape($flag);
    is($flag->{'shape'},'tongued');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'shape'=>'bone'});
    FlagGenerator::generate_shape($flag);
    is($flag->{'shape'},'bone');
};

subtest 'test generate_ratio' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_ratio($flag);
    is($flag->{'ratio'},'1.6');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'ratio'=>3});
    FlagGenerator::generate_ratio($flag);
    is($flag->{'ratio'},'3');
};

subtest 'test generate_division' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_division($flag);
    is($flag->{'division'},'vertical');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'division'=>'bunny'});
    FlagGenerator::generate_division($flag);
    is($flag->{'division'},'bunny');
};

subtest 'test generate_overlay' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_overlay($flag);
    is($flag->{'overlay'}->{'name'},'quad');
    is($flag->{'overlay'}->{'side'},'se');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'overlay'=>{'name'=>'stripe'}});
    FlagGenerator::generate_overlay($flag);
    is($flag->{'overlay'}->{'name'},'stripe');
    is($flag->{'overlay'}->{'side'},'horizontal');
    is($flag->{'overlay'}->{'count'},'9');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'overlay'=>{'name'=>'bunny'}});
    FlagGenerator::generate_overlay($flag);
    is($flag->{'overlay'}->{'name'},'bunny');
};

subtest 'test generate_symbol' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_symbol($flag);
    is($flag->{'symbol'},'letter');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'symbol'=>'bunny'});
    FlagGenerator::generate_symbol($flag);
    is($flag->{'symbol'},'bunny');
};

subtest 'test generate_border' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_border($flag);
    is($flag->{'border'},'scaloped');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'border'=>'bunny'});
    FlagGenerator::generate_border($flag);
    is($flag->{'border'},'bunny');
};

subtest 'test generate_letter' => sub {
    my $flag;
    $flag=FlagGenerator::create_flag({'seed'=>41630});
    FlagGenerator::generate_letter($flag);
    is($flag->{'letter'},'P');

    $flag=FlagGenerator::create_flag({'seed'=>41630, 'letter'=>'b'});
    FlagGenerator::generate_letter($flag);
    is($flag->{'letter'},'b');
};

1;


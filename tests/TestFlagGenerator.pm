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
    set_seed(1);
    $flag=FlagGenerator::create_flag();
    FlagGenerator::generate_colors($flag);
    is($flag->{'seed'},41630);
    is(@{$flag->{'colors'}},5);
    is($flag->{'colors'}[0]->{'meaning'},undef);
    is($flag->{'colors'}[1]->{'meaning'},'happiness');
    print Dumper $flag;


    $flag=FlagGenerator::create_flag({'seed'=>12345});
    FlagGenerator::generate_colors($flag);
    is($flag->{'seed'},12345);
    is(@{$flag->{'colors'}},5);

    $flag=FlagGenerator::create_flag(1);
    FlagGenerator::generate_colors($flag);
    is($flag->{'seed'},442135);
    is(@{$flag->{'colors'}},5);

    done_testing();
};





1;


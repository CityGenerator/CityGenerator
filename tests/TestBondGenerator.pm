#!/usr/bin/perl -wT
###############################################################################
#
package TestBondGenerator;

use strict;
use warnings;

use Data::Dumper;
use Exporter;
use GenericGenerator qw( set_seed );
use BondGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_bond' => sub {
    my $bond;
    $bond = BondGenerator::create_bond();
    foreach my $value (qw( seed other template when_chance name) ){
        isnt($bond->{$value}, undef, "ensure $value is set");
    }
    
    $bond = BondGenerator::create_bond(
        {
            'seed'        => 12,
            'other'       => 'Zeus',
            'template'    => 'Dog and OTHER show.',
            'when_chance'   => 1,
            'reason_chance' => 1,
            'when'        => 'Silly',
            'reason'      => 'Because.'
        }
    );
    is( $bond->{'seed'},        12,                                   'ensure seed is set to 12' );
    is( $bond->{'other'},       'Zeus',                               'ensure other is set' );
    is( $bond->{'template'},    'Dog and OTHER show.',                'ensure other is set' );
    is( $bond->{'when_chance'},   1,                                    'ensure when_chance is set' );
    is( $bond->{'reason_chance'}, 1,                                    'ensure reason_chance is set' );
    is( $bond->{'when'},        'Silly',                              'ensure when is set' );
    is( $bond->{'reason'},      'Because.',                           'ensure reason is set' );
    is( $bond->{'name'},     'Silly, Dog and Zeus show. Because.', 'ensure name is sane' );

    done_testing();
};

1;

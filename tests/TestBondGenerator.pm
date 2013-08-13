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
    foreach my $value (qw( seed other template content name) ){
        isnt($bond->{$value}, undef, "ensure $value is set");
    }

    like ($bond->{'name'}, "/you/i", "make sure you is interpolated.");
    
    $bond = BondGenerator::create_bond(
        {
            'seed'        => 12,
            'other'       => 'Zeus',
            'template'    => 'Dog and [% other %] show.',
            'when_chance'   => 1,
            'reason_chance' => 1,
            'when'        => 'Silly',
            'reason'      => 'Because.'
        }
    );
    is( $bond->{'seed'},        12,                                   'ensure seed is set to 12' );
    is( $bond->{'other'},       'Zeus',                               'ensure other is set' );
    is( $bond->{'template'},    'Dog and [% other %] show.',                'ensure other is set' );
    is( $bond->{'when_chance'},   1,                                    'ensure when_chance is set' );
    is( $bond->{'reason_chance'}, 1,                                    'ensure reason_chance is set' );
    is( $bond->{'when'},        'Silly',                              'ensure when is set' );
    is( $bond->{'reason'},      'Because.',                           'ensure reason is set' );
    is( $bond->{'name'},     'Silly, Dog and Zeus show. Because.', 'ensure name is sane' );

    done_testing();
};
subtest 'test select_reason' => sub {
    my $bond;
    $bond = BondGenerator::create_bond({'seed'=>1, 'reasontype'=>'what',});
    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );

    $bond = BondGenerator::create_bond({'seed'=>1, 'reasontype'=>'what', 'reason_chance'=>100});
    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );
    is( $bond->{'reason_chance'}, '100', 'ensure reason_chance is set' );
    is( $bond->{'reason'}, undef, 'ensure reason is not set' );


    $bond = BondGenerator::create_bond({'seed'=>1, 'reasontype'=>'what', 'reason_chance'=>1});

    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );
    is( $bond->{'reason_chance'}, '1', 'ensure reason_chance is set' );
    isnt( $bond->{'reason'}, undef, 'ensure reason is set' );

    $bond = BondGenerator::create_bond({'seed'=>1, 'reasontype'=>'what','reason_chance'=>1, 'reason'=>'because'});
    is( $bond->{'reasontype'}, 'what', 'ensure reasontype is set' );

    done_testing();
};
1;

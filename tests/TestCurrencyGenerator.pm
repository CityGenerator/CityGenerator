#!/usr/bin/perl -wT
###############################################################################
#
package TestCurrencyGenerator;

use strict;
use warnings;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use CurrencyGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );

subtest 'test create' => sub {
    my $currency;
#    GenericGenerator::set_seed(1);
    $currency = CurrencyGenerator::create( );
    isnt( $currency->{'seed'}, undef, 'ensure seed is set.' );

    print Dumper $currency;
    done_testing();
};

done_testing();

1;

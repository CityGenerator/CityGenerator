#!/usr/bin/perl -wT
package CurrencyGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);


###############################################################################

=head1 NAME

    CurrencyGenerator - used to generate Currencys

=head1 SYNOPSIS

    use CurrencyGenerator;
    my $currency1=CurrencyGenerator::create();
    my $currency2=CurrencyGenerator::create($parameters);

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use NPCGenerator;
use POSIX;
use Template;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CurrencyGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/currencys.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################

my $xml_data        = $xml->XMLin( "xml/data.xml",        ForceContent => 1, ForceArray => ['option'] );
my $currency_data   = $xml->XMLin( "xml/currencies.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the currency structure.

=head3 create()

This method is used to create a simple currency with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create {
    my ($params) = @_;
    my $currency = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $currency->{$key} = $params->{$key};
        }
    }

    if ( !defined $currency->{'seed'} ) {
        $currency->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed( $currency->{'seed'} );
    GenericGenerator::generate_stats($currency,$currency_data);
    GenericGenerator::select_features($currency,$currency_data);

    $currency->{'name'}=ucfirst parse_object($currency_data->{'name'})->{'content'};

    GenericGenerator::parse_template($currency, 'template');
    return $currency;
}



1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 2
of the License.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=head1 DISCLAIMER OF WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut

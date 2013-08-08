#!/usr/bin/perl -wT
###############################################################################

package BondGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_bond);


#TODO make generate_name method for use with namegenerator

###############################################################################

=head1 NAME

    BondGenerator - used to generate Bonds

=head1 SYNOPSIS

    use BondGenerator;
    my $bond=BondGenerator::create_bond();

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by BondGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/bonds.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
my $xml_data        = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
my $bond_data       = $xml->XMLin( "xml/bonds.xml", ForceContent => 1, ForceArray => ['option'] );
###############################################################################

=head2 Core Methods

The following methods are used to create the core of the bond structure.


=head3 create_bond()

This method is used to create a simple bond with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_bond {
    my ($params) = @_;
    my $bond = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $bond->{$key} = $params->{$key};
        }
    }

    if ( !defined $bond->{'seed'} ) {
        $bond->{'seed'} = set_seed();
    }

    return $bond;
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

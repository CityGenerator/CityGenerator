#!/usr/bin/perl -wT
###############################################################################

package EstablishmentGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_establishment);

#TODO make generate_name method for use with namegenerator
###############################################################################

=head1 NAME

    EstablishmentGenerator - used to generate Establishments

=head1 DESCRIPTION

 This can be used to create a Establishment

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/establishments.xml>

=back

=cut

###############################################################################

my $xml_data            = $xml->XMLin( "xml/data.xml",              ForceContent => 1, ForceArray => ['option'] );
my $establishment_data  = $xml->XMLin( "xml/establishments.xml",    ForceContent => 1, ForceArray => ['option'] );

###############################################################################


=head2 create_establishment()

This method is used to create a simple establishment with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_establishment {
    my ($params) = @_;
    my $establishment = {};
    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $establishment->{$key} = $params->{$key};
        }
    }
    $establishment->{'seed'} = set_seed() if ( !defined $establishment->{'seed'} );


    foreach my $stat (qw( reputation size price popularity)) {
        $establishment->{'stats'}->{$stat} = d(100) if ( !defined $establishment->{'stats'}->{$stat} );
        $establishment->{ $stat . "_description" }
            = roll_from_array( $establishment->{'stats'}->{$stat}, $establishment_data->{$stat}->{'option'} )->{'content'}
            if ( !defined $establishment->{ $stat . "_description" } );
    }

    generate_establishment_name($establishment);
    generate_owner($establishment);

    return $establishment;
}


###############################################################################

=head2 generate_establishment_name()

    generate a name for the establishment.

=cut

###############################################################################
sub generate_establishment_name {
    my ($establishment) = @_;
    set_seed( $establishment->{'seed'} );
    my $nameobj = parse_object( $establishment_data->{'name'} );
    $establishment->{'name'} = $nameobj->{'content'} if ( !defined $establishment->{'name'} );
    return $establishment;
}




###############################################################################

=head2 generate_owner()
 
generate the owner for the establishment
 
=cut

###############################################################################

sub generate_owner {
    my ($establishment) = @_;

    if ( !defined $establishment->{'owner'} ) {

        $establishment->{'owner'} = NPCGenerator::create_npc();

        #TODO flesh out npc here, need to add to NPCGenerator.
    }

    return $establishment;

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

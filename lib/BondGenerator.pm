#!/usr/bin/perl -wT
###############################################################################

package BondGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);


###############################################################################

=head1 NAME

    BondGenerator - used to generate Bonds

=head1 SYNOPSIS

    use BondGenerator;
    my $bond=BondGenerator::create();

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use List::Util 'shuffle', 'min', 'max';
use NPCGenerator;
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


=head3 create()

This method is used to create a simple bond with nothing more than:

=over

=item * a seed

=item * content

=back

=cut

###############################################################################
sub create {
    my ($params) = @_;
    my $bond = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $bond->{$key} = $params->{$key};
        }
    }

    if ( !defined $bond->{'seed'} ) {
        $bond->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed($bond->{'seed'});
   
    GenericGenerator::select_features($bond, $bond_data); 

    select_persons($bond);
    select_reason($bond);

    GenericGenerator::parse_template($bond);
    $bond->{'template'}=$bond->{'when'}.", ".$bond->{'template'} if (defined $bond->{'when'} );
    $bond->{'template'}=ucfirst($bond->{'template'});
    $bond->{'template'}=$bond->{'template'}." ".$bond->{'reason'}  if (defined $bond->{'reason'} );

    return $bond;
}


###############################################################################

=head2 select_persons()

generate an npc, and put it, yourself, and one of you again into a 3-person array.

=cut

###############################################################################
sub select_persons{
    my ($bond)=@_;
    my $npc= NPCGenerator::create({'seed'=>$bond->{'seed'} });
    if (!defined $bond->{'other'}){
        $bond->{'other'} = $npc->{'firstname'};
    }
    $bond->{'person'} = [shuffle($bond->{'other'}, 'you'   )];

    push @{$bond->{'person'}}, rand_from_array( $bond->{'person'} );
    return $bond;
}


###############################################################################

=head2 select_reason()

generate an npc, and put it, yourself, and one of you again into a 3-person array.

=cut

###############################################################################
sub select_reason{
    my ($bond)=@_;
    if ( defined $bond->{'reasontype'} ) {
        $bond->{'reason_chance'} = d(100) if ( !defined $bond->{'reason_chance'} );
        if ($bond->{'reason_chance'} < 50 ){
           $bond->{'reason'}= rand_from_array($bond_data->{'reason'}->{$bond->{'reasontype'}}->{'option'})->{'content'} if (!defined $bond->{'reason'});
        }
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

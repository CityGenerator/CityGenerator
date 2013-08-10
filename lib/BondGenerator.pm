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
        $bond->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed($bond->{'seed'});
    
    select_template($bond);
    select_other($bond);
    select_reason($bond);
    select_when($bond);
    parse_template($bond);
    return $bond;
}

sub parse_template{
    my ($bond)=@_;
    if( d(2) == 1){
        $bond->{'PERSON1'}=$bond->{'other'};
        $bond->{'PERSON2'}="you";
    }else{
        $bond->{'PERSON1'}="you";
        $bond->{'PERSON2'}=$bond->{'other'};
    }
    if( d(2) == 1){
        $bond->{'PERSON'}="you";
    }else{
        $bond->{'PERSON'}=$bond->{'other'};
    }
#    print Dumper $bond;
    $bond->{'name'}= $bond->{'template'};
    $bond->{'name'}=~ s/PERSON1/$bond->{'PERSON1'}/gx;
    $bond->{'name'}=~ s/PERSON2/$bond->{'PERSON2'}/gx;
    $bond->{'name'}=~ s/PERSON/$bond->{'PERSON'}/gx;
    $bond->{'name'}=~ s/OTHER/$bond->{'other'}/gx;
    $bond->{'name'}=$bond->{'when'}.", ".$bond->{'name'} if (defined $bond->{'when'} );
    $bond->{'name'}=ucfirst($bond->{'name'});
#TODO are they Amused?
    $bond->{'name'}=$bond->{'name'}." ".$bond->{'reason'}  if (defined $bond->{'reason'} );
    return $bond;
}



sub select_when{
    my ($bond)=@_;
    $bond->{'when_chance'} = d(100) if ( !defined $bond->{'when_chance'} );
    if ($bond->{'when_chance'} < 50 ){
        $bond->{'when'}= rand_from_array($bond_data->{'when'}->{'option'})->{'content'} if (!defined $bond->{'when'});
    }

    return $bond;
}
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


sub select_other{
    my ($bond)=@_;
    my $npc= NPCGenerator::create_npc({'seed'=>$bond->{'seed'} });
#    print Dumper $npc;
    if (!defined $bond->{'other'}){
        $bond->{'other'} = $npc->{'firstname'} || $npc->{'name'};
    }
    return $bond;
}


sub select_template{
    my ($bond)=@_;

    my $template= rand_from_array($bond_data->{'template'}->{'option'});

    $bond->{'template'}=$template->{'content'} if (!defined $bond->{'template'});
    $bond->{'reasontype'}=$template->{'reasontype'} if (!defined $bond->{'reasontype'});

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

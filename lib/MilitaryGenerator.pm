#!/usr/bin/perl -wT
###############################################################################

package MilitaryGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_military);

###############################################################################

=head1 NAME

    MilitaryGenerator - used to generate military statistics

=head1 SYNOPSIS

    use MilitaryGenerator;
    my $military=MilitaryGenerator::create_military($source);
  
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
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item * F<xml/data.xml>

=cut

###############################################################################
my $xml_data = $xml->XMLin( "xml/data.xml", ForceContent => 1, ForceArray => ['option'] );


###############################################################################

=head2 Core Methods

The following methods are used to create the core of the military structure.


=head3 create_military()

This method is used to create a simple military from a given object.

=over

=item * a seed

=item * a source name

=item * a size classification

=item * a population estimation

=back

=cut

###############################################################################
sub create_military {
    my ($params) = @_;
    my $military = {};

    # swipe important details from params
    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $military->{$key} = $params->{$key};
        }
    }

    if ( !defined $military->{'seed'} ) {
        $military->{'seed'} = set_seed();
    }
    GenericGenerator::set_seed($military->{'seed'});

    generate_fortification($military);
    generate_preparation($military);
    generate_favored_tactic($military);
    generate_reputation($military);
    generate_weapon_reputation($military);
    generate_favored_weapon($military);
    set_troop_size($military);
    return $military;
}

###############################################################################

=head2 generate_fortification()
    
Determine how well prepared they are, which is influenced by the "military" stat
for the provided source.

=cut

###############################################################################

sub generate_fortification {
    my ($military) = @_;

    GenericGenerator::set_seed($military->{'seed'}+ 1);
    if ( !defined $military->{'fortification_roll'} ) {
        $military->{'fortification_roll'} = &d(100);
    }
    #Yes, fortification uses the same xml as preparation
    $military->{'fortification'}
        = roll_from_array( $military->{'fortification_roll'}, $xml_data->{'preparation'}->{'option'} )->{'content'}
        if ( !defined $military->{'fortification'} );
    return $military;
}


###############################################################################

=head2 generate_preparation()
    
Determine how well prepared they are, which is influenced by the "military" stat
for the provided source.

=cut

###############################################################################

sub generate_preparation {
    my ($military) = @_;
    GenericGenerator::set_seed($military->{'seed'}+2);

    if ( !defined $military->{'preparation_roll'} ) {
        if ( defined $military->{'mil_mod'} && $military->{'mil_mod'} < -1 ) {
            $military->{'preparation_roll'} = &d(45);
        } elsif ( $military->{'mil_mod'} && $military->{'mil_mod'} > 1 ) {
            $military->{'preparation_roll'} = 56 + &d(45);
        } else {
            $military->{'preparation_roll'} = &d(100);
        }
    }
    $military->{'preparation'}
        = roll_from_array( $military->{'preparation_roll'}, $xml_data->{'preparation'}->{'option'} )->{'content'}
        if ( !defined $military->{'preparation'} );
    return $military;
}

###############################################################################

=head2 generate_favored_tactic()

    generate favored_tactics in battle

=cut

###############################################################################

sub generate_favored_tactic {
    my ($military) = @_;
    GenericGenerator::set_seed($military->{'seed'}+3);

    my $tactic = rand_from_array( $xml_data->{'tactictypes'}->{'option'} )->{'content'};
    $military->{'favored tactic'} = $tactic if ( !defined $military->{'favored tactic'} );
    return $military;
}


###############################################################################

=head2 generate_reputation()

    generate favored_tactics in battle

=cut

###############################################################################

sub generate_reputation {
    my ($military) = @_;

    GenericGenerator::set_seed($military->{'seed'}+4);
    my $rep = rand_from_array( $xml_data->{'reputation'}->{'option'} )->{'content'};
    $military->{'reputation'} = $rep if ( !defined $military->{'reputation'} );
    return $military;
}


###############################################################################

=head2 generate_weapon_reputation()

    generate weapon reputation in battle

=cut

###############################################################################

sub generate_weapon_reputation {
    my ($military) = @_;

    GenericGenerator::set_seed($military->{'seed'}+5);
    my $rep = rand_from_array( $xml_data->{'reputation'}->{'option'} )->{'content'};
    $military->{'weapon reputation'} = $rep if ( !defined $military->{'weapon reputation'} );
    return $military;
}

###############################################################################

=head2 generate_favored_weapon()

generate favored_weapon preferred by the military.

=cut

###############################################################################

sub generate_favored_weapon {
    my ($military) = @_;
    GenericGenerator::set_seed($military->{'seed'}+6);

    my $weaponclass = rand_from_array( $xml_data->{'weapontypes'}->{'weapon'} );
    $military->{'favored weapon'} = rand_from_array( $weaponclass->{'option'} )->{'content'}
        if ( !defined $military->{'favored weapon'} );

    return $military;
}


###############################################################################

=head2 set_troop_size()

Set the size of the troops for the population

=cut

###############################################################################

sub set_troop_size {
    my ($military) = @_;
    GenericGenerator::set_seed($military->{'seed'}+7);

    #If no population total is provided, make one up!
    $military->{'population_total'} = d(1000) * 10 if ( !defined $military->{'population_total'} );

    my $percentmod = 10 + ( $military->{'military_mod'} || 0 ) + ( $military->{'authority_mod'} || 0 );

    $military->{'active_percent'} = 10 + $percentmod / 4 + d($percentmod) / 4
        if ( !defined $military->{'active_percent'} );
    $military->{'reserve_percent'} = 5 + d($percentmod) / 4 if ( !defined $military->{'reserve_percent'} );
    $military->{'para_percent'}    = 3 + d($percentmod) / 4 if ( !defined $military->{'para_percent'} );

    $military->{'active_troops'} = int( $military->{'population_total'} * $military->{'active_percent'} / 100 )
        if ( !defined $military->{'active_troops'} );
    $military->{'reserve_troops'} = int( $military->{'population_total'} * $military->{'reserve_percent'} / 100 )
        if ( !defined $military->{'reserve_troops'} );
    $military->{'para_troops'} = int( $military->{'active_troops'} * $military->{'para_percent'} / 100 )
        if ( !defined $military->{'para_troops'} );

    return $military;
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

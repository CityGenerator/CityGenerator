#!/usr/bin/perl -wT
###############################################################################

package AstronomyGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_astronomy generate_star_name generate_moon_name);

###############################################################################

=head1 NAME

    AstronomyGenerator - used to generate Astronomical features

=head1 SYNOPSIS

    use AstronomyGenerator;
    my $astronomy=AstronomyGenerator::create_astronomy();

=cut

###############################################################################

use Carp;
use CGI;
use ContinentGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use Lingua::EN::Inflect qw(A);
use List::Util 'shuffle', 'min', 'max';
use Math::Trig ':pi';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by AstronomyGenerator.pm:

=over

=item F<xml/astronomydata.xml>

=item F<xml/moonnames.xml>

=item F<xml/starnames.xml>

=back

=head1 INTERFACE


=cut

###############################################################################
my $astronomy_data = $xml->XMLin( "xml/astronomydata.xml", ForceContent => 1, ForceArray => [ 'option', 'reason' ] );
my $starnames_data = $xml->XMLin( "xml/starnames.xml",     ForceContent => 1, ForceArray => ['option'] );
my $moonnames_data = $xml->XMLin( "xml/moonnames.xml",     ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the astronomy structure.


=head3 create_astronomy()

This method is used to create a simple astronomy with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_astronomy {
    my ($params) = @_;
    my $astronomy = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $astronomy->{$key} = $params->{$key};
        }
    }

    if ( !defined $astronomy->{'seed'} ) {
        $astronomy->{'seed'} = set_seed();
    }

    $astronomy = generate_starsystem($astronomy);
    $astronomy = generate_moons($astronomy);
    $astronomy = generate_celestial_objects($astronomy);

    return $astronomy;
} ## end sub create_astronomy


###############################################################################

=head3 generate_starsystem()

    generate a starsystem.

=cut

###############################################################################
sub generate_starsystem {
    my ($astronomy) = @_;
    set_seed( $astronomy->{'seed'} + length( ( caller(0) )[3] ) );

    $astronomy->{'starsystem_roll'} = d(100) if ( !defined $astronomy->{'starsystem_roll'} );

    my $starsystem = roll_from_array( $astronomy->{'starsystem_roll'}, $astronomy_data->{'stars'}->{'option'} );
    $astronomy->{'starsystem_count'} = $starsystem->{'count'};
    $astronomy->{'starsystem_name'}  = $starsystem->{'content'};
    $astronomy->{'star'}             = [] if ( !defined $astronomy->{'star'} );
    $astronomy->{'star_description'} = [] if ( !defined $astronomy->{'star_description'} );
    for ( my $starid = 0 ; $starid < $astronomy->{'starsystem_count'} ; $starid++ ) {
        generate_star( $astronomy, $starid );
    }

    return $astronomy;
}
###############################################################################

=head3 generate_moons()

    generate a moons for the astronomy.

=cut

###############################################################################
sub generate_moons {
    my ($astronomy) = @_;
    set_seed( $astronomy->{'seed'} + length( ( caller(0) )[3] ) );

    $astronomy->{'moons_roll'} = d(100) if ( !defined $astronomy->{'moons_roll'} );

    my $moons = roll_from_array( $astronomy->{'moons_roll'}, $astronomy_data->{'moons'}->{'option'} );
    $astronomy->{'moons_count'} = $moons->{'count'};
    $astronomy->{'moons_name'}  = $moons->{'content'};

    $astronomy->{'moon'} = [] if ( !defined $astronomy->{'moon'} );
    for ( my $moonid = 0 ; $moonid < $astronomy->{'moons_count'} ; $moonid++ ) {
        generate_moon( $astronomy, $moonid );
    }

    return $astronomy;
}


###############################################################################

=head3 generate_star()

    generate details for a single star.

=cut

###############################################################################
sub generate_star {
    my ( $astronomy, $id ) = @_;

    $id = 0 if ( !defined $id );
    set_seed( $astronomy->{'seed'} + length( ( caller(0) )[3] ) + $id );

    my $nameobj = parse_object($starnames_data);
    $astronomy->{'star'}[$id]->{'name'} = $nameobj->{'content'} if ( !defined $astronomy->{'star'}[$id]->{'name'} );

    $astronomy->{'star'}[$id]->{'color_roll'} = d(100) if ( !defined $astronomy->{'star'}[$id]->{'color_roll'} );
    $astronomy->{'star'}[$id]->{'color'}
        = roll_from_array( $astronomy->{'star'}[$id]->{'color_roll'}, $astronomy_data->{'starcolor'}->{'option'} )
        ->{'content'}
        if ( !defined $astronomy->{'star'}[$id]->{'color'} );

    $astronomy->{'star'}[$id]->{'size_roll'} = d(100) if ( !defined $astronomy->{'star'}[$id]->{'size_roll'} );
    $astronomy->{'star'}[$id]->{'size'}
        = roll_from_array( $astronomy->{'star'}[$id]->{'size_roll'}, $astronomy_data->{'size'}->{'option'} )
        ->{'content'}
        if ( !defined $astronomy->{'star'}[$id]->{'size'} );

    $astronomy->{'star_description'}[$id]
        = $astronomy->{'star'}[$id]->{'name'} . ", "
        . A( $astronomy->{'star'}[$id]->{'size'} . " " . $astronomy->{'star'}[$id]->{'color'} . " star" )
        if ( !defined $astronomy->{'star_description'}[$id] );


    return $astronomy;
}


###############################################################################

=head3 generate_moon()

    generate a name for a moon.

=cut

###############################################################################
sub generate_moon {
    my ( $astronomy, $id ) = @_;

    $id = 0 if ( !defined $id );
    set_seed( $astronomy->{'seed'} + length( ( caller(0) )[3] ) + $id );
    my $nameobj = parse_object($moonnames_data);
    $astronomy->{'moon'}[$id]->{'name'} = $nameobj->{'content'} if ( !defined $astronomy->{'moon'}[$id]->{'name'} );

    $astronomy->{'moon'}[$id]->{'color_roll'} = d(100) if ( !defined $astronomy->{'moon'}[$id]->{'color_roll'} );
    $astronomy->{'moon'}[$id]->{'color'}
        = roll_from_array( $astronomy->{'moon'}[$id]->{'color_roll'}, $astronomy_data->{'mooncolor'}->{'option'} )
        ->{'content'}
        if ( !defined $astronomy->{'moon'}[$id]->{'color'} );

    $astronomy->{'moon'}[$id]->{'size_roll'} = d(100) if ( !defined $astronomy->{'moon'}[$id]->{'size_roll'} );
    $astronomy->{'moon'}[$id]->{'size'}
        = roll_from_array( $astronomy->{'moon'}[$id]->{'size_roll'}, $astronomy_data->{'size'}->{'option'} )
        ->{'content'}
        if ( !defined $astronomy->{'moon'}[$id]->{'size'} );

    $astronomy->{'moon_description'}[$id]
        = $astronomy->{'moon'}[$id]->{'name'} . ", "
        . A( $astronomy->{'moon'}[$id]->{'size'} . " " . $astronomy->{'moon'}[$id]->{'color'} . " moon" )
        if ( !defined $astronomy->{'moon_description'}[$id] );
    return $astronomy;
}

###############################################################################

=head3 generate_celestial()

    generate details for a single celestial object.

=cut

###############################################################################
sub generate_celestial {
    my ( $astronomy, $id ) = @_;

    $id = 0 if ( !defined $id );
    set_seed( $astronomy->{'seed'} + length( ( caller(0) )[3] ) + $id );


    $astronomy->{'celestial'}[$id]->{'size'}
        = rand_from_array( $astronomy_data->{'celestial'}->{'size'}->{'option'} )->{'content'}
        if ( !defined $astronomy->{'celestial'}[$id]->{'size'} );
    $astronomy->{'celestial'}[$id]->{'age'}
        = rand_from_array( $astronomy_data->{'celestial'}->{'age'}->{'option'} )->{'content'}
        if ( !defined $astronomy->{'celestial'}[$id]->{'age'} );
    $astronomy->{'celestial'}[$id]->{'name'}
        = rand_from_array( $astronomy_data->{'celestial'}->{'name'}->{'option'} )->{'content'}
        if ( !defined $astronomy->{'celestial'}[$id]->{'name'} );

    $astronomy->{'celestial_description'}[$id]
        = A( $astronomy->{'celestial'}[$id]->{'size'} . " " . $astronomy->{'celestial'}[$id]->{'name'} )
        . " that has been around for "
        . $astronomy->{'celestial'}[$id]->{'age'}
        if ( !defined $astronomy->{'celestial_description'}[$id] );


    return $astronomy;
}


###############################################################################

=head3 generate_celestial_objects()

    generate nearby celestial objects for the planet.

=cut

###############################################################################
sub generate_celestial_objects {
    my ($astronomy) = @_;

    set_seed( $astronomy->{'seed'} + length( ( caller(0) )[3] ) );

    $astronomy->{'celestial_roll'} = d(100) if ( !defined $astronomy->{'celestial_roll'} );
    my $celestial
        = roll_from_array( $astronomy->{'celestial_roll'}, $astronomy_data->{'celestial'}->{'number'}->{'option'} );
    $astronomy->{'celestial_count'} = $celestial->{'count'} if ( !defined $astronomy->{'celestial_count'} );
    $astronomy->{'celestial_name'}  = $celestial->{'type'}  if ( !defined $astronomy->{'celestial_name'} );

    $astronomy->{'celestial'}             = [] if ( !defined $astronomy->{'celestial'} );
    $astronomy->{'celestial_description'} = [] if ( !defined $astronomy->{'celestial_description'} );
    for ( my $celestialid = 0 ; $celestialid < $astronomy->{'celestial_count'} ; $celestialid++ ) {
        generate_celestial( $astronomy, $celestialid );
    }


    return $astronomy;
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

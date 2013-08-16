#!/usr/bin/perl -wT
###############################################################################

package WorldGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_world generate_name);

#FIXME TODO I don't need to reassign back to world when passing in a reference
# i.e. I can simplify $world=generate_foo($world); as generate_foo($world);
###############################################################################

=head1 NAME

    WorldGenerator - used to generate Worlds

=head1 SYNOPSIS

    use WorldGenerator;
    my $world=WorldGenerator::create_world();

=cut

###############################################################################

use Carp;
use CGI;
use ContinentGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use AstronomyGenerator;
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

The following datafiles are used by WorldGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/worldnames.xml>

=back

=head1 INTERFACE


=cut

###############################################################################
my $world_data = $xml->XMLin( "xml/worlddata.xml", ForceContent => 1, ForceArray => [ 'option', 'reason' ] );
my $worldnames_data = $xml->XMLin( "xml/worldnames.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the world structure.


=head3 create_world()

This method is used to create a simple world with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_world {
    my ($params) = @_;
    my $world = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $world->{$key} = $params->{$key};
        }
    }

    if ( !defined $world->{'seed'} ) {
        $world->{'seed'} = GenericGenerator::set_seed();
    }

    generate_name($world);
    generate_atmosphere($world);
    generate_astronomy($world);
    generate_basetemp($world);
    generate_air($world);
    generate_wind($world);
    generate_year($world);
    generate_day($world);
    generate_plates($world);
    generate_surface($world);
    generate_surfacewater($world);
    generate_freshwater($world);
    generate_civilization($world);
    generate_smallstorms($world);
    generate_precipitation($world);
    generate_clouds($world);
    return $world;
} ## end sub create_world


###############################################################################

=head3 generate_name()

    generate a name for the world.

=cut

###############################################################################
sub generate_name {
    my ($world) = @_;
    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    my $nameobj = parse_object($worldnames_data);
    $world->{'name'} = $nameobj->{'content'} if ( !defined $world->{'name'} );
    return $world;
}


###############################################################################

=head3 generate_atmosphere()

    generate anatmosphere.

=cut

###############################################################################
sub generate_atmosphere {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );

    $world->{'atmosphere'}->{'color_roll'} = d(100) if ( !defined $world->{'atmosphere'}->{'color_roll'} );
    my $atmosphere = roll_from_array( $world->{'atmosphere'}->{'color_roll'}, $world_data->{'atmosphere'}->{'option'} );

    $world->{'atmosphere'}->{'color'} = $atmosphere->{'color'} if ( !defined $world->{'atmosphere'}->{'color'} );

    $world->{'atmosphere'}->{'reason_roll'} = d(100) if ( !defined $world->{'atmosphere'}->{'reason_roll'} );

    if ( $world->{'atmosphere'}->{'reason_roll'} < $world_data->{'atmosphere'}->{'reason_chance'}
        and defined $atmosphere->{'reason'} )
    {
        $world->{'atmosphere'}->{'reason'}
            = roll_from_array( $world->{'atmosphere'}->{'reason_roll'}, $atmosphere->{'reason'} )->{'content'}
            if ( !defined $world->{'atmosphere'}->{'reason'} );
    }

    return $world;
}


###############################################################################

=head3 generate_basetemp()

    generate base temperature and the population modifier.

=cut

###############################################################################
sub generate_basetemp {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );

    my $basetemp = rand_from_array( $world_data->{'basetemp'}->{'option'} );
    $world->{'basetemp'}          = $basetemp->{'content'} if ( !defined $world->{'basetemp'} );
    $world->{'basetemp_modifier'} = $basetemp->{'pop_mod'} if ( !defined $world->{'basetemp_modifier'} );


    return $world;
}


###############################################################################

=head3 generate_air()

    generate air conditions on the planet.

=cut

###############################################################################
sub generate_air {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    $world->{'air'} = rand_from_array( $world_data->{'air'}->{'option'} )->{'content'} if ( !defined $world->{'air'} );

    return $world;
}


###############################################################################

=head3 generate_wind()

    generate wind conditions on the planet.

=cut

###############################################################################
sub generate_wind {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    $world->{'wind'} = rand_from_array( $world_data->{'wind'}->{'option'} )->{'content'}
        if ( !defined $world->{'wind'} );

    return $world;
}


###############################################################################

=head3 generate_year()

    generate length of a year (in days) planet.

=cut

###############################################################################
sub generate_year {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    $world->{'year_roll'} = d(100) if ( !defined $world->{'year_roll'} );

    my $year = roll_from_array( $world->{'year_roll'}, $world_data->{'year'}->{'option'} );
    $world->{'year'} = int( rand( $year->{'maxday'} - $year->{'minday'} ) + $year->{'minday'} )
        if ( !defined $world->{'year'} );

    return $world;
}


###############################################################################

=head3 generate_day()

    generate length of a day (in hours) planet.

=cut

###############################################################################
sub generate_day {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    $world->{'day_roll'} = d(100) if ( !defined $world->{'day_roll'} );

    my $day = roll_from_array( $world->{'day_roll'}, $world_data->{'day'}->{'option'} );
    $world->{'day'} = int( rand( $day->{'maxhour'} - $day->{'minhour'} ) + $day->{'minhour'} )
        if ( !defined $world->{'day'} );

    return $world;
}


###############################################################################

=head3 generate_plates()

    generate the number of tectonic plates on a planet.

=cut

###############################################################################
sub generate_plates {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    $world->{'plates_roll'} = d(100) if ( !defined $world->{'plates_roll'} );

    my $plates = roll_from_array( $world->{'plates_roll'}, $world_data->{'plates'}->{'option'} );
    $world->{'plates'} = int( rand( $plates->{'maxplate'} - $plates->{'minplate'} ) + $plates->{'minplate'} )
        if ( !defined $world->{'plates'} );
    $world->{'continent_count'} = int( $world->{'plates'} / 3 );
    return $world;
}


###############################################################################

=head3 generate_surface()

    generate the number of tectonic surface on a planet.

=cut

###############################################################################
sub generate_surface {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );
    $world->{'surface_roll'} = d(100) if ( !defined $world->{'surface_roll'} );

    my $surface = roll_from_array( $world->{'surface_roll'}, $world_data->{'surface'}->{'option'} );
    $world->{'surface'} = int( rand( $surface->{'maxkm'} - $surface->{'minkm'} ) + $surface->{'minkm'} )
        if ( !defined $world->{'surface'} );
    $world->{'size'} = $surface->{'size'} if ( !defined $world->{'size'} );

    # Calculated values
    $world->{'radius'} = int sqrt( $world->{'surface'} / ( 4 * pi ) ) if ( !defined $world->{'radius'} );
    $world->{'circumfrence'} = int( pi * $world->{'radius'} * 2 );


    return $world;
}


###############################################################################

=head3 generate_surfacewater()

    generate surfacewater for the planet.

=cut

###############################################################################
sub generate_surfacewater {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );


    $world->{'surfacewater_percent'} = d(100) if ( !defined $world->{'surfacewater_percent'} );
    $world->{'surfacewater_description'}
        = roll_from_array( $world->{'surfacewater_percent'}, $world_data->{'surfacewater'}->{'option'} )->{'content'}
        if ( !defined $world->{'surfacewater_description'} );

    return $world;
}


###############################################################################

=head3 generate_freshwater()

    generate freshwater for the planet.

=cut

###############################################################################
sub generate_freshwater {
    my ($world) = @_;

    # adding +1 so it doesn't match surface water exactly...
    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );


    $world->{'freshwater_percent'} = d(100) if ( !defined $world->{'freshwater_percent'} );
    $world->{'freshwater_description'}
        = roll_from_array( $world->{'freshwater_percent'}, $world_data->{'freshwater'}->{'option'} )->{'content'}
        if ( !defined $world->{'freshwater_description'} );

    return $world;
}

###############################################################################

=head3 generate_civilization()

    generate civilization for the planet.

=cut

###############################################################################
sub generate_civilization {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );


    $world->{'civilization_percent'} = d(100) if ( !defined $world->{'civilization_percent'} );
    my $civilization = roll_from_array( $world->{'civilization_percent'}, $world_data->{'civilization'}->{'option'} );
    $world->{'civilization_description'} = $civilization->{'content'}
        if ( !defined $world->{'civilization_description'} );
    $world->{'civilization_modifier'} = $civilization->{'modifier'} if ( !defined $world->{'civilization_modifier'} );

    return $world;
}


###############################################################################

=head3 generate_smallstorms()

    generate smallstorms for the planet.

=cut

###############################################################################
sub generate_smallstorms {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );


    $world->{'smallstorms_percent'} = d(100) if ( !defined $world->{'smallstorms_percent'} );
    $world->{'smallstorms_description'}
        = roll_from_array( $world->{'smallstorms_percent'}, $world_data->{'smallstorms'}->{'option'} )->{'content'}
        if ( !defined $world->{'smallstorms_description'} );

    return $world;
}


###############################################################################

=head3 generate_precipitation()

    generate precipitation for the planet.

=cut

###############################################################################
sub generate_precipitation {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );


    $world->{'precipitation_percent'} = d(100) if ( !defined $world->{'precipitation_percent'} );
    $world->{'precipitation_description'}
        = roll_from_array( $world->{'precipitation_percent'}, $world_data->{'precipitation'}->{'option'} )->{'content'}
        if ( !defined $world->{'precipitation_description'} );

    return $world;
}


###############################################################################

=head3 generate_clouds()

    generate clouds for the planet.

=cut

###############################################################################
sub generate_clouds {
    my ($world) = @_;

    set_seed( $world->{'seed'} + length( ( caller(0) )[3] ) );

    $world->{'clouds_percent'} = d(100) if ( !defined $world->{'clouds_percent'} );
    $world->{'clouds_description'}
        = roll_from_array( $world->{'clouds_percent'}, $world_data->{'clouds'}->{'option'} )->{'content'}
        if ( !defined $world->{'clouds_description'} );

    return $world;
}


###############################################################################

=head3 generate_astronomy()

    generate astronomical stuff for the planet

=cut

###############################################################################
sub generate_astronomy {
    my ($world) = @_;

    $world->{'astronomy'} = AstronomyGenerator::create_astronomy( { 'seed' => $world->{'seed'} } )
        if ( !defined $world->{'astronomy'} );

    return $world;
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

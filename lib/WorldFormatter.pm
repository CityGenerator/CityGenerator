#!/usr/bin/perl -wT
###############################################################################

package WorldFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printSummary);

###############################################################################

=head1 NAME

    WorldFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a world, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use JSON;
use Lingua::Conjunction;
use Lingua::EN::Inflect qw(A);
use Lingua::EN::Numbers qw(num2en);
use Number::Format;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

###############################################################################

=head2 printSummary()

printSummary strips out important info from a World object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($world) = @_;
    my $content = "";
    $content
        .= "$world->{'name'} is "
        . A( $world->{'size'} )
        . ", $world->{'basetemp'} planet orbiting "
        . A( $world->{'astronomy'}->{'starsystem_name'} ) . ".\n";
    $content
        .= "$world->{'name'} has a $world->{'astronomy'}->{'moons_name'}, "
        . A( $world->{'air'} )
        . " $world->{'atmosphere'}->{'color'} atmosphere and fresh water is $world->{'freshwater_description'}.\n";
    $content .= "The surface of the planet is $world->{'surfacewater_percent'}% covered by water.\n";
    return $content;
}


###############################################################################

=head2 printSkySummary()

printSkySummary strips out important info from a World object and returns formatted text.

=cut

###############################################################################
sub printSkySummary {
    my ($world)    = @_;
    my $content    = "";
    my $stars      = conjunction( @{ $world->{'astronomy'}->{'star_description'} } );
    my $moons      = printMoonList($world);
    my $celestials = printCelestialList($world);
    my $atmosphere = printAtmosphere($world);
    $content .= "$world->{'name'} orbits " . A( $world->{'astronomy'}->{'starsystem_name'} ) . ": $stars.\n";
    $content .= "$world->{'name'} also has $moons.\n";
    $content .= "In the night sky, you see $celestials.\n";
    $content .= "During the day, the sky is $atmosphere.\n";


    return $content;
}

###############################################################################

=head2 printAtmosphere()

printAtmosphere gives a nice sentence describing the atmosphereic conditions and 
reasons for it

=cut

###############################################################################
sub printAtmosphere {
    my ($world) = @_;
    my $content = $world->{'atmosphere'}->{'color'};
    if ( defined $world->{'atmosphere'}->{'reason'} ) {
        $content .= ", which is partially due to " . $world->{'atmosphere'}->{'reason'};
    }

    return $content;
}


###############################################################################

=head2 printMoonList()

printMoonList nicely formats the moon description listings

=cut

###############################################################################
sub printMoonList {
    my ($world) = @_;
    my $content = "";
    if ( $world->{'astronomy'}->{'moons_count'} == 0 ) {
        $content .= $world->{'astronomy'}->{'moons_name'};
    } else {
        $content .= A( $world->{'astronomy'}->{'moons_name'} ) . ": "
            . conjunction( @{ $world->{'astronomy'}->{'moon_description'} } );
    }
    return $content;
}


###############################################################################

=head2 printCelestialList()

printCelestialList nicely formats the Celestial object description listings

=cut

###############################################################################
sub printCelestialList {
    my ($world) = @_;
    my $content = "";
    if ( $world->{'astronomy'}->{'celestial_count'} == 0 ) {
        $content .= $world->{'astronomy'}->{'celestial_name'};
    } else {
        $content .= $world->{'astronomy'}->{'celestial_name'} . ": "
            . conjunction( @{ $world->{'astronomy'}->{'celestial_description'} } );
    }

    return $content;
}


###############################################################################

=head2 printLandSummary()

printLandSummary strips out important info from a World object and returns formatted text.

=cut

###############################################################################
sub printLandSummary {
    my ($world) = @_;
    my $content = "";

    my $de = Number::Format->new( -thousands_sep => ',' );

    $content
        .= "$world->{'name'} is "
        . $de->format_number( $world->{'surface'} )
        . " square kilometers (with a circumference of "
        . $de->format_number( $world->{'circumference'} )
        . " kilometers).\n"
        . "Surface water is $world->{'surfacewater_description'}, covering $world->{'surfacewater_percent'}% of the planet.\n"
        . "Around $world->{'freshwater_percent'}% of the planet's water is fresh water.\n"
        . "The crust is split into $world->{'plates'} plates, resulting in $world->{'continent_count'} continents.\n";

    return $content;
}


###############################################################################

=head2 printWeatherSummary()

printWeatherSummary strips out important info from a World object and returns formatted text.

=cut

###############################################################################
sub printWeatherSummary {
    my ($world) = @_;
    my $content = "";
    my $stars   = conjunction( @{ $world->{'star_description'} } );

    my $de = Number::Format->new( -thousands_sep => ',' );

    $content
        .= "While $world->{'name'} has a reasonable amount of variation, the overall climate is $world->{'basetemp'}.\n"
        . "Small storms are $world->{'smallstorms_description'}, precipitation is $world->{'precipitation_description'}, the atmosphere is $world->{'air'} and clouds are $world->{'clouds_description'}.\n";

    return $content;
}


###############################################################################

=head2 printWorldDataSummary()

printWorldDataSummary strips out important info from a World object and returns formatted text.

=cut

###############################################################################
sub printWorldDataSummary {
    my ($world) = @_;
    my $content = "";
    my $stars   = conjunction( @{ $world->{'star_description'} } );

    $content = << "EOF"
    <ul>
        <li>Stars: $world->{'astronomy'}->{'starsystem_count'}</li>
        <li>Moons: $world->{'astronomy'}->{'moons_count'}</li>
        <li>Celestial Objects: $world->{'astronomy'}->{'celestial_count'}</li>
        <li>Weather: $world->{'basetemp'}</li>
        <li>Sky: $world->{'atmosphere'}->{'color'}</li>
        <li>Size: $world->{'size'}</li>
        <li>Year: $world->{'year'} days</li>
        <li>Day: $world->{'day'} hours</li>
        <li>Oceans: $world->{'surfacewater_percent'}%</li>
        <li>Fresh water: $world->{'freshwater_description'}</li>
    </ul>
EOF
        ;

    return $content;
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

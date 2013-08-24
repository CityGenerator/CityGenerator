
## Please see file perltidy.ERR
#!/usr/bin/perl -wT
###############################################################################

package EnvironmentFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printEnvironment);

###############################################################################

=head1 NAME

    EnvironmentFormatter - used to format the environment.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use Lingua::Conjunction;
use Lingua::EN::Inflect qw(A);
use Lingua::EN::Numbers qw(num2en);
use Number::Format 'format_number';
use POSIX;
use version;

###############################################################################

=head2 printGeography()

printGeography strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printGeography {
    my ($city) = @_;
    my $content = "";
    $content
        .= "This $city->{'arable_description'} $city->{'size'} is $city->{'density_description'} populated (".format_number($city->{'population_density'})."/sq km), covers $city->{'area'} square kilometers, and roughly has a diameter of $city->{'diameter'} meters. \n";

    return $content;
}

###############################################################################

=head2 printClimate()

printClimate strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printClimate {
    my ($city) = @_;
    my $content = "";
    $content
        .= "$city->{'name'} has a $city->{'climate'}->{'name'} climate, which is characterized by $city->{'climate'}->{'description'}, and has $city->{'climate'}->{'seasondescription'}. ";
    $content
        .= "Winds in the region are $city->{'climate'}->{'wind'} and the temperature is generally $city->{'climate'}->{'temp'} with $city->{'climate'}->{'temp_variation'} variation. ";
    $content .= "Precipitation is $city->{'climate'}->{'precip'}, and the sky is $city->{'climate'}->{'cloudcover'}. ";

    return $content;
}


###############################################################################

=head2 printAstronomy()

printAstronomy strips out important info from a cityobject and returns formatted text.

=cut

###############################################################################
sub printAstronomy {
    my ($city) = @_;
    my $content = "";

    #TODO replace conjunction wuth a print sub like moon
    my $stars      = conjunction( @{ $city->{'astronomy'}->{'star_description'} } );
    my $moons      = printMoonList($city);
    my $celestials = printCelestialList($city);
    $content .= "$city->{'name'} sees " . A( $city->{'astronomy'}->{'starsystem_name'} ) . " overhead: $stars.\n";
    $content .= "$city->{'name'} also has $moons.\n";
    $content .= "In the night sky, you see $celestials.\n";

    return $content;
}


###############################################################################

=head2 printMoonList()

printMoonList formats the moon descriptions and returns a nice phrase

=cut

###############################################################################
sub printMoonList {
    my ($city) = @_;
    my $content = "";
    if ( $city->{'astronomy'}->{'moons_count'} == 0 ) {
        $content .= $city->{'astronomy'}->{'moons_name'};
    } else {
        $content .= A( $city->{'astronomy'}->{'moons_name'} ) . ": "
            . conjunction( @{ $city->{'astronomy'}->{'moon_description'} } );
    }
    return $content;
}


###############################################################################

=head2 printCelestialList()

printCelestialList formats the celestial object descriptions and returns a nice phrase

=cut

###############################################################################
sub printCelestialList {
    my ($city) = @_;
    my $content = "";
    if ( $city->{'astronomy'}->{'celestial_count'} == 0 ) {
        $content .= $city->{'astronomy'}->{'celestial_name'};
    } else {
        $content .= $city->{'astronomy'}->{'celestial_name'} . ": "
            . conjunction( @{ $city->{'astronomy'}->{'celestial_description'} } );
    }

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

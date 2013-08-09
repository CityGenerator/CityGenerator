#!/usr/bin/perl -wT
###############################################################################

package CityscapeFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printCityscape);

###############################################################################

=head1 NAME

    CityscapeFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

###############################################################################

=head2 printCityscape()

printCityscape strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printCityscape {
#FIXME get rid of this and use what other formatters are doing
    my ($city) = @_;
    my $content;
    $content .= " " . printWalls($city);
    $content .= " " . printStreets($city);
    $content .= " " . printDistrictList($city);
    $content .= " " . printHousingList($city);
    $content .= "</p>";

    return $content;
}


###############################################################################

=head2 printWalls()

printWalls formats details about walls around the city.

=cut

###############################################################################

sub printWalls {
    my ($city) = @_;
    my $content = "No walls currently surround the city.";

    if ( $city->{'walls'}->{'height'} ne '0' ) {
        $content
            = "Visitors are greeted with a "
            . $city->{'walls'}->{'condition'} ." ".$city->{'walls'}->{'material'}. " ".$city->{'walls'}->{'style'}   
            . " that is "
            . $city->{'walls'}->{'height'}
            . " meters tall. The city wall protects the core $city->{'protected_percent'}% of the city, with $city->{'watchtowers'}->{'count'} towers spread along the $city->{'walls'}->{'length'} kilometer wall.";
    }

    return $content;
}

###############################################################################

=head2 printStreets()

printStreets formats details about streets around the city.

=cut

###############################################################################

sub printStreets {
    my ($city) = @_;

    #FIXME This could be simplified with perl's Lingua modules.
    my $mainroads = $city->{'streets'}->{'mainroads'} == 0 ? "none" : $city->{'streets'}->{'mainroads'};
    $mainroads = $mainroads eq "1" ? "1 is" : $mainroads . " are";
    my $roads = $city->{'streets'}->{'roads'} == 1 ? "is 1 road" : "are " . $city->{'streets'}->{'roads'} . " roads";

    my $content = "There $roads leading to $city->{'name'}; $mainroads major.  ";

    $content .= "The city is lined with " . $city->{'streets'}->{'content'} . ".";

    return $content;
}

###############################################################################

=head2 printDistrictList()

printDistrictList formats details about the District List.

=cut

###############################################################################

sub printDistrictList {
    my ($city)    = @_;
    my @districts = keys %{ $city->{'districts'} };
    my $content   = "";
    if ( scalar(@districts) == 0 ) {
        $content = "There are no defined districts in this city.";
    } elsif ( scalar(@districts) == 1 ) {
        $content = "The city includes the $districts[1] District.";
    } else {
        my $last_district = pop @districts;
        $content
            = "The city is broken into the following Districts: " . join( ", ", @districts ) . " and $last_district.";
    }


    return $content;
}


###############################################################################

=head2 printHousingList()

printHousingList formats details about streets around the city.

=cut

###############################################################################

sub printHousingList {
    my ($city) = @_;
    my $content
        = "Among housing, there are "
        . $city->{'housing'}->{'wealthy'}
        . " wealthy residences, "
        . $city->{'housing'}->{'average'}
        . " average homes and "
        . $city->{'housing'}->{'poor'}
        . " dilapidated homes.";

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

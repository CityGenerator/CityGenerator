#!/usr/bin/perl -wT
###############################################################################

package PeopleFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    PeopleFormatter - used to format people details

=head1 DESCRIPTION

 Prints and formats details about the people citizens and travelers

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Inflect qw( A PL_N );
use POSIX;
use version;

###############################################################################

=head2 printSummary()

printSummary strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($city) = @_;
    my $content = "The people in $city->{'name'} $city->{'tolerance_description'} outsiders.";

    return $content;
}

###############################################################################

=head2 printCitizens()

printCitizens strips out important info from a City object and returns details about citizens

=cut

###############################################################################
sub printCitizens {
    my ($city) = @_;
    my $content;
    if ( scalar( @{ $city->{'citizens'} } ) == 0 ) {
        $content = "None are of note.";
    } else {

        $content .= "The following citizens are worth mentioning: \n";
        $content .= "<ul class='twocolumn'> \n";
        foreach my $citizen ( @{ $city->{'citizens'} } ) {
            if ( $citizen->{'race'} eq 'other' or $citizen->{'race'} eq 'any' ) {
                $citizen->{'race'} = "oddball";
            }
            $content .= "<li>";
            if ( defined $citizen->{'name'} ) {
                $content
                    .= "<b>"
                    . $citizen->{'name'}
                    . "</b> is "
                    . A( lc( $citizen->{'sex'} ) . " " . lc( $citizen->{'race'} ) ) . " ";
            } else {
                $content .= "A nameless " . lc( $citizen->{'sex'} ) . " " . lc( $citizen->{'race'} ) . " ";

            }
            $content
                .= "who is known in "
                . $citizen->{'reputation_scope'}
                . " as being "
                . A( $citizen->{'skill_description'} )
                . " $citizen->{'profession'}. \n";
            $content .= ucfirst( $citizen->{'pronoun'} ) . " appears " . $citizen->{'behavior'} . ". \n";
            $content .= "</li>";
        }
    }

    $content .= "</ul>";

    return $content;
}

###############################################################################

=head2 printTravelers()

printTravelers strips out important info from a City object and returns details 
about people travelers.

=cut

###############################################################################
sub printTravelers {
    my ($city) = @_;
    my $content;

    if ( scalar( @{ $city->{'travelers'} } ) == 0 ) {
        $content = "None are of note.";
    } else {

        $content .= "The following travelers are worth mentioning: \n";
        $content .= "<ul class='twocolumn'> \n";
        foreach my $traveler ( @{ $city->{'travelers'} } ) {
            if ( $traveler->{'race'} eq 'other' or $traveler->{'race'} eq 'any' ) {
                $traveler->{'race'} = "oddball";
            }
            $content .= "<li>";
            if ( defined $traveler->{'name'} ) {
                $content
                    .= "<b>"
                    . $traveler->{'name'}
                    . "</b>, "
                    . A( $traveler->{'behavior'} . " " . lc( $traveler->{'sex'} ) . " " . lc( $traveler->{'race'} ) )
                    . ". \n";
            } else {
                $content .= ucfirst( A( $traveler->{'behavior'} . " " . $traveler->{'sex'} ) ) . " "
                    . lc( $traveler->{'race'} ) . ". \n";
            }
            $content
                .= ucfirst( $traveler->{'pronoun'} ) . " is "
                . A( lc( $traveler->{'class'} ) )
                . " who is $traveler->{'motivation_description'}. \n";
            $content .= "</li>";
        }
    }

    $content .= "</ul>";

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

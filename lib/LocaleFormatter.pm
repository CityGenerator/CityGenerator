#!/usr/bin/perl -wT
###############################################################################

package LocaleFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printLandmarks printTaverns );

###############################################################################

=head1 NAME

    LocaleFormatter - used to format information about various locals.

=head1 DESCRIPTION

 This takes a city and prettily formats Taverns and Landmarks.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Inflect qw( A );
use POSIX;
use version;


###############################################################################

=head2 printLandmarks()

printLandmarks strips out Landmark info and formats it.

=cut

###############################################################################
sub printLandmarks {
    my ($city)  = @_;
    my $content = "";
    my $locale  = $city->{'locale'};
    return $content;
}

###############################################################################

=head2 printTaverns()

printTaverns strips out Tavern information and formats it.

=cut

###############################################################################
sub printTaverns {
    my ($city) = @_;
    my $content = "";
    if ( scalar( @{ $city->{'taverns'} } ) > 0 ) {
        $content
            .= "<p>Taverns are often central gathering places for the citizens. In $city->{'name'} can find the following taverns:</p>\n";
        $content .= "<ul class='demolistfinal'>";
        foreach my $tavern ( @{ $city->{'taverns'} } ) {
            $content .= describe_tavern($tavern);
        }

        $content .= "</ul>";
    } else {
        $content .= "<p>There are no taverns in this town.</p>\n";
    }


    return $content;
}

sub describe_tavern {
    my ($tavern) = @_;
    my $content = "<li>";
    $content
        .= "<b>The $tavern->{'name'}</b> is "
        . A( $tavern->{'size_description'} )
        . " tavern that $tavern->{'popularity_description'}. \n";
    $content .= "It has a reputation for $tavern->{'reputation_description'}.\n";

    #TODO this is friggen ugly. refactor.
    if ( defined $tavern->{'bartender'}->{'name'} ) {
        $content
            .= "Prices at the $tavern->{'name'} are $tavern->{'cost_description'} and is owned by "
            . A( $tavern->{'bartender'}->{'race'} )
            . " named $tavern->{'bartender'}->{'name'} who seems $tavern->{'bartender'}->{'behavior'}. \n";
    } else {
        $content
            .= "Prices at the $tavern->{'name'} are $tavern->{'cost_description'} and is owned by "
            . A( "nameless " . $tavern->{'bartender'}->{'race'} )
            . " who seems $tavern->{'bartender'}->{'behavior'}. \n";
    }
    $content
        .= "The law $tavern->{'law'} the tavern and its patrons, however most violence is handled by $tavern->{'violence'}. \n";
    $content .= "</li>";
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

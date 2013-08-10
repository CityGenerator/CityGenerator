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
use Lingua::EN::Inflect qw( A PL_N );
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
        $content .= "The $tavern->{'name'} is owned by a $tavern->{'bartender'}->{'behavior'} $tavern->{'bartender'}->{'race'}" 
        . "named $tavern->{'bartender'}->{'name'} whose prices are $tavern->{'cost_description'} and the patrons appear $tavern->{'atmosphere'}. \n";
    } else {
        $content .= "The $tavern->{'name'} is run by a $tavern->{'bartender'}->{'behavior'} $tavern->{'bartender'}->{'race'}"
        . "whose prices are $tavern->{'cost_description'} and the patrons seem $tavern->{'atmosphere'}. \n";
    }
    $content
        .= "The law $tavern->{'law'} the tavern and its patrons, however most violence is handled by $tavern->{'violence'}. \n";
    $content .= "</li>";
    return $content;
}

###############################################################################

=head2 printEstablishments()

printTaverns strips out Establishment information and formats it.

=cut

###############################################################################
sub printEstablishments {
    my ($city) = @_;
    my $content = "";
    $content .= "foo";
    if ( scalar( @{ $city->{'establishments'} } ) > 0 ) {
        $content
            .= "<p>These establishments worthy of mention in $city->{'name'}:</p>\n";
        $content .= "<ul class='demolistfinal'>";
        foreach my $establishment ( @{ $city->{'establishments'} } ) {
            $content .= describe_establishment($establishment);
        }

        $content .= "</ul>";
    } else {
        $content .= "<p>There are no establishments in this town.</p>\n";
    }


    return $content;
}

sub describe_establishment {
    # The Fat Ostrich is a small, clean, rundown bakery made of stone and wood and is in a rundown area of 
    # the red light district.  It appears to be busy, has five patrons inside, and has a good reputation 
    # with the locals for cheap prices and quality work.  It is run by Jesse Husband-Father who is a large 
    # Orc with an even temperament but prone to occasional bursts of rage.  The bakery is on good terms 
    # with the law but regularly pays bribes to organized crime lord Brad Crime-Boss.    
    
    my ($establishment) = @_;
    my $content = "<li>";
    $content .= "<b>The $establishment->{'name'}</b> A( $establishment->{'type'} ) that $establishment->{'popularity_description'} ";
    $content .= "$establishment->{'size_description'}  $establishment->{'reputation_description'} \n";
    $content .= " and is run by a $establishment->{'manager'}->{'sex'} A( $establishment->{'manager'}->{'race'} ) ";
    $content .= "named $establishment->{'manager'}->{'name'} ";

#use Lingua::EN::Inflect qw( A PL_N );
#
#$content .= "Laws are enforced by " . A( $city->{'laws'}->{'enforcer'} ) . ", $city->{'laws'}->{'enforcement'}. \n";
#
#$content .= "The imprisonment rate is $city->{'imprisonment_rate'}->{'percent'}% of the population ($city->{'imprisonment_rate'}->{'population'} "
#. PL_N( "adult", $city->{'imprisonment_rate'}->{'population'} ) . "). \n";
    
#            
#    $establishment->{'manager'}->{'behavior'}
    
# is run by $establishment->{'manager'}        
#        . A( $establishment->{'size_description'} )
#        . " establishment that $establishment->{'popularity_description'}. \n";
#    $content .= "It has a reputation for $establishment->{'reputation_description'}.\n";
#
#    if ( defined $establishment->{'bartender'}->{'name'} ) {
#        $content .= "The $establishment->{'name'} is owned by a $establishment->{'bartender'}->{'behavior'} $establishment->{'bartender'}->{'race'}" 
#        . "named $establishment->{'bartender'}->{'name'} whose prices are $establishment->{'cost_description'} and the patrons appear $establishment->{'atmosphere'}. \n";
#    } else {
#        $content .= "The $establishment->{'name'} is run by a $establishment->{'bartender'}->{'behavior'} $establishment->{'bartender'}->{'race'}"
#        . "whose prices are $establishment->{'cost_description'} and the patrons seem $establishment->{'atmosphere'}. \n";
#    }
#    $content
#        .= "The law $establishment->{'law'} the establishment and its patrons, however most violence is handled by $establishment->{'violence'}. \n";

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

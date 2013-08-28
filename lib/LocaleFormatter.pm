#!/usr/bin/perl -wT
###############################################################################

package LocaleFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    LocaleFormatter - used to format information about various locals.

=head1 DESCRIPTION

 This takes a city and prettily formats Establishments and Landmarks.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use Lingua::Conjunction;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Inflect qw( A PL_N NO);
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

=head2 printEstablishments()

printEstablishments strips out Establishment information and formats it.

=cut

###############################################################################
sub printEstablishments {
    my ($city) = @_;
    my $content = "";
    if ( scalar( @{ $city->{'establishments'} } ) > 0 ) {
        $content
            .= "<p>These establishments worthy of mention in $city->{'name'}:</p>\n";
        $content .= "<ul class='twocolumn'>";
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
    my ($establishment) = @_;
    my $content = "<li>";
   
    #FIXME we need to re-evaluate these if statements; text should be readable if any one is missing.
    #FIXME for example. "The Wet Frog is a greasy looing average sized..." vs. "The West Frog average sized..."
    #FIXME is needs to be moved above, and these need an article on whichever one is first.
    #FIXME we may need to re-evaluate how this is generated :/
    $content .= "<b>The $establishment->{'name'}</b>\n";
    $content .= "<span onclick='hideMe(this);' id='establishment".$establishment->{'seed'}."_control' class='collapser' >[+]</span>\n";
    $content .= '<span style="display:none" class="establishment" id="establishment'.$establishment->{'seed'}.'">';
    $content .= "The $establishment->{'name'} is ".A($establishment->{'size_description'}).", $establishment->{'condition'}-looking  $establishment->{'type'}. \n";
    $content .= "The building ";
    
    if ( defined $establishment->{'direction'} ) {    
        $content .= "faces $establishment->{'direction'}";
    }
    
    my @features = ();

    push( @features, A("$establishment->{'storefront'} storefront") )    if ( defined $establishment->{'storefront'} );
    push( @features, "$establishment->{'windows'} windows" )             if ( defined $establishment->{'windows'} );
    push( @features, A("roof made from $establishment->{'storeroof'}") ) if ( defined $establishment->{'storeroof'} );
    if (scalar(@features) >0){

        $content .= " with ".conjunction(shuffle @features);
    }
    $content.=". \n";
    #print STDERR Dumper $establishment;
    $content .= "It is located in ".A($establishment->{'neighborhood'})." neighborhood";

    if ( defined $establishment->{'district'} ) {    
        $content .= " of the $establishment->{'district'} district";
    }
    $content.=". \n";
    $content .= " This place is run by ".A($establishment->{'manager'}->{'behavior'})." $establishment->{'manager'}->{'race'} named $establishment->{'manager'}->{'name'}. \n";

    if ( defined $establishment->{'service_type'} ) {    
        $content .= "The $establishment->{'type'} is known for $establishment->{'price_description'} prices for the $establishment->{'service_type'} there, ";
        $content .= " and $establishment->{'popularity_description'}. ";
    }

    my @senses;
    push @senses, "you smell $establishment->{'smell'}" if ( defined $establishment->{'smell'} );
    push @senses, "you hear $establishment->{'sound'}"  if ( defined $establishment->{'sound'} );
    push @senses, "you see $establishment->{'sight'}"   if ( defined $establishment->{'sight'} );
    if (@senses != 0){
        $content .= " Upon entering " . conjunction(shuffle @senses ) . ".\n";
    }    
    
    my $verb= (defined $establishment->{'occupants'} && $establishment->{'occupants'} ==1) ? 'is' : 'are';
    $content .= " There $verb ".NO('customer', $establishment->{'occupants'})." in the $establishment->{'type'}.";

    if ( defined $establishment->{'enforcer'} ) {
        $content .= " The $establishment->{'enforcer'}";
    }

    if ( defined $establishment->{'graft'} ) {
        $content .= " $establishment->{'graft'} the owner and patrons.";
    }

    $content .= "</span></li>";
    
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

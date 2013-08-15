#!/usr/bin/perl -wT
###############################################################################

package LocaleFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printLandmarks printEstablishments );

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
   
    $content .= "<b>The $establishment->{'name'} <span onclick='hideMe(this);' id='establishment".$establishment->{'seed'}."_control' class='collapser' > [+]</span></b> ";
    $content.='<span style="display:none" id="establishment'.$establishment->{'seed'}.'"> The '. $establishment->{'name'};
    #FIXME we need to re-evaluate these if statements; text should be readable if any one is missing.
    #FIXME for example. "The Wet Frog is a greasy looing average sized..." vs. "The West Frog average sized..."
    #FIXME is needs to be moved above, and these need an article on whichever one is first.
    #FIXME we may need to re-evaluate how this is generated :/
    if ( defined $establishment->{'condition'} ) {    
        $content .= " is ".A($establishment->{'condition'})." looking ";
    }
    
    if ( defined $establishment->{'size_description'} ) {    
        $content .= " $establishment->{'size_description'} sized ";
    }
    
    if ( defined $establishment->{'type'} ) {    
        $content .= " $establishment->{'type'} ";
    }

    if ( defined $establishment->{'direction'} ) {    
        $content .= " facing $establishment->{'direction'} ";
    }
    
    if ( defined $establishment->{'storefront'} ) {    
        $content .= " with ".A($establishment->{'storefront'})." storefront, ";
    }

    if ( defined $establishment->{'windows'} ) {    
        $content .= " $establishment->{'windows'} windows, ";
    }
    
    if ( defined $establishment->{'storeroof'} ) {    
        $content .= " and a roof made from $establishment->{'storeroof'} ";
    }

    if ( defined $establishment->{'neighborhood'} ) {    
        $content .= " in ".A($establishment->{'neighborhood'})." neighborhood ";
    }

    if ( defined $establishment->{'district'} ) {    
        $content .= " of the $establishment->{'district'} district. ";
    }

    if ( defined $establishment->{'manager'}->{'behavior'} ) {    
        $content .= " This place is run by ".A($establishment->{'manager'}->{'behavior'})." ";
    }

    if ( defined $establishment->{'manager'}->{'race'} ) {    
        $content .= " $establishment->{'manager'}->{'race'} ";
    }

    if ( defined $establishment->{'manager'}->{'name'} ) {    
        $content .= " named $establishment->{'manager'}->{'name'}. ";
    }

    if ( defined $establishment->{'service_type'} ) {    
        $content .= "This $establishment->{'type'} is known for  ";
    }

    if ( defined $establishment->{'price_description'} ) {    
        $content .= " $establishment->{'price_description'} prices for the $establishment->{'service_type'} there ";
    }
    
    if ( defined $establishment->{'popularity_description'} ) {    
        $content .= " and $establishment->{'popularity_description'}. ";
    }

    my @senses;
    push @senses,  "you smell $establishment->{'smell'}" if ( defined $establishment->{'smell'} );
    push @senses,  "you hear $establishment->{'sound'}" if ( defined $establishment->{'sound'} );
    push @senses,  "you see $establishment->{'sight'}" if ( defined $establishment->{'sight'} );
    if (@senses != 0){
        $content .= " Upon entering " . conjunction(shuffle @senses ) . ".";
    }    
    
    my $verb= ($establishment->{'occupants'} ==1) ? 'is' : 'are';
    $content .= " There $verb ".NO('customer', $establishment->{'occupants'})." in the $establishment->{'type'}.";

    if ( defined $establishment->{'enforcer'} ) {
        $content .= " The $establishment->{'enforcer'}";
    }

    if ( defined $establishment->{'graft'} ) {
        $content .= " $establishment->{'graft'} the owner and patrons at the $establishment->{'type'}.";
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

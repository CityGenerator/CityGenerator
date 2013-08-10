#!/usr/bin/perl -wT
###############################################################################

package GovtFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printSummary printCrime printLeader printMilitary printLaw );

###############################################################################

=head1 NAME

    GovtFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

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

printLeader strips out important info from a Govt Object and writes a summary based on the stats.

=cut

###############################################################################
sub printSummary {
    my ($city)  = @_;
    my $content = "";
    my $govt    = $city->{'govt'};
    $content
        .= "$city->{'name'} is governed through "
        . A( $city->{'govt'}->{'type'} )
        . ", where "
        . $city->{'govt'}->{'description'} . ". ";
    $content .= "The government as a whole is seen as $city->{'govt'}->{'efficiency_description'}. ";
    $content
        .= "Officials in $city->{'name'} are often seen as $city->{'govt'}->{'corruption_description'} and the policies are $city->{'govt'}->{'approval_description'}. ";
    $content
        .= "The political influence of $city->{'name'} in the region is $city->{'govt'}->{'influence_description'} due to $city->{'govt'}->{'influencereason'}. ";
    $content .= "In times of crisis, the population $city->{'govt'}->{'unity_description'}. ";

    return $content;
}

###############################################################################

=head2 printLeader()

printLeader strips out important info from a Govt Object about the current Leader

=cut

###############################################################################
sub printLeader {
    my ($city)  = @_;
    my $content = "";
    my $govt    = $city->{'govt'};
    my $leadername;
    if (defined $city->{'govt'}->{'leader'}->{'name'}){
        $leadername="$city->{'govt'}->{'leader'}->{'title'} $city->{'govt'}->{'leader'}->{'name'}";
    }else{
        $leadername="The $city->{'govt'}->{'leader'}->{'title'}";
    }

    $content
        .= "$city->{'name'} is ruled by $leadername. ";
    $content
        .= "The $city->{'govt'}->{'leader'}->{'title'} has been in power $city->{'govt'}->{'leader'}->{'length'} and is $city->{'govt'}->{'leader'}->{'reputation'} by the people. ";
    $content
        .= "There is $city->{'govt'}->{'leader'}->{'opposition'} opposition to the $city->{'govt'}->{'leader'}->{'title'} and policies. ";
    $content
        .= "The right to rule was granted $city->{'govt'}->{'leader'}->{'right'}, and that power is maintained $city->{'govt'}->{'leader'}->{'maintained'}. ";

#
#$city->{'name'} is ruled a $govt->{'reputation'} $govt->{'description'}. Within the city there is a $govt->{'secondary_power'}->{'power'} that $govt->{'secondary_power'}->{'plot'} current leadership. The population approves of $govt->{'description'} policies in general.";
    return $content;
}

###############################################################################

=head2 printLaw()

printLaw provides details about the laws in the city

=cut

###############################################################################
sub printLaw {
    my ($city) = @_;
    my $content = "";
    $content .= "Laws are enforced by " . A( $city->{'laws'}->{'enforcer'} ) . ", $city->{'laws'}->{'enforcement'}. \n";
    $content
        .= "Justice is served $city->{'laws'}->{'trial'}, with a common punishment being $city->{'laws'}->{'punishment'}. \n";

    return $content;
}

###############################################################################

=head2 printCrime()

printCrime displays information about crime in the city.

=cut

###############################################################################
sub printCrime {
    my ($city) = @_;
    my $content = "";
    $content .= "Crime is $city->{'crime_description'}. \n";
    $content .= "The most common crime is $city->{'laws'}->{'commoncrime'}. \n";
    $content
        .= "The imprisonment rate is $city->{'imprisonment_rate'}->{'percent'}% of the population ($city->{'imprisonment_rate'}->{'population'} "
        . PL_N( "adult", $city->{'imprisonment_rate'}->{'population'} ) . "). \n";

    return $content;
}

###############################################################################

=head2 printMilitary()

printMilitary shows details of current military status.

=cut

###############################################################################
sub printMilitary {
    my ($city)  = @_;
    my $content = "";

    my $walls="lack of defensible wall";
    if   (defined $city->{'walls'}->{'condition'} ){
        my $walls=$city->{'walls'}->{'condition'}." ".$city->{'walls'}->{'condition'} ;
    }

    my $tactic=define_tactics($city);

    $content.="$city->{'name'} has ".A($city->{'military_description'})." attitude towards the military. \n";
    $content.="Their standing army of $city->{'military'}->{'active_troops'} citizens ($city->{'military'}->{'active_percent'}%) is at the ready, with a reserve force of $city->{'military'}->{'reserve_troops'} ($city->{'military'}->{'reserve_percent'}%). \n";
    $content.="Of the active duty military, $city->{'military'}->{'para_troops'} ($city->{'military'}->{'para_percent'}%) are special forces. \n";
    $content.="Due to their $city->{'military_description'} attitude and $walls, $city->{'name'} is $city->{'military'}->{'fortification'} fortified. \n"; 
    $content.="$city->{'name'} fighters are $city->{'military'}->{'weapon reputation'} for their use of $city->{'military'}->{'favored weapon'} in battle. \n";
    $content.="They are $city->{'military'}->{'reputation'} for their $city->{'military'}->{'favored tactic'} and are considered $city->{'military'}->{'preparation'} skilled in battle. \n";

    return $content;
}


sub define_tactics{
    my ($city)  = @_;
    if (defined $city->{'tactics'}->{'content'}){
        return " $city->{'military'}->{'reputation'} for their $city->{'military'}->{'favored tactic'} and are";
    }else{
        return "";
    }
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

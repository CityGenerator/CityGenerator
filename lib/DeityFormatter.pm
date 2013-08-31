#!/usr/bin/perl -wT
###############################################################################

package DeityFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    DeityFormatter - used to format information on an Deity.

=head1 DESCRIPTION

 This take a deity, strips the important info, and generates a paragraph or two.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use JSON;
use Lingua::Conjunction;
use Lingua::EN::Inflect qw(A PL_N);
use Lingua::EN::Numbers qw(num2en);
use Number::Format;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

###############################################################################

=head2 printSummary()

printSummary strips out important info from a Deity object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($deity) = @_;
    my $content = "";
    $content.= "$deity->{'name'} is ".A( $deity->{'importance_description'})." who favors ".$deity->{'best_stat'}. ".\n "  ;
    $content.= "$deity->{'firstname'} controls ".conjunction(@{$deity->{'portfolio'}}).".\n ";
    $content.= ucfirst($deity->{'posessivepronoun'})." holy symbol is ".A( $deity->{'primarycolor'})." $deity->{'holy symbol'} and prefers $deity->{'worship'} from $deity->{'posessivepronoun'} followers.\n ";
    $content.=ucfirst($deity->{'weapon'})." are the preferred weapon of $deity->{'firstname'}.\n";
    return $content;
}
###############################################################################

=head2 printFollowers()

printFollowers provides details about the deity's followers

=cut

###############################################################################
sub printFollowers {
    my ($deity) = @_;
    my $content = "";
    $content.="This $deity->{'age_description'} god's worshipers are $deity->{'following_description'}.\n";
    $content.="$deity->{'firstname'} is thought to have $deity->{'devotion_description'} devoted followers in the world.\n ";
    $content.="$deity->{'firstnames'} followers are said to be $deity->{'secrecy_description'} about their affiliation.\n ";
    return $content;
}
###############################################################################

=head2 printClergy()

printClergy provides details about the deity'sclergy

=cut

###############################################################################
sub printClergy {
    my ($deity) = @_;
    my $content = "";
    $content.=ucfirst($deity->{'clergytype'})." of $deity->{'firstname'} often follow a Vow of $deity->{'vow_type'} (a vow to $deity->{'vow'}).\n";
    return $content;
}



###############################################################################

=head2 printSects()

Print sects if they exist.

=cut

###############################################################################
sub printSects {
    my ($deity) = @_;
    my $content;
    if (scalar( @{$deity->{'sect'}}) >0 ){
        $content.="$deity->{'firstname'} is known to have the following ".PL_N("sect", scalar(@{$deity->{'sect'}}))." worshiping $deity->{'objectivepronoun'}:\n";
        $content.="<ul>\n";
        foreach my $sect (@{$deity->{'sect'}}) {
            $content.="<li>The $sect->{'name'} $sect->{'type'} is seen as $sect->{'acceptance'} by other followers.</li>\n";
        }
        $content.="</ul>\n";
    }

    return $content;
}

###############################################################################

=head2 printDescription()

Print a nice physical description of the Deity

=cut

###############################################################################
sub printDescription {
    my ($deity) = @_;
    my $content = "";
    $content.= "$deity->{'name'} often appears as ".A($deity->{'height'})." $deity->{'race'} with ".A($deity->{'complexion'})." complexion. \n";
    $content.= $deity->{'firstname'}." appears $deity->{'build'} and has $deity->{'eyes'} eyes. \n";
    return $content;
}


###############################################################################

=head2 printRacialBreakdown()

printRacialBreakdown formats details about the races.

=cut

###############################################################################

sub printData {
    my ($deity) = @_;
    my $content = "                    <h3>Vital Stats</h3>\n";
    $content .= "                    <ul>\n";
    foreach my $stat ( sort keys %{ $deity->{'stats'} } ) {
        $content .= "                        <li>$stat: ".$deity->{$stat."_description"}."</li>\n"
    }
    $content .= "                    </ul>\n";
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

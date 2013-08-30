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
use Lingua::EN::Inflect qw(A);
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

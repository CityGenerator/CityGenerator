#!/usr/bin/perl -wT
###############################################################################

package PopulationFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printRaces printAges);

###############################################################################

=head1 NAME

    PopulationFormatter - used to format population details

=head1 DESCRIPTION

 Prints and formats details about the population races and ages

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

=head2 printRaces()

printRaces strips out important info from a City object and returns details about races

=cut

###############################################################################
sub printRaces {
    my ($city) = @_;
    my $content;
    
    #TODO add dominant race
    #TODO add moral and order descriptions
    #$content.="$city->{'name'} is a $city->{'moraldescription'} and $city->{'orderdescription'} population. \n";
    $content.="Here's the breakdown of this $city->{'type'} population:";

    $content.="<ul> \n";
    foreach my $race ( reverse sort {$a->{'percent'} <=> $b->{'percent'}} @{$city->{'races'}}  ){
        $content.= "<li style='margin-left:200px;'>$race->{'population'} $race->{'plural'} ($race->{'percent'}%) </li> \n";
    }
    $content.="</ul>";

    return $content;
}

###############################################################################

=head2 printAges()

printAges strips out important info from a City object and returns details 
about population ages.

=cut

###############################################################################
sub printAges {
    my ($city) = @_;
    my $content;
    $content.="Children account for $city->{'children'}->{'percent'}% ($city->{'children'}->{'population'}), and the elderly account for $city->{'elderly'}->{'percent'}% ($city->{'elderly'}->{'population'}) of this $city->{'age_description'} city. \n";

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

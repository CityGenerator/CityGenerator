#!/usr/bin/perl -wT
###############################################################################

package EventFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printEvents printPostings);

###############################################################################

=head1 NAME

    EventFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Summary.

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

=head2 printSummary()

printSummary strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printSummary {
#FIXME flesh this out I guess... does it even need to be here?
    my ($city) = @_;
    my $content;
    $content .= "$city->{'name'} is a lively city with many opportunities available.";
    return $content;
}


###############################################################################

=head2 printPostings()

printPostings displays a list of current job postings

=cut

###############################################################################

sub printPostings {
    my ($city) = @_;
    my $content = "You'll find the following job postings:";
    $content .= "<ul class='twocolumn'> \n";
    foreach my $posting (@{ $city->{'postings'} } ){
        $content.= "<li>".$posting->{'template'}."</li>\n";
    
    }    

    $content .= "</ul>\n";

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

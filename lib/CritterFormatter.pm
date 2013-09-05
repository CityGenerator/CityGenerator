#!/usr/bin/perl -wT
###############################################################################

package CritterFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    CritterFormatter - used to format information on an Critter.

=head1 DESCRIPTION

 This take a critter, strips the important info, and generates a paragraph or two.

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

printSummary strips out important info from a Critter object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($critter) = @_;
    my $content = "";
    $content.= "The $critter->{'name'} is ".A($critter->{'terror_description'})." $critter->{'basecritter'} that $critter->{'diet'}.\n ";
    $content.= "Adventurers should be wary of its $critter->{'attacktype'} $critter->{'attack'}, and it's reported $critter->{'ability'}.\n ";

    return $content;
}

###############################################################################

=head2 printDescription()

Print a nice physical description of the Critter

=cut

###############################################################################
sub printDescription {
    my ($critter) = @_;
    my $content = "";
    $content.="The $critter->{'name'} appears to be ".A($critter->{'size_description'})." $critter->{'basecritter'} that $critter->{'locomotion'}.\n ";
    $content.="It $critter->{'diet'} with its $critter->{'maw'}.\n " ;

    if (defined $critter->{'covering'}){
        $content.="Its $critter->{'size_description'} body is covered with $critter->{'coveringtype'}, $critter->{'coveringcolor'} $critter->{'covering'}.\n ";
    }
    if (defined $critter->{'subtype'}){
        $content.="It $critter->{'subtype'}.\n ";
    }
    
#          'subtype_roll' => 53,
#          'seed' => 476217,
#          'age_description' => 'adult',
#          'basecritter' => 'bat',
#          'template' => undef,
#          'nametemplate' => 'black-cheeked Yerzin bat',
#          'stats' => {
#                       'terror' => 4,
#                       'age' => 43,
#                       'creation' => 71,
#                       'size' => 80
#                     },
#          'part' => '-cheeked',
#          'npc' => {
#                     'firstname' => 'Yerzin'
#                   },
#          'creation_description' => 'is older than the elves',
#          'part_type' => 'cheeks',



    return $content;
}


sub printData {
    my ($critter) = @_;
    my $content = "";
 


 
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

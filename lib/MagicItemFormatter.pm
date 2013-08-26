#!/usr/bin/perl -wT
###############################################################################

package MagicItemFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    MagicItemFormatter - used to format information on an MagicItem.

=head1 DESCRIPTION

 This take a item, strips the important info, and generates a paragraph or two.

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

printSummary strips out important info from a MagicItem object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($item) = @_;
    my $content = "";

    if ($item->{'item'} eq 'potion' ){
        $content.="The $item->{'name'} is ".A($item->{'color'})." $item->{'content'} in ".A($item->{'material'})." $item->{'container'}. \n"; 
        $content.="The $item->{'category_type'} $item->{'content'} $item->{'category'} and is of $item->{'quality_description'} quality. \n";
        $content.="The $item->{'container'} is $item->{'repair_description'} and smells of sweat. \n";
        $content.="This $item->{'strength_description'} $item->{'content'} is considered ".A($item->{'value_description'}).". \n";
        if (defined  $item->{'sideeffect'}){
            $content.="May cause $item->{'sideeffect'}, which is $item->{'sideeffectduration'}. \n";
        }
        $content.="The $item->{'name'} was created by ".A($item->{'creator'}->{'build'})." $item->{'creator'}->{'race'} named $item->{'creator'}->{'name'}. \n";
        #TODO if statement for label
    }elsif ($item->{'item'} eq 'scroll' ){
        $content.="The $item->{'name'} is ".A($item->{'material'})." $item->{'content'} that can be found in ".A($item->{'container'}).". \n"; 
        $content.="The $item->{'category_type'} $item->{'content'} $item->{'category'} and is of $item->{'quality_description'} quality. \n";
        $content.="This $item->{'strength_description'} $item->{'content'} is considered ".A($item->{'value_description'}).". \n";
        if (defined  $item->{'decorations'}){
            $content.="The $item->{'container'} is decorated with $item->{'decorations'}. \n";
        }
        $content.="The $item->{'name'} was created by ".A($item->{'creator'}->{'build'})." $item->{'creator'}->{'race'} named $item->{'creator'}->{'name'}. \n";
        #TODO if statement for label

    }elsif ($item->{'item'} eq 'armor' ){
        $content.="The $item->{'name'} is $item->{'quality_description'} $item->{'category_type'} that is $item->{'repair_description'}. \n";
        $content.="This $item->{'value_description'} $item->{'effect'}";
        if (defined  $item->{'ability'}){
            $content.=" and $item->{'ability'}"
        }
        $content.=". \n";
        if (defined  $item->{'flaw'}){
            $content.="You notice $item->{'flaw'} on the armor. \n";
        }
        if (defined  $item->{'curse'}){
            $content.="Unbeknownst to the user, this armor has ".A($item->{'curse_type'})." curse, meaning it $item->{'curse'}.\n";
        }
        $content.="The $item->{'name'} was created by ".A($item->{'creator'}->{'build'})." $item->{'creator'}->{'race'} named $item->{'creator'}->{'name'}. \n";
            #$item->{''}
        # TODO does not discuss decorations

    }elsif ($item->{'item'} eq 'weapon' ){

        $content.="The $item->{'name'} is $item->{'quality_description'} $item->{'category_type'} that is $item->{'repair_description'}. \n";
        $content.="This $item->{'value_description'} $item->{'effect'}";
        if (defined  $item->{'ability'}){
            $content.=" and $item->{'ability'}"
        }
        $content.=". \n";
        if (defined  $item->{'flaw'}){
            $content.="You notice $item->{'flaw'} on the weapon. \n";
        }
        if (defined  $item->{'curse'}){
            $content.="Unbeknownst to the user, this weapon has ".A($item->{'curse_type'})." curse, meaning it $item->{'curse'}.\n";
        }
        $content.="The $item->{'name'} was created by ".A($item->{'creator'}->{'build'})." $item->{'creator'}->{'race'} named $item->{'creator'}->{'name'}. \n";
        # TODO does not discuss decorations
    }
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

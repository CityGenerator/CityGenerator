#!/usr/bin/perl -wT
package ResourceGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use NPCGenerator;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Titlecase;
use POSIX;
use version;
use XML::Simple;
use lib "lib/";

local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';
my $xml = XML::Simple->new();
my $xml_data = $xml->XMLin( "xml/resources.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 create()

This method is used to create a resource

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create {
	my $output;
	my $roll = d(3);

    if($roll == 1){ # Wildlife resource
        $output = create_wildlife();
    }

    if($roll == 2){ # Natural resource
        $output = create_natural();
    }

    if($roll == 3){ # Structure resource
        $output = create_structure();
    }

    if(d(1) == 1){
        $output .= add_visitors();
    }else{
        $output .= '. ';
    }

    if(d(6) < 5){
        $output .= add_precious();
    }
    return {'template'=>$output};
}

#create_resource(); #FIXME Not sure why this is here?

###############################################################################

=head2 create_structure()

add precious stuff to the narrative

=cut

###############################################################################
sub create_structure {
    my ($content) = @_;

    $content = ucfirst(rand_from_array( $xml_data->{'structures'}->{'age'}->{'option'} )->{'content'}) .' ';
    $content .= rand_from_array( $xml_data->{'structures'}->{'option'} )->{'content'} .' ';
    $content .= 'inhabited by ';
    $content .= rand_from_array( $xml_data->{'wildlife'}->{'type'} )->{'content'} .' '. rand_from_array(    $xml_data->{'wildlife'}->{'animal'} )->{'content'} .'s';

    return $content;
}

###############################################################################

=head2 create_natural()

add precious stuff to the narrative

=cut

###############################################################################
sub create_natural {
    my ($content) = @_;
    my $natural;

    $natural = rand_from_array( $xml_data->{'natural'}->{'type'} );
    $content = '';
    if(d(2) == 1){
        $content .= roll_from_array( d(100), $xml_data->{'scarcity'}->{'option'} )->{'content'} . ' ';
    }
    if(d(2) == 1){
        $content .= rand_from_array( $xml_data->{'natural'}->{'age'}->{'option'} )->{'content'} . ' ';
    }
    $content .= $natural->{'content'} . ' ';
    $content .= rand_from_array( $natural->{'suffix'}->{'option'} )->{'content'};

    return ucfirst($content);
}

###############################################################################

=head2 create_wildlife()

add precious stuff to the narrative

=cut

###############################################################################
sub create_wildlife {
    my ($content) = @_;
    my $wildlife;

    $content = '';
    if(d(2) == 1){
        $content .= roll_from_array( d(100), $xml_data->{'scarcity'}->{'option'} )->{'content'} . ' ';
    }
    if(d(2) == 1){
        $content .= rand_from_array( $xml_data->{'wildlife'}->{'type'} )->{'content'} . ' ';
    }
    $wildlife = rand_from_array( $xml_data->{'wildlife'}->{'animal'} );
    $content .= $wildlife->{'content'} . ' ' ;
    $content .= $wildlife->{'group'};

    return ucfirst($content);
}

###############################################################################

=head2 add_precious()

add precious stuff to the narrative

=cut

###############################################################################
sub add_precious {
    my ($precious) = @_;
    my $who = '';

    if(d(2) == 1){
        $who = NPCGenerator::create()->{'name'} . ' said ';
    }
    $precious = ' ' . ucfirst($who . rand_from_array( $xml_data->{'precious'}->{'find'} )->{'content'}) . ' ' .
    rand_from_array( $xml_data->{'precious'}->{'type'} )->{'content'} . ' ' .
    rand_from_array( $xml_data->{'precious'}->{'option'} )->{'content'} . ' ' .
    rand_from_array( $xml_data->{'precious'}->{'post'} )->{'content'} . '.';

    return $precious;
}

###############################################################################

=head2 add_visitors()

add precious stuff to the narrative

=cut

###############################################################################
sub add_visitors {
    my ($visitors) = @_;

    $visitors = ' that are ';
    $visitors .= rand_from_array( $xml_data->{'feelings'}->{'option'} )->{'content'};
    $visitors .= ' by ';
    $visitors .= rand_from_array( $xml_data->{'groups'}->{'option'} )->{'content'} . '.';

    return $visitors;
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

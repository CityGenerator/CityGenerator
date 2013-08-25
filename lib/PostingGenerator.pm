#!/usr/bin/perl -wT
package PostingGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);


###############################################################################

=head1 NAME

    PostingGenerator - used to generate Postings

=head1 SYNOPSIS

    use PostingGenerator;
    my $posting1=PostingGenerator::create();
    my $posting2=PostingGenerator::create($parameters);

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use List::Util 'shuffle', 'min', 'max';
use NPCGenerator;
use POSIX;
use Template;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by PostingGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/postings.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################

my $xml_data        = $xml->XMLin( "xml/data.xml",      ForceContent => 1, ForceArray => ['option'] );
my $posting_data    = $xml->XMLin( "xml/postings.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the posting structure.

=head3 create()

This method is used to create a simple posting with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create {
    my ($params) = @_;
    my $posting = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $posting->{$key} = $params->{$key};
        }
    }

    if ( !defined $posting->{'seed'} ) {
        $posting->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed( $posting->{'seed'} );

    foreach my $featurename (qw( template request hook payment duration requirement disclaimer detail critter skill item testitem supplies subject ) ){
        select_feature($posting, $featurename);
    }
    $posting->{'contact'}= NPCGenerator::create()->{'name'} if (!defined $posting->{'contact'});
    $posting->{'person'}= NPCGenerator::create()->{'name'} if (!defined $posting->{'person'});
    $posting->{'class'}= rand_from_array([keys %{$xml_data->{'classes'}->{'class'}}]) if (!defined $posting->{'class'}) ;


    GenericGenerator::parse_template($posting);
    append_extras($posting);
    return $posting;
}


###############################################################################

=head2 select_feature()

Set the given feature for the posting.

=cut

###############################################################################
sub select_feature {
    my ($posting, $featurename) = @_;
    my $feature= rand_from_array($posting_data->{$featurename}->{'option'});
    if (defined $posting_data->{$featurename}->{'chance'} ){
        $posting->{$featurename."_roll"} = d(100) if (!defined $posting->{$featurename."_roll"}); 
    }
    if (!defined $posting_data->{$featurename}->{'chance'} || $posting->{$featurename."_roll"} <= $posting_data->{$featurename}->{'chance'} ){
        $posting->{$featurename}= $feature->{'content'} if (!defined $posting->{$featurename});
    }
    return $posting;
}

###############################################################################

=head2 append_extras()

append non-interpolated features to $posting->template()

=cut

###############################################################################
sub append_extras {
    my ($posting) = @_;

    if (defined $posting->{'hook'}){
       $posting->{'template'}=$posting->{'hook'}." ".$posting->{'template'};
    }
    if (defined $posting->{'request'}){
       $posting->{'template'}=$posting->{'request'}." ".$posting->{'template'};
    }

    foreach my $feature ( shuffle qw( requirement disclaimer payment ) ){

        if (defined $posting->{$feature}){
           $posting->{'template'}=$posting->{'template'}." ".$posting->{$feature};
        }
    }


    $posting->{'template'}=$posting->{'template'}." Contact ".$posting->{'contact'};
    if (defined $posting->{'location'}){
       $posting->{'template'}=$posting->{'template'}."at ".$posting->{'location'};
    }
    if (defined $posting->{'detail'}){
       $posting->{'template'}=$posting->{'template'}." ".$posting->{'detail'};
    }
    $posting->{'template'}.=".";
    


    return $posting;
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

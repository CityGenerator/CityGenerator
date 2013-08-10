#!/usr/bin/perl -wT
###############################################################################

package MythGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_myth);


#TODO make generate_name method for use with namegenerator

###############################################################################

=head1 NAME

    MythGenerator - used to generate Myths

=head1 SYNOPSIS

    use MythGenerator;
    my $myth=MythGenerator::create_myth();

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by MythGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/myths.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
# FIXME This needs to stop using our
my $xml_data       = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
my $mythnames_data = $xml->XMLin( "xml/myths.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the myth structure.


=head3 create_myth()

This method is used to create a simple myth with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_myth {
    my ($params) = @_;
    my $myth = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $myth->{$key} = $params->{$key};
        }
    }

    if ( !defined $myth->{'seed'} ) {
        $myth->{'seed'} = set_seed();
    }

    return $myth;
} ## end sub create_myth


#Generate Myths


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

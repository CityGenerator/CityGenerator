#!/usr/bin/perl -wT
###############################################################################

package GovtGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_govt);
#FIXME TODO add a stat for Government Size
###############################################################################

=head1 NAME

    GovtGenerator - used to generate Governments

=head1 SYNOPSIS

    use GovtGenerator;
    my $govt=GovtGenerator::create_govt();

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

The following datafiles are used by GovtGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/govts.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
# FIXME This needs to stop using our
my $xml_data  = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
my $govt_data = $xml->XMLin( "xml/govts.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the govt structure.


=head3 create_govt()

This method is used to create a simple govt with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_govt {
    my ($params) = @_;
    my $govt = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $govt->{$key} = $params->{$key};
        }
    }

    if ( !defined $govt->{'seed'} ) {
        $govt->{'seed'} = set_seed();
    }
    generate_stats($govt);
    set_govt_type($govt);
    generate_leader($govt);

    #    set_secondary_power($govt);
    #    set_reputation($govt);
    return $govt;
} ## end sub create_govt

###############################################################################


=head3 generate_stats()

This method is used to generate baseline stats

=cut

###############################################################################
sub generate_stats {
    my ($govt) = @_;
    GenericGenerator::set_seed( $govt->{'seed'} );
    foreach my $stat (qw( corruption approval efficiency influence unity theology )) {
        $govt->{'stats'}->{$stat} = d(100) if ( !defined $govt->{'stats'}->{$stat} );
        $govt->{ $stat . "_description" }
            = roll_from_array( $govt->{'stats'}->{$stat}, $govt_data->{$stat}->{'option'} )->{'content'}
            if ( !defined $govt->{ $stat . "_description" } );
    }
    $govt->{'influencereason'} = rand_from_array( $govt_data->{'influencereason'}->{'option'} )->{'content'}
        if ( !defined $govt->{"influencereason"} );
    return $govt;
} ## end sub create_govt

###############################################################################


=head3 generate_leader()

This method is used to generate a leader for the government

=cut

###############################################################################
sub generate_leader {
    my ($govt) = @_;

    $govt->{'leader'} = NPCGenerator::create_npc( { 'seed' => $govt->{'seed'} } );

    $govt->{'leader'}->{'right'} = rand_from_array( $govt_data->{'right'}->{'option'} )->{'content'}
        if ( !defined $govt->{'leader'}->{'right'} );
    $govt->{'leader'}->{'reputation'} = rand_from_array( $govt_data->{'reputation'}->{'option'} )->{'content'}
        if ( !defined $govt->{'leader'}->{'reputation'} );
    $govt->{'leader'}->{'length'} = rand_from_array( $govt_data->{'length'}->{'option'} )->{'content'}
        if ( !defined $govt->{'leader'}->{'length'} );
    $govt->{'leader'}->{'opposition'} = rand_from_array( $govt_data->{'opposition'}->{'option'} )->{'content'}
        if ( !defined $govt->{'leader'}->{'opposition'} );
    $govt->{'leader'}->{'maintained'} = rand_from_array( $govt_data->{'maintained'}->{'option'} )->{'content'}
        if ( !defined $govt->{'leader'}->{'maintained'} );

    $govt->{'leader'}->{'title'} = $govt->{'title'}->{'male'} if ( !defined $govt->{'leader'}->{'title'} );

    return $govt;
} ## end sub create_govt

###############################################################################


=head3 set_govt_type()

This method is used to create a simple govt with nothing more than:

=cut

###############################################################################
sub set_govt_type {
    my ($govt) = @_;

    my $govtype = rand_from_array( $govt_data->{'govtypes'}->{'option'} );

    $govt->{'description'} = $govtype->{'description'}                           if ( !defined $govt->{'description'} );
    $govt->{'type'}        = $govtype->{'type'}                                  if ( !defined $govt->{'type'} );
    $govt->{'title'}       = rand_from_array( $govtype->{'titles'}->{'option'} ) if ( !defined $govt->{'title'} );


    return $govt;
} ## end sub create_govt


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

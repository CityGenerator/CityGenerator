#!/usr/bin/perl -wT
###############################################################################

package EventGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_event);

###############################################################################

=head1 NAME

    EventGenerator - used to generate Events

=head1 SYNOPSIS

    use EventGenerator;
    my $event=EventGenerator::create_event();

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

The following datafiles are used by EventGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/events.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
# FIXME This needs to stop using our
my $xml_data   = $xml->XMLin( "xml/data.xml",   ForceContent => 1, ForceArray => ['option'] );
my $event_data = $xml->XMLin( "xml/events.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the event structure.


=head3 create_event()

This method is used to create a simple event with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_event {
    my ($params) = @_;
    my $event = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $event->{$key} = $params->{$key};
        }
    }

    if ( !defined $event->{'seed'} ) {
        $event->{'seed'} = set_seed();
    }

    return $event;
} ## end sub create_event

###############################################################################

=head3 select_base()

select the base type of event.

=cut

###############################################################################
sub select_base {
    my ($event) = @_;

    $event->{'base'} = rand_from_array( [ keys %{ $event_data->{'event'} } ] ) if ( !defined $event->{'base'} );
    $event->{'name'} = $event->{'base'};

    return $event;
}


###############################################################################

=head3 select_modifier()

select the modifier for a given base type of event.

=cut

###############################################################################
sub select_modifier {
    my ($event) = @_;

    my $base = $event_data->{'event'}->{ $event->{'base'} };

    $event->{'modifier'} = rand_from_array( $base->{'option'} )->{'content'} if ( !defined $event->{'modifier'} );
    $event->{'name'} = $event->{'modifier'} . " " . $event->{'base'};

    return $event;
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

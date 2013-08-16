#!/usr/bin/perl -wT
###############################################################################

package ConditionGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_condition flesh_out_condition);

###############################################################################

=head1 NAME

    ConditionGenerator - used to generate Conditions

=head1 SYNOPSIS

    use ConditionGenerator;
    my $condition=ConditionGenerator::create_condition();

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use Date::Format qw(time2str);
use Date::Parse qw( str2time );
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by ConditionGenerator.pm:

=over

=item F<xml/conditions.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
# FIXME This needs to stop using our
my $condition_data = $xml->XMLin( "xml/conditions.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the city structure.


=head3 create_condition()

This method is used to create a simple condition with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_condition {
    my ($params) = @_;
    my $condition = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $condition->{$key} = $params->{$key};
        }
    }

    if ( !defined $condition->{'seed'} ) {
        $condition->{'seed'} = set_seed();
    }
    $condition->{'original_seed'} = $condition->{'seed'};
    $condition->{'pop_mod'}       = {} if ( !defined $condition->{'pop_mod'} || ref $condition->{'pop_mod'} ne 'HASH' );
    $condition->{'bar_mod'}       = {} if ( !defined $condition->{'bar_mod'} || ref $condition->{'bar_mod'} ne 'HASH' );
    return $condition;
} ## end sub create_condition


###############################################################################

=head3 flesh_out_condition()

    Flesh out all of the functionality of the condition.

=cut

###############################################################################
sub flesh_out_condition {
    my ($condition) = @_;
    set_time($condition);
    set_temp($condition);
    set_air($condition);
    set_wind($condition);
    set_forecast($condition);
    set_clouds($condition);
    set_precip($condition);
    set_storm($condition);
    return $condition;
} ## end sub flesh_out_condition

###############################################################################

=head3 set_time()

    Set the current time of the conditions.

=cut

###############################################################################
sub set_time {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );

    my $timeobj = rand_from_array( $condition_data->{'time'}->{'option'} );
    $condition->{'time_description'} = $timeobj->{'content'} if ( !defined $condition->{'time_description'} );

    $condition->{'time_exact'} = time2str( '%H:%M', str2time( $timeobj->{'time'} ) + ( d(120) - 1 ) * 60 )
        if ( !defined $condition->{'time_exact'} );
    $condition->{'time_bar_mod'} = $timeobj->{'bar_mod'} if ( !defined $condition->{'time_bar_mod'} );
    $condition->{'time_pop_mod'} = $timeobj->{'pop_mod'} if ( !defined $condition->{'time_pop_mod'} );
    $condition->{'pop_mod'}->{'time'} = $condition->{'time_pop_mod'};
    $condition->{'bar_mod'}->{'time'} = $condition->{'time_bar_mod'};
    return $condition;
}


###############################################################################

=head3 set_temp()

    Set the current temp of the conditions.

=cut

###############################################################################
sub set_temp {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );

    my $tempobj = rand_from_array( $condition_data->{'temp'}->{'option'} );
    $condition->{'temp_description'} = $tempobj->{'content'} if ( !defined $condition->{'temp_description'} );
    $condition->{'temp_pop_mod'}     = $tempobj->{'pop_mod'} if ( !defined $condition->{'temp_pop_mod'} );
    $condition->{'pop_mod'}->{'temp'} = $condition->{'temp_pop_mod'};
    return $condition;
}


###############################################################################

=head3 set_air()

    Set the current air condition.

=cut

###############################################################################
sub set_air {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );

    my $airobj = rand_from_array( $condition_data->{'air'}->{'option'} );
    $condition->{'air_description'} = $airobj->{'content'} if ( !defined $condition->{'air_description'} );
    $condition->{'air_pop_mod'}     = $airobj->{'pop_mod'} if ( !defined $condition->{'air_pop_mod'} );
    $condition->{'pop_mod'}->{'air'} = $condition->{'air_pop_mod'};
    return $condition;
}


###############################################################################

=head3 set_wind()

    Set the current wind condition.

=cut

###############################################################################
sub set_wind {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );

    my $windobj = rand_from_array( $condition_data->{'wind'}->{'option'} );
    $condition->{'wind_description'} = $windobj->{'content'} if ( !defined $condition->{'wind_description'} );
    $condition->{'wind_pop_mod'}     = $windobj->{'pop_mod'} if ( !defined $condition->{'wind_pop_mod'} );
    $condition->{'pop_mod'}->{'wind'} = $condition->{'wind_pop_mod'};
    return $condition;
}


###############################################################################

=head3 set_forecast()

    Set the current forecast condition.

=cut

###############################################################################
sub set_forecast {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );

    my $forecastobj = rand_from_array( $condition_data->{'forecast'}->{'option'} );
    $condition->{'forecast_description'} = $forecastobj->{'content'}
        if ( !defined $condition->{'forecast_description'} );
    return $condition;
}


###############################################################################

=head3 set_clouds()

    Set the current clouds condition.

=cut

###############################################################################
sub set_clouds {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );

    my $cloudsobj = rand_from_array( $condition_data->{'clouds'}->{'option'} );
    $condition->{'clouds_description'} = $cloudsobj->{'content'} if ( !defined $condition->{'clouds_description'} );
    return $condition;
}


###############################################################################

=head3 set_precip()

    Set the current precipitation.

=cut

###############################################################################
sub set_precip {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );
    $condition->{'precip_chance'} = d(100) if ( !defined $condition->{'precip_chance'} );

    if ( $condition->{'precip_chance'} <= $condition_data->{'precip'}->{'chance'} ) {
        my $precipobj = rand_from_array( $condition_data->{'precip'}->{'option'} );
        $condition->{'precip_description'} = $precipobj->{'type'} if ( !defined $condition->{'precip_description'} );

        if ( defined $precipobj->{'option'} ) {
            my $subobj = rand_from_array( $precipobj->{'option'} );
            $condition->{'precip_subdescription'} = $subobj->{'type'}
                if ( !defined $condition->{'precip_subdescription'} );

        }

    }

    return $condition;
}


###############################################################################

=head3 set_storm()

    Set the current storm conditions if there is one, as well as flagging lightning and thunder.

=cut

###############################################################################
sub set_storm {

    my ($condition) = @_;
    set_seed( $condition->{'seed'} );
    $condition->{'storm_chance'} = d(100) if ( !defined $condition->{'storm_chance'} );
    set_seed();
    if ( $condition->{'storm_chance'} <= $condition_data->{'storm'}->{'chance'} ) {
        my $stormobj = rand_from_array( $condition_data->{'storm'}->{'option'} );
        $condition->{'storm_description'} = $stormobj->{'content'} if ( !defined $condition->{'storm_description'} );

        set_seed();
        $condition->{'thunder_chance'} = d(100) if ( !defined $condition->{'thunder_chance'} );
        if ( $condition->{'thunder_chance'} <= $condition_data->{'storm'}->{'thunder'}->{'chance'} ) {
            set_seed();
            my $thunderobj = rand_from_array( $condition_data->{'storm'}->{'thunder'}->{'option'} );
            $condition->{'thunder_description'} = $thunderobj->{'content'}
                if ( !defined $condition->{'thunder_description'} );
        }

        set_seed();
        $condition->{'lightning_chance'} = d(100) if ( !defined $condition->{'lightning_chance'} );
        if ( $condition->{'lightning_chance'} <= $condition_data->{'storm'}->{'lightning'}->{'chance'} ) {
            set_seed();
            my $lightningobj = rand_from_array( $condition_data->{'storm'}->{'lightning'}->{'option'} );
            $condition->{'lightning_description'} = $lightningobj->{'content'}
                if ( !defined $condition->{'lightning_description'} );
        }

    }
    return $condition;

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

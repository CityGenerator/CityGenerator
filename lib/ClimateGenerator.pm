#!/usr/bin/perl -wT
###############################################################################

package ClimateGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_climate flesh_out_climate);

###############################################################################

=head1 NAME

    ClimateGenerator - used to generate Climates

=head1 SYNOPSIS

    use ClimateGenerator;
    my $climate=ClimateGenerator::create_climate();

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

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by ClimateGenerator.pm:

=over

=item F<xml/climate.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
my $climate_data= $xml->XMLin( "xml/climate.xml", ForceContent => 1, ForceArray => ['option'] );

my $biomematrix=[  
	['EF','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW','BW'],
	['EF','DW','DW','CS','CS','BW','BW','BW','BW','BW','BW','BS','BS','BS','BS','BS','BS','BS','BS','BS','BS'],
	['EF','DW','DW','DW','CS','CS','CS','CS','CS','CS','CS','CS','CS','BS','BS','BS','BS','BS','BS','BS','BS'],
	['EF','ET','DW','DW','DW','CS','CS','CS','CS','CS','CS','CS','CS','CS','AW','AW','AW','AW','AW','AW','BS'],
	['EF','ET','DW','DW','DW','DW','CS','CS','CS','CS','CS','CS','CS','CS','CS','AW','AW','AW','AW','AW','BS'],
	['EF','ET','DW','DW','DW','DW','CW','CW','CW','CW','CS','CS','CS','CS','CS','AW','AW','AW','AW','AW','AW'],
	['EF','ET','DW','DW','DW','DW','CW','CW','CW','CW','CW','CS','CS','CS','CS','AW','AW','AW','AW','AW','AW'],
	['EF','ET','DW','DW','DW','DW','CW','CW','CW','CW','CW','CW','CW','CS','CS','AW','AW','AW','AW','AW','AW'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','CS','AW','AW','AW','AW','AW','AW'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AM','AM','AM','AM','AM','AM','AM'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AM','AM','AM','AM','AM','AM','AM'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AM','AM','AM','AM','AM','AM','AM'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AM','AM','AM','AM','AM','AM','AM'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AM','AM','AM','AM','AM','AM','AM'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AM','AM','AM','AM','AM','AM','AM'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AF','AF','AF','AF','AF','AF','AF'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CW','CW','CW','CW','AF','AF','AF','AF','AF','AF','AF'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CF','CF','CF','CF','AF','AF','AF','AF','AF','AF','AF'],
	['EF','ET','ET','DF','DF','DF','CW','CW','CW','CW','CF','CF','CF','CF','AF','AF','AF','AF','AF','AF','AF'],
	['EF','ET','ET','DF','DF','DF','CF','CF','CF','CF','CF','CF','CF','CF','AF','AF','AF','AF','AF','AF','AF'],
	['EF','ET','ET','DF','DF','DF','CF','CF','CF','CF','CF','CF','CF','CF','AF','AF','AF','AF','AF','AF','AF'],
];

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Core Methods

The following methods are used to create the core of the city structure.


=head3 create_climate()

This method is used to create a simple climate with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_climate {
    my ($params) = @_;
    my $climate = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $climate->{$key} = $params->{$key};
        }
    }

    if ( !defined $climate->{'seed'} ) {
        $climate->{'seed'} = set_seed();
    }

    #set base stat values, and if they don't exist, set new value.
    foreach my $stat (qw( altitude continentality latitude pressure )  ){
        if ( !defined $climate->{$stat}){
            $climate->{$stat}=d(101)-1;
        }else{
            $climate->{$stat}= min(100,  max(0,$climate->{$stat} )  );
        }
    }

    # The higher the latitude or altitude, the lower the temp.
    $climate->{'temperature'} = ((100 - $climate->{'altitude'}) + (100 - $climate->{'latitude'}))/2   if (!defined $climate->{'temperature'});
    # The higher the pressure and lower the continentality, the higher the precip
    $climate->{'precipitation'} =( $climate->{'pressure'} + (100 - $climate->{'continentality'}))/2   if (!defined $climate->{'precipitation'});

    #calculate the biome based on temp and precip
    $climate = calculate_biome($climate);

    return $climate;
} ## end sub create_climate

###############################################################################

=head2 Secondary Methods

The following methods are used to flesh out the climate.

=head3 flesh_out_climate()

Add the other features beyond the core climate.

=cut

###############################################################################
sub flesh_out_climate {
    my ($climate) = @_;
    GenericGenerator::set_seed( $climate->{'seed'} );
    calculate_wind($climate);
    calculate_temp($climate);
    calculate_precip($climate);
    calculate_cloudcover($climate);
 
    return $climate;
}



###############################################################################

=head3 calculate_biome()

    calculate which biome key and biome from temperature and precipitation

=cut

###############################################################################
sub calculate_biome {
    my ($climate) = @_;
    
    # These two lines are ugly ways to translate 0-100 precip and temp values to array indexes
    my $precipkey   = ceil( $climate->{'precipitation'}  /100 * (scalar(@$biomematrix) - 1)) ;
    my $tempkey = ceil( $climate->{'temperature'}/100 * (scalar( @{ $biomematrix->[$precipkey]   }) - 1));

    # once we know what are keys are, set the biome key, then look up the climate name.
    $climate->{'biomekey'}= $biomematrix->[$precipkey][$tempkey] if (!defined $climate->{'biomekey'});
    $climate->{'name'}=  $climate_data->{'biomes'}->{'option'}->{$climate->{'biomekey'}}->{'type'}  if (!defined $climate->{'name'});
    $climate->{'description'}=  $climate_data->{'biomes'}->{'option'}->{$climate->{'biomekey'}}->{'content'}  if (!defined $climate->{'description'});
    $climate->{'seasontypes'}=  [split( /,/, $climate_data->{'biomes'}->{'option'}->{$climate->{'biomekey'}}->{'seasons'})]  if (!defined $climate->{'seasontypes'});

    $climate->{'seasontype'}=  rand_from_array( $climate->{'seasontypes'}  ) if (!defined $climate->{'seasontype'});
    $climate->{'seasondescription'}= $climate_data->{'seasons'}->{'option'}->{$climate->{'seasontype'}}->{'content'}  if (!defined $climate->{'seasondescription'});


    return $climate;
}

###############################################################################

=head3 calculate_winds()

    calculate which type of wind to use

=cut

###############################################################################
sub calculate_wind {
    my ($climate) = @_;
    $climate->{'wind_roll'}=d(100) if (!defined $climate->{'wind_roll'} );
    $climate->{'wind_variation_roll'}=d(100) if (!defined $climate->{'wind_variation_roll'} );
    $climate->{'wind'}=  roll_from_array( $climate->{'wind_roll'}, $climate_data->{'winds'}->{'option'}  )->{'content'} if (!defined $climate->{'wind'});
    $climate->{'wind_variation'}=  roll_from_array( $climate->{'wind_variation_roll'}, $climate_data->{'variation'}->{'option'}  )->{'content'} if (!defined $climate->{'wind_variation'});
    return $climate;
}

###############################################################################

=head3 calculate_temp()

    calculate which type of temp to use

=cut

###############################################################################
sub calculate_temp {
    my ($climate) = @_;
    $climate->{'temp_variation_roll'}=d(100) if (!defined $climate->{'temp_variation_roll'} );
    $climate->{'temp'}=  roll_from_array( $climate->{'temperature'}, $climate_data->{'temp'}->{'option'}  )->{'content'} if (!defined $climate->{'temp'});
    $climate->{'temp_variation'}=  roll_from_array( $climate->{'temp_variation_roll'}, $climate_data->{'variation'}->{'option'}  )->{'content'} if (!defined $climate->{'temp_variation'});
    return $climate;
}

###############################################################################

=head3 calculate_precip()

    calculate which type of precip to use

=cut

###############################################################################
sub calculate_precip {
    my ($climate) = @_;
    $climate->{'precip_variation_roll'}=d(100) if (!defined $climate->{'precip_variation_roll'} );
    $climate->{'precip'}=  roll_from_array( $climate->{'precipitation'}, $climate_data->{'precip'}->{'option'}  )->{'content'} if (!defined $climate->{'precip'});
    $climate->{'precip_variation'}=  roll_from_array( $climate->{'precip_variation_roll'}, $climate_data->{'variation'}->{'option'}  )->{'content'} if (!defined $climate->{'precip_variation'});
    return $climate;
}

###############################################################################

=head3 calculate_cloudcover()

    calculate which type of cloudcover to use

=cut

###############################################################################
sub calculate_cloudcover {
    my ($climate) = @_;
    $climate->{'cloudcover_roll'}=d(100) if (!defined $climate->{'cloudcover_roll'} );
    $climate->{'cloudcover_variation_roll'}=d(100) if (!defined $climate->{'cloudcover_variation_roll'} );
    $climate->{'cloudcover'}=  roll_from_array( $climate->{'cloudcover_roll'}, $climate_data->{'cloudcover'}->{'option'}  )->{'content'} if (!defined $climate->{'cloudcover'});
    $climate->{'cloudcover_variation'}=  roll_from_array( $climate->{'cloudcover_variation_roll'}, $climate_data->{'variation'}->{'option'}  )->{'content'} if (!defined $climate->{'cloudcover_variation'});
    return $climate;
}



1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

#!/usr/bin/perl -wT
###############################################################################

package FlagGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_flag generate_colors);

###############################################################################

=head1 NAME

    FlagGenerator - used to generate Flags

=head1 SYNOPSIS

    use FlagGenerator;
    my $flag=CityGenerator::create_flag();

=cut

###############################################################################
use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use CityGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;
use version;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by FlagGenerator.pm:

=over

=item F<xml/flag.xml>

=back

=head1 INTERFACE


=cut

###############################################################################

#FIXME should the above line go before $xml is created orafter, and is this in every file??
my $flag_data = $xml->XMLin( "xml/flag.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the flagstructure.


=head3 create_flag()

This method is used to create a simple flag with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_flag {
    my ($params) = @_;
    my $flag = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $flag->{$key} = $params->{$key};
        }
    }

    if ( !defined $flag->{'seed'} ) {
        $flag->{'seed'} = GenericGenerator::set_seed();
    }
    $flag = generate_colors($flag);
    $flag = generate_shape($flag);
    $flag = generate_ratio($flag);
    $flag = generate_division($flag);
    $flag = generate_overlay($flag);
    $flag = generate_symbol($flag);

    #$flag = generate_border($flag);
    $flag = generate_letter($flag);
    return $flag;
} ## end sub create_flag


###############################################################################

=head2 generate_colors()

generate colors and their meanings

=cut

###############################################################################

sub generate_colors {
    my ($flag) = @_;

    my $colorcount = 7;
    GenericGenerator::set_seed( $flag->{'seed'} );


    my @colors = keys %{ $flag_data->{'colors'}->{'color'} };
    @colors = shuffle @colors;

    while ( $colorcount-- > 0 ) {
        @colors = shuffle @colors;

        #TODO replace this and other examples of it with an increment_seed method... and is this even needed??
        GenericGenerator::set_seed( GenericGenerator::get_seed() + 1 );
        my $color       = {};
        my $targetcolor = pop @colors;

        my $shade = rand_from_array( $flag_data->{'colors'}->{'color'}->{$targetcolor}->{'option'} );

        $color->{'hex'} = sprintf( "#%2.2X%2.2X%2.2X", $shade->{'red'}, $shade->{'green'}, $shade->{'blue'} );
        $color->{'type'} = $shade->{'type'};

        push @{ $flag->{'colors'} }, $color;
    }
    return $flag;
}


###############################################################################

=head2 generate_shape()

select a shape from the list as well as any attributes like scallops

=cut

###############################################################################
sub generate_shape {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );

    # First lets figure out what type of shape we're dealing with if we don't already have one.
    $flag->{'shape'}->{'name'} = rand_from_array( [ keys %{ $flag_data->{'shape'}->{'option'} } ] )
        if ( !defined $flag->{'shape'}->{'name'} );

    # Now that we have the name, lets grab the rest of it, including features.
    my $shape = $flag_data->{'shape'}->{'option'}->{ $flag->{'shape'}->{'name'} };


    # Lets see what attributes the shape has, and select some.
    foreach my $attribute_name ( keys %$shape ) {

        # select the option from the array
        my $attr = rand_from_array( $shape->{$attribute_name}->{'option'} );

        # If the attribute_name is already defined, don't use attr->content
        $flag->{'shape'}->{$attribute_name} = $attr->{'content'} if ( !defined $flag->{'shape'}->{$attribute_name} );

        # If the field is numeric and a value is not already set, randomly generate it.
        if (    defined $shape->{$attribute_name}->{'numeric'}
            and $shape->{$attribute_name}->{'numeric'}
            and ( !defined $flag->{'shape'}->{ $attribute_name . "_selected" } ) )
        {

            # Note that we're setting the seed here so passing in a paramter (say side=>top),
            # followup parameters will still be generated properly (count will still be 5)
            $flag->{'shape'}->{ $attribute_name . "_selected" } = d( $flag->{'shape'}->{$attribute_name} );
        }
    }
    return $flag;
}


###############################################################################

=head2 generate_ratio()

select a ratio of length:width for the flag

=cut

###############################################################################
sub generate_ratio {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );
    $flag->{'ratio'} = rand_from_array( $flag_data->{'ratio'}->{'option'} )->{'content'}
        if ( !defined $flag->{'ratio'} );
    return $flag;
}


###############################################################################

=head2 generate_division()

Determine which type of division and how it is numerically divided

=cut

###############################################################################
sub generate_division {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );

    # First lets figure out what type of division we're dealing with if we don't already have one.
    $flag->{'division'}->{'name'} = rand_from_array( [ keys %{ $flag_data->{'division'}->{'option'} } ] )
        if ( !defined $flag->{'division'}->{'name'} );

    # Now that we have the name, lets grab the rest of it, including features.
    my $division = $flag_data->{'division'}->{'option'}->{ $flag->{'division'}->{'name'} };


    # Lets see what attributes the division has, and select some.
    foreach my $attribute_name ( keys %$division ) {

        # select the option from the array
        my $attr = rand_from_array( $division->{$attribute_name}->{'option'} );

        # If the attribute_name is already defined, don't use attr->content
        $flag->{'division'}->{$attribute_name} = $attr->{'content'}
            if ( !defined $flag->{'division'}->{$attribute_name} );

        # If the field is numeric and a value is not already set, randomly generate it.
        if (    defined $division->{$attribute_name}->{'numeric'}
            and $division->{$attribute_name}->{'numeric'}
            and ( !defined $flag->{'division'}->{ $attribute_name . "_selected" } ) )
        {

            # Note that we're setting the seed here so passing in a paramter (say side=>top),
            # followup parameters will still be generated properly (count will still be 5)
            $flag->{'division'}->{ $attribute_name . "_selected" } = d( $flag->{'division'}->{$attribute_name} );
        }
    }
    return $flag;
}


###############################################################################

=head2 generate_overlay()

Determine which type of overlay and where is is located and sized

=cut

###############################################################################
sub generate_overlay {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );

    # First lets figure out what type of overlay we're dealing with if we don't already have one.
    $flag->{'overlay'}->{'name'} = rand_from_array( [ keys %{ $flag_data->{'overlay'}->{'option'} } ] )
        if ( !defined $flag->{'overlay'}->{'name'} );

    # Now that we have the name, lets grab the rest of it, including features.
    my $overlay = $flag_data->{'overlay'}->{'option'}->{ $flag->{'overlay'}->{'name'} };


    # Lets see what attributes the overlay has, and select some.
    foreach my $attribute_name ( keys %$overlay ) {

        # select the option from the array
        my $attr = rand_from_array( $overlay->{$attribute_name}->{'option'} );

        # If the attribute_name is already defined, don't use attr->content
        $flag->{'overlay'}->{$attribute_name} = $attr->{'content'}
            if ( !defined $flag->{'overlay'}->{$attribute_name} );

        # If the field is numeric and a value is not already set, randomly generate it.
        if (    defined $overlay->{$attribute_name}->{'numeric'}
            and $overlay->{$attribute_name}->{'numeric'}
            and ( !defined $flag->{'overlay'}->{ $attribute_name . "_selected" } ) )
        {

            # Note that we're setting the seed here so passing in a paramter (say side=>top),
            # followup parameters will still be generated properly (count will still be 5)
            $flag->{'overlay'}->{ $attribute_name . "_selected" } = d( $flag->{'overlay'}->{$attribute_name} );
        }
    }
    return $flag;
}


###############################################################################

=head2 generate_symbol()

Determine which type of symbol and where it is located

=cut

###############################################################################
sub generate_symbol {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );

    # First lets figure out what type of symbol we're dealing with if we don't already have one.
    $flag->{'symbol'}->{'name'} = rand_from_array( [ keys %{ $flag_data->{'symbol'}->{'option'} } ] )
        if ( !defined $flag->{'symbol'}->{'name'} );

    # Now that we have the name, lets grab the rest of it, including features.
    my $symbol = $flag_data->{'symbol'}->{'option'}->{ $flag->{'symbol'}->{'name'} };

    # Lets see what attributes the symbol has, and select some.
    foreach my $attribute_name ( keys %$symbol ) {

        # select the option from the array
        my $attr = rand_from_array( $symbol->{$attribute_name}->{'option'} );

        # If the attribute_name is already defined, don't use attr->content
        $flag->{'symbol'}->{$attribute_name} = $attr->{'content'} if ( !defined $flag->{'symbol'}->{$attribute_name} );

        # If the field is numeric and a value is not already set, randomly generate it.
        if (    defined $symbol->{$attribute_name}->{'numeric'}
            and $symbol->{$attribute_name}->{'numeric'}
            and ( !defined $flag->{'symbol'}->{ $attribute_name . "_selected" } ) )
        {

            # Note that we're setting the seed here so passing in a paramter (say side=>top),
            # followup parameters will still be generated properly (count will still be 5)
            $flag->{'symbol'}->{ $attribute_name . "_selected" } = d( $flag->{'symbol'}->{$attribute_name} );
        }
    }
    return $flag;
}


###############################################################################

=head2 generate_border()

Determine which type of border to use

=cut

###############################################################################
sub generate_border {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );
    $flag->{'border'} = rand_from_array( $flag_data->{'border'}->{'option'} )->{'content'}
        if ( !defined $flag->{'border'} );
    return $flag;
}


###############################################################################

=head2 generate_letter()

Determine which letter to use- if the cityname is given, use the first letter.
Otherwise, use a random capital letter.

=cut

###############################################################################
sub generate_letter {
    my ($flag) = @_;
    GenericGenerator::set_seed( $flag->{'seed'} );
    my @letters = ( 'A' .. 'Z' );
    if ( defined $flag->{'cityname'} ) {
        $flag->{'symbol'}->{'letter'} = substr $flag->{'cityname'}, 0, 1;
    } else {
        $flag->{'symbol'}->{'letter'} = $letters[ rand @letters ];
    }
    return $flag;
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

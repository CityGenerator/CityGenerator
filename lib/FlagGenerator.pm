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
use version;
use XML::Simple;

my $xml = XML::Simple->new();

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
my $flag_data    = $xml->XMLin( "xml/flag.xml", ForceContent => 1, ForceArray => ['option'] );

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
#    $flag = generate_symbol($flag);
    #$flag = generate_border($flag);
    #$flag = generate_letter($flag);
    return $flag;
} ## end sub create_flag


###############################################################################

=head2 generate_colors()

generate colors and their meanings

=cut

###############################################################################

sub generate_colors {
    my ($flag)=@_;

    my $colorcount=5;
    GenericGenerator::set_seed($flag->{'seed'});

    my @colors=keys %{$flag_data->{'colors'}->{'color'}};

    while ($colorcount-- >0){
        shuffle @colors;
        $GenericGenerator::seed++;
        my $color={};
        my $targetcolor=pop @colors;
        if ( defined $flag_data->{'colors'}->{'color'}->{$targetcolor}->{'meaning'}){
            $color->{'meaning'}=rand_from_array($flag_data->{'colors'}->{'color'}->{$targetcolor}->{'meaning'}->{'option'})->{'type'};
        }

        my $shade=rand_from_array($flag_data->{'colors'}->{'color'}->{$targetcolor}->{'option'});

        $color->{'hex'} = sprintf ("#%2.2X%2.2X%2.2X",$shade->{'red'},$shade->{'green'},$shade->{'blue'});
        $color->{'type'}=$shade->{'type'};

        push @{$flag->{'colors'}}, $color ;
    }
    return $flag;
}

sub generate_shape {
    my ($flag)=@_;
    GenericGenerator::set_seed($flag->{'seed'});
    $flag->{'shape'}=rand_from_array($flag_data->{'shape'}->{'option'})->{'content'} if (!defined $flag->{'shape'});
    return $flag;
}

sub generate_ratio {
    my ($flag)=@_;
    GenericGenerator::set_seed($flag->{'seed'});
    $flag->{'ratio'}=rand_from_array($flag_data->{'ratio'}->{'option'})->{'content'} if (!defined $flag->{'ratio'});
    return $flag;
}

sub generate_division {
    my ($flag)=@_;
    GenericGenerator::set_seed($flag->{'seed'});
    my $division=rand_from_array($flag_data->{'division'}->{'option'});


    $flag->{'division'}=$division->{'content'} if (!defined $flag->{'division'});
    return $flag;
}


sub generate_overlay {
    my ($flag)=@_;
    GenericGenerator::set_seed($flag->{'seed'});
    # First lets figure out what type of overlay we're dealing with if we don't already have one.
    $flag->{'overlay'} ->{'name'}= rand_from_array( [keys %{$flag_data->{'overlay'}->{'option'}}]  ) if (!defined $flag->{'overlay'}->{'name'});
    
    # Now that we have the name, lets grab the rest of it, including features.
    my $overlay=$flag_data->{'overlay'}->{'option'}->{  $flag->{'overlay'} ->{'name'}  };
   

    # Lets see what attributes the overlay has, and select some.
    foreach my $attribute_name (keys %$overlay){

        # Note that we're setting the seed here so passing in a paramter (say side=>top), 
        # followup parameters will still be generated properly (count will still be 5)
        GenericGenerator::set_seed($flag->{'seed'});
        # select the option from the array
        my $attr=rand_from_array( $overlay->{$attribute_name}->{'option'} ); 

        # If the attribute_name is already defined, don't use attr->content
        $flag->{'overlay'}->{$attribute_name}= $attr->{'content'} if (!defined  $flag->{'overlay'}->{$attribute_name});

        # If the field is numeric and a value is not already set, randomly generate it.
        GenericGenerator::set_seed($flag->{'seed'});
        if (defined $overlay->{$attribute_name}->{'numeric'} and 
            $overlay->{$attribute_name}->{'numeric'} and  
            !defined  $flag->{'overlay'}->{$attribute_name."_selected"}) {
                # Note that we're setting the seed here so passing in a paramter (say side=>top), 
                # followup parameters will still be generated properly (count will still be 5)
                $flag->{'overlay'}->{$attribute_name."_selected"}= d( $flag->{'overlay'}->{$attribute_name} ) ;
        }
    }
    return $flag;
}
sub generate_symbol {
    my ($flag)=@_;
    GenericGenerator::set_seed($flag->{'seed'});
    $flag->{'symbol'}=rand_from_array($flag_data->{'symbol'}->{'option'})->{'content'} if (!defined $flag->{'symbol'});
    return $flag;
}

sub generate_border {
    my ($flag)=@_;
    GenericGenerator::set_seed($flag->{'seed'});
    $flag->{'border'}=rand_from_array($flag_data->{'border'}->{'option'})->{'content'} if (!defined $flag->{'border'});
    return $flag;
}


sub generate_letter {
    my ($flag)=@_;
    my $city={'seed'=>$flag->{'seed' }};
    $city=CityGenerator::generate_city_name($city)->{'name'};
    $flag->{'letter'}=substr( $city,0,1 ) if (!defined $flag->{'letter'});
    return $flag;
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

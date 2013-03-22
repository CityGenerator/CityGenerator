#!/usr/bin/perl -wT
###############################################################################

package FlagGenerator;

###############################################################################

=head1 NAME

    FlagGenerator - used to generate Flags

=head1 DESCRIPTION

 This can be used to create a Flag

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( create_flag generate_colors);

use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 Data files

The following datafiles are used by FlagGenerator.pm:

=over

=item F<xml/flag.xml>

=back

=cut

###############################################################################
# FIXME This needs to stop using our
our $flag_data    = $xml->XMLin( "xml/flag.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################


=head2 create_flag()

This method is used to create a simple flag with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_flag {
    my ($params) = @_;
    my $flag={};

    if (ref $params eq 'HASH'){
        foreach my $key (sort keys %$params){
            $flag->{$key}=$params->{$key};
        }
    }

    if(!defined $flag->{'seed'}){
        $flag->{'seed'}=set_seed();
    }

    return $flag;
}

###############################################################################

=head2 generate_colors()

generate colors and their meanings

=cut

###############################################################################

sub generate_colors {
    my ($flag)=@_;

    my $colorcount=5;
    set_seed($flag->{'seed'});

    my @colors=keys %{$flag_data->{'color'}};

    while ($colorcount-- >0){
        shuffle @colors;
        $GenericGenerator::seed++;
        my $color={};
        my $targetcolor=pop @colors;
        if ( defined $flag_data->{'color'}->{$targetcolor}->{'meaning'}){
            $color->{'meaning'}=rand_from_array($flag_data->{'color'}->{$targetcolor}->{'meaning'}->{'option'})->{'type'};
        }

        my $shade=rand_from_array($flag_data->{'color'}->{$targetcolor}->{'option'});

        $color->{'hex'} = sprintf ("#%2.2X%2.2X%2.2X",$shade->{'red'},$shade->{'green'},$shade->{'blue'});
        $color->{'type'}=$shade->{'type'};

        push @{$flag->{'colors'}}, $color ;
    }
    return $flag;
}



1;

#!/usr/bin/perl -wT
###############################################################################

package MilitaryGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_military);

###############################################################################

=head1 NAME

    MilitaryGenerator - used to generate military statistics

=head1 SYNOPSIS

    use MilitaryGenerator;
    my $military=MilitaryGenerator::create_military($source);
  
=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item * F<xml/data.xml>

=cut

###############################################################################
my $xml_data            = $xml->XMLin( "xml/data.xml",           ForceContent => 1, ForceArray => ['option'] );



###############################################################################

=head2 Core Methods

The following methods are used to create the core of the military structure.


=head3 create_military()

This method is used to create a simple military from a given object.

=over

=item * a seed

=item * a source name

=item * a size classification

=item * a population estimation

=back

=cut

###############################################################################
sub create_military {
    my ($source) = @_;
    my $military = {};

    # swipe important details from city

    if ( defined $source->{'seed'} ) {
        $military->{'seed'} =  $source->{'seed'};
    }else{
        $military->{'seed'} = set_seed();
    }
    $military->{'original_seed'} = $military->{'seed'};


    return $military;
} ## end sub create_military













1;

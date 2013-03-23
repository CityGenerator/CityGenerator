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


###############################################################################

=head2 generate_preparation()
    
Determine how well prepared they are, which is influenced by the "military" stat
for the provided source.

=cut

###############################################################################

sub generate_preparation {
    my ($military)=@_;

    if (!defined $military->{'preparation_roll'}){
        if (defined $military->{'mil_mod'} &&  $military->{'mil_mod'} < -1 ) {
            $military->{'preparation_roll'}=&d(45);
        }elsif ($military->{'mil_mod'} &&  $military->{'mil_mod'} > 1 ) {
            $military->{'preparation_roll'}=56+ &d(45);
        }else{
            $military->{'preparation_roll'}=&d(100);
        }
    }
    $military->{'preparation'}=roll_from_array( $military->{'preparation_roll'} , $xml_data->{'preparation'}->{'option'})->{'content'} if (!defined $military->{'preparation'});
    return $military;
}

###############################################################################

=head2 generate_favored_tactic()

    generate favored_tactics in battle

=cut

###############################################################################

sub generate_favored_tactic {
    my ($military)=@_;
    
     my $tactic=rand_from_array(    $xml_data->{'tactictypes'}->{'option'} )->{'content'};
     $military->{'favored tactic'}= $tactic if (!defined $military->{'favored tactic'});
    return $military;
}

###############################################################################

=head2 generate_reputation()

    generate favored_tactics in battle

=cut

###############################################################################

sub generate_reputation {
    my ($military)=@_;
    
    my $rep = rand_from_array(  $xml_data->{'reputation'}->{'option'}  )->{'content'};
    $military->{'reputation'}=$rep if (!defined $military->{'reputation'});
    return $military;
}


###############################################################################

=head2 generate_favored_weapon()

generate favored_weapon preferred by the military.

=cut

###############################################################################

sub generate_favored_weapon {
    my ($military)=@_;

    my $weaponclass=rand_from_array(    $xml_data->{'weapontypes'}->{'weapon'} );
    $military->{'favored weapon'}    = rand_from_array(    $weaponclass->{'option'} )->{'content'} if  (!defined $military->{'favored weapon'} );

    return $military;
} 








1;

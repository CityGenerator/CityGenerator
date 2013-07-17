#!/usr/bin/perl -wT
###############################################################################

package GovtFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printGovt printCrime);

###############################################################################

=head1 NAME

    GovtFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

###############################################################################

=head2 printGovt()

printGovt strips out important info from a Govt Object

=cut

###############################################################################
sub printGovt {
    my ($city) = @_;
    my $content="";
    my $govt=$city->{'govt'};
    $content= "$city->{'name'} is ruled a $govt->{'reputation'} $govt->{'description'}. Within the city there is a $govt->{'secondary_power'}->{'power'} that $govt->{'secondary_power'}->{'plot'} current leadership. The population approves of $govt->{'description'} policies in general.";
    return $content;
}

###############################################################################

=head2 printCrime()

printGovt strips out important info from a Govt Object

=cut

###############################################################################
sub printCrime {
    my ($city) = @_;
    my $content="";
    my $govt=$city->{'govt'};
    $content= "Crime is $city->{'crime_description'}. Laws are enforced by a $city->{'laws'}->{'enforcer'}. Justice is served by $city->{'laws'}->{'trial'}, with a common punishment being $city->{'laws'}->{'punishment'}. The most common crime is $city->{'laws'}->{'commoncrime'}. The imprisonment rate is ".($city->{'imprisonment_rate'}->{'percent'}*100)."% of the population ($city->{'imprisonment_rate'}->{'population'} adult[s]).";
    return $content;
}

1;

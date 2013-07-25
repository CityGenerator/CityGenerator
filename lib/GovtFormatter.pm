#!/usr/bin/perl -wT
###############################################################################

package GovtFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printGovt printCrime printLeader printMilitary printLaw );

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
use Lingua::EN::Inflect qw( A ) ;
use POSIX;
use version;

###############################################################################

=head2 printLeader()

printLeader strips out important info from a Govt Object about the current Leader

=cut

###############################################################################
sub printLeader {
    my ($city) = @_;
    my $content="";
    my $govt=$city->{'govt'};
    $content.= "$city->{'name'} is ruled by ".A($city->{'govt'}->{'leader'}->{'title'})." ( $city->{'govt'}->{'leader'}->{'title'} $city->{'govt'}->{'leader'}->{'name'}  ) through ".A($city->{'govt'}->{'type'}).", where ".$city->{'govt'}->{'description'}.". ";
    $content.= "The $city->{'govt'}->{'leader'}->{'title'} has been in power $city->{'govt'}->{'leader'}->{'length'} and is $city->{'govt'}->{'leader'}->{'reputation'} by the people. ";
    $content.= "There is $city->{'govt'}->{'leader'}->{'opposition'} opposition to the $city->{'govt'}->{'leader'}->{'title'} and policies. ";
    $content.= "The right to rule was granted $city->{'govt'}->{'leader'}->{'right'}, and that power is maintained $city->{'govt'}->{'leader'}->{'maintained'}. ";
    $content.= "Officials in $city->{'name'} are often seen as $city->{'govt'}->{'corruption_description'} and the policies are $city->{'govt'}->{'approval_description'}. ";
    $content.= "The government as a whole is seen as $city->{'govt'}->{'efficiency_description'}. ";
    $content.= "The political influence of $city->{'name'} in the region is $city->{'govt'}->{'influence_description'} due to $city->{'govt'}->{'influencereason'}. ";
    $content.= "In times of crisis, the population $city->{'govt'}->{'unity_description'}. ";

#
#$city->{'name'} is ruled a $govt->{'reputation'} $govt->{'description'}. Within the city there is a $govt->{'secondary_power'}->{'power'} that $govt->{'secondary_power'}->{'plot'} current leadership. The population approves of $govt->{'description'} policies in general.";
    return $content;
}

###############################################################################

=head2 printLaw()

printGovt strips out important info from a Govt Object

=cut

###############################################################################
sub printLaw {
    my ($city) = @_;
    my $content="";
    my $govt=$city->{'govt'};
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
    return $content;
}

###############################################################################

=head2 printCrime()

printGovt strips out important info from a Govt Object

=cut

###############################################################################
sub printMilitary {
    my ($city) = @_;
    my $content="";
    my $govt=$city->{'govt'};
    return $content;
}

1;

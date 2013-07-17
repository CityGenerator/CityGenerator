
#!/usr/bin/perl -wT
###############################################################################

package EnvironmentFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printEnvironment);

###############################################################################

=head1 NAME

    EnvironmentFormatter - used to format the environment.

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

=head2 printGeography()

printGeography strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printGeography {
    my ($city) = @_;
    my $content="";
    $content.="This $city->{'arable_description'} $city->{'size'} is $city->{'density_description'} populated ($city->{'population_density'}/sq km) and covers $city->{'area'} square kilometers.";

    return $content;
}
1;

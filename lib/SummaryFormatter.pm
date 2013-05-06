
#!/usr/bin/perl -wT
###############################################################################

package SummaryFormatter;

###############################################################################

=head1 NAME

    SummaryFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( printSummary);

use CGI;
use Data::Dumper;
use List::Util 'shuffle', 'min', 'max';
use POSIX;

=head2 printSummary()

printSummary strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($city) = @_;
    print Dumper $city;
    my $content="";
    $content.="$city->{'name'} is a $city->{'size'} in the $city->{'region'}->{'name'} with a $city->{'description'} of around $city->{'pop_estimate'}.";

    return $content;
}

1;

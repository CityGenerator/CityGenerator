
#!/usr/bin/perl -wT
###############################################################################

package GeographyFormatter;

###############################################################################

=head1 NAME

    GeographyFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( printGeography);

use CGI;
use Data::Dumper;
use List::Util 'shuffle', 'min', 'max';
use POSIX;

=head2 printGeography()

printGeography strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printGeography {
    my ($city) = @_;
    my $content="";
    $content.="This $city->{'arable_description'} $city->{'size'} is $city->{'density_description'} populated, covering $city->{'area'} hectares and supported by a $city->{'support_area'} square mile region.";

    return $content;
}

1;

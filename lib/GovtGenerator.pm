#!/usr/bin/perl -wT
###############################################################################

package GovtGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_govt);

###############################################################################

=head1 NAME

    GovtGenerator - used to generate Governments

=head1 SYNOPSIS

    use GovtGenerator;
    my $govt=GovtGenerator::create_govt();

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by GovtGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/govts.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
# FIXME This needs to stop using our
my $xml_data           = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
my $govt_data= $xml->XMLin( "xml/govts.xml", ForceContent => 1, ForceArray => [] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the govt structure.


=head3 create_govt()

This method is used to create a simple govt with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_govt {
    my ($params) = @_;
    my $govt = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $govt->{$key} = $params->{$key};
        }
    }

    if ( !defined $govt->{'seed'} ) {
        $govt->{'seed'} = set_seed();
    }
    generate_stats($govt);
    set_govt_type($govt);
    set_secondary_power($govt);
    set_reputation($govt);
    return $govt;
} ## end sub create_govt

###############################################################################


=head3 generate_stats()

This method is used to generate baseline stats

=cut

###############################################################################
sub generate_stats {
    my ($govt) = @_;
    $govt->{'stats'}->{'corruption'} = d(100) if ( !defined $govt->{'stats'}->{'corruption'} );
    $govt->{'stats'}->{'approval'}   = d(100) if ( !defined $govt->{'stats'}->{'approval'}   );
    $govt->{'stats'}->{'efficiency'} = d(100) if ( !defined $govt->{'stats'}->{'efficiency'} );
    $govt->{'stats'}->{'influence'}  = d(100) if ( !defined $govt->{'stats'}->{'influence'}  );
    $govt->{'stats'}->{'unity'}      = d(100) if ( !defined $govt->{'stats'}->{'unity'}      );


    return $govt;
} ## end sub create_govt


###############################################################################


=head3 set_govt_type()

This method is used to create a simple govt with nothing more than:

=cut

###############################################################################
sub set_govt_type {
    my ($govt) = @_;

    my $govtype=rand_from_array($govt_data->{'govtypes'}->{'option'});
    $govt->{'description'} =$govtype->{'content'} if (!defined $govt->{'description'} );
    $govt->{'type_approval_mod'} =$govtype->{'approval_mod'} if (!defined $govt->{'type_approval_mod'} );
    $govt->{'stats'}->{'approval'}+=$govt->{'type_approval_mod'};

    return $govt;
} ## end sub create_govt

###############################################################################


=head3 set_secondary_power()

This method is used to create a secondary power and plot.

=cut

###############################################################################
sub set_secondary_power {
    my ($govt) = @_;

    my $plot    = rand_from_array($govt_data->{'secondarypower'}->{'plot'});
    my $power   = rand_from_array($govt_data->{'secondarypower'}->{'power'});
    my $subplot = rand_from_array($power->{'subplot'});
    $govt->{'secondary_power'}->{'plot'}         = $plot->{'content'}   if (!defined $govt->{'secondary_power'}->{'plot'} );
    $govt->{'secondary_power'}->{'power'}        = $power->{'type'}     if (!defined $govt->{'secondary_power'}->{'power'} );
    $govt->{'secondary_power'}->{'subplot_roll'} = d(100)               if (!defined $govt->{'secondary_power'}->{'subplot_roll'} );
    if ( $govt->{'secondary_power'}->{'subplot_roll'}   < $power->{'subplot_chance'} ) {
        $govt->{'secondary_power'}->{'subplot'} =$subplot->{'content'} if (!defined $govt->{'secondary_power'}->{'subplot'} );
    }
    return $govt;
} ## end sub create_govt

###############################################################################


=head3 set_reputation()

select how the population feels about the govt

=cut

###############################################################################
sub set_reputation {
    my ($govt) = @_;

    my $reputation=rand_from_array($xml_data->{'reputation'}->{'option'});
    $govt->{'reputation'} =$reputation->{'content'} if (!defined $govt->{'reputation'} );
    $govt->{'reputation_approval_mod'} =$reputation->{'approval_mod'} if (!defined $govt->{'reputation_approval_mod'} );


    return $govt;
} ## end sub create_govt





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

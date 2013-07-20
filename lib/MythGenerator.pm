#!/usr/bin/perl -wT
###############################################################################

package MythGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_myth);


#TODO make generate_name method for use with namegenerator

###############################################################################

=head1 NAME

    MythGenerator - used to generate Myths

=head1 SYNOPSIS

    use MythGenerator;
    my $myth=MythGenerator::create_myth();

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

The following datafiles are used by MythGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/myths.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
# FIXME This needs to stop using our
my $xml_data           = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
my $mythnames_data= $xml->XMLin( "xml/myths.xml", ForceContent => 1, ForceArray => [] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the myth structure.


=head3 create_myth()

This method is used to create a simple myth with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_myth {
    my ($params) = @_;
    my $myth = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $myth->{$key} = $params->{$key};
        }
    }

    if ( !defined $myth->{'seed'} ) {
        $myth->{'seed'} = set_seed();
    }

    return $myth;
} ## end sub create_myth




#Generate Myths


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

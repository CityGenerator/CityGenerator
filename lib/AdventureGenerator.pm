#!/usr/bin/perl -wT
###############################################################################

package AdventureGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_adventure create_name);


###############################################################################

=head1 NAME

    AdventureGenerator - used to generate Adventures

=head1 SYNOPSIS

    use AdventureGenerator;
    my $adventure=AdventureGenerator::create_adventure();

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use Lingua::EN::Inflect qw( A ) ;
use Lingua::EN::Conjugate qw( gerund s_form participle );
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by AdventureGenerator.pm:

=over

=item F<xml/adventure.xml>

=item F<xml/adventurenames.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################

our $adv_data     = $xml->XMLin( "xml/adventure.xml",       ForceContent => 1, ForceArray => ['option'] );
our $advname_data = $xml->XMLin( "xml/adventurenames.xml", ForceContent => 1, ForceArray => [] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the adventure structure.


=head3 create_adventure()

This method is used to create a simple adventure with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_adventure {
    my ($params) = @_;
    my $adventure = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $adventure->{$key} = $params->{$key};
        }
    }

    if ( !defined $adventure->{'seed'} ) {
        $adventure->{'seed'} = set_seed();
    }

    return $adventure;
} ## end sub create_adventure

###############################################################################
sub generate_name {
    my ($adventure) = @_;
    GenericGenerator::set_seed($adventure->{'seed'});
    $adventure->{'namepattern'}=rand_from_array($advname_data->{'pattern'}->{'option'})->{'content'} if (!defined $adventure->{'namepattern'});
    $adventure->{'name'} = $adventure->{'namepattern'}  if (!defined $adventure->{'name'} );

    my $subject=generate_subject($adventure);
    while ( $adventure->{'name'} =~ s/SUBJECT/$subject/) {
        $subject=generate_subject($adventure);
    }
    my $noun=generate_noun($adventure);
    while ( $adventure->{'name'} =~ s/NOUN/$noun/) {
        $subject=generate_noun($adventure);
    }

    while ( $adventure->{'name'} =~ /VERB\.gerund/ ) {
        my $verb = gerund (generate_verb($adventure));
        $adventure->{'name'} =~ s/VERB\.gerund/$verb/;
    }

    while ( $adventure->{'name'} =~ /VERB\.thirdperson/ ) {
        my $verb = s_form (generate_verb($adventure));
        $adventure->{'name'} =~ s/VERB\.thirdperson/$verb/;
    }
    while ( $adventure->{'name'} =~ /VERB\.participle/ ) {
        my $verb = participle (generate_verb($adventure));
        $adventure->{'name'} =~ s/VERB\.participle/$verb/;
    }

    while ( $adventure->{'name'} =~ /VERB/ ) {
        my $verb = generate_verb($adventure);
        $adventure->{'name'} =~ s/VERB/$verb/;
    }

    while ( $adventure->{'name'} =~ s/NEGATE/Don't/ ) {
    }



    $adventure->{'name'} = ucfirst $adventure->{'name'};

    return $adventure;
} ## end sub create_adventure


sub generate_noun {
    my ($adventure)=@_;
    return ucfirst rand_from_array($advname_data->{'noun'}->{'option'})->{'base'};
}


sub generate_subject {
    my ($adventure)=@_;
    my $subject="";
    $subject=generate_noun($adventure);

    if ( d(100) > $advname_data->{'pattern'}->{'adjective_chance'} ){
        $subject=ucfirst rand_from_array($advname_data->{'adjective'}->{'option'})->{'base'} . " $subject";
    }

    if ( d(100) > $advname_data->{'pattern'}->{'article_chance'} ){
        my $article= rand_from_array($advname_data->{'article'}->{'option'})->{'content'};
        if($article eq "a"){
            $subject=A($subject);
        }else{
            $subject= "$article $subject";
        }
    }
    return $subject;
}

sub generate_verb {
    my ($adventure)=@_;
    my $verb=ucfirst rand_from_array($advname_data->{'verb'}->{'option'})->{'base'};

    if ( d(100) > $advname_data->{'pattern'}->{'adverb_chance'} ){
        $verb=ucfirst rand_from_array($advname_data->{'adverb'}->{'option'})->{'base'} . " $verb";
    }

    return $verb;
}

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

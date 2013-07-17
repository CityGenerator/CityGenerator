#!/usr/bin/perl -wT
###############################################################################

package GenericGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( get_seed set_seed rand_from_array roll_from_array d parse_object seed);

###############################################################################

=head1 NAME

    GenericGenerator - Base package used by other Generators

=head1 SYNOPSIS

    use GenericGenerator;
    GenericGenerator::set_seed();

=cut

###############################################################################

#TODO add a bound function- bound(1,100,$val)
use Carp;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX; 
use version;
use Carp qw(longmess);
###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

No datafiles are directly used by GenericGenerator.

=cut

our $seed;


=head1 INTERFACE


=cut

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the city structure.




###############################################################################

=head2 get_seed()

Return the $seed value

=cut

###############################################################################
sub get_seed{

    return $seed;
}

###############################################################################

=head2 set_seed()

Check the parameters for cityID and set the seed accordingly.
This is what allows us to return to previously generated hosts.

=cut

###############################################################################
sub set_seed{
    my ($newseed)=@_;

    if ( (!defined $newseed) or $newseed!~ m/^\d+$/x){
        $newseed = int rand(1000000);
    }
    $seed=$newseed;
    srand $seed;
    return $seed;
}


###############################################################################

=head2 rand_from_array()

Select a random item from an array.

=cut

###############################################################################
sub rand_from_array {
    my ($array) = @_;
    if (ref $array  ne 'ARRAY'){
        print STDERR longmess();
        croak "you passed in something that wasn't an array reference. @!";
    }
    return $array->[ rand @$array  ];
}

###############################################################################

=head2 roll_from_array()

When passed a roll and a list of items, check the min and max properties of 
each and select the one that $roll best fits otherwise use the first item.

=cut

###############################################################################
sub roll_from_array {
    my ( $roll, $items ) = @_;
    my $selected_item = $items->[0];
    for my $item (@$items) {

        if (defined $item->{'min'} and defined $item->{'max'} ){
            if ( $item->{'min'} <= $roll and $item->{'max'} >= $roll ) {
                $selected_item = $item;
                last;
            }
        }elsif ( ! defined $item->{'min'} && !  defined $item->{'max'} ){
                $selected_item = $item;
                last;
        }elsif ( ! defined $item->{'min'}  ){
            if ( $item->{'max'} >= $roll ) {
                $selected_item = $item;
                last;
            }
        }else{
            if ( $item->{'min'} <= $roll ) {
                $selected_item = $item;
                last;
            }
        }
    }
    return $selected_item;
}

###############################################################################

=head2 d()

This serves the function of rolling a dice- a d6, d10, etc.

=cut

###############################################################################
sub d {
    my ($die) = @_;
    # d as in 1d6
    if ( $die=~ /^\d+$/x ){
        return int( rand($die)+1 );
    }elsif ($die=~/^(\d+)d(\d+)$/x){
        my $dicecount=$1;
        $die=$2;
        my $total=0;
        while ($dicecount-- >0){
            $total+=&d($die);
        }
        return $total;
    }else{
        croak "$die is not a valid dice format.";

    }
}

###############################################################################

=head2 parse_object()

A horribly named subroutine to parse out and randomly select the parts. This
method is really the crux of the name generation stuff.

=cut

###############################################################################
sub parse_object {
    my ($object)=@_;
    my $newobj= { 'content'=>'' };
    # We currently only care about 4 parts; FIXME to pull this list dynamically
    foreach my $part (qw/title pre root post trailer/){
        # Make sure that the part exists for this object.
        if(defined $object->{$part}){

            my $newpart;
            # If the object is an array, we're going to shuffle
            # the array and select one of the elements.
            if ( ref($object->{$part}) eq 'ARRAY'){
                # Shuffle the array and pop one element off
                my @parts=shuffle( @{$object->{$part}});
                $newpart=pop(@parts);

            # If the object is a Hash, we presume that there's only one choice
            } elsif ( ref($object->{$part}) eq 'HASH'  and $object->{$part}->{'content'}){
                # rename for easier handling
                $newpart=$object->{$part};
            }

            # make sure the element has content;
            # ignore it if it doesn't.
            if (defined $newpart->{'content'}){
                if (
                        # If no chance is defined, add it to the list.
                        (!defined $object->{$part.'_chance'}) or
                        # If chance is defined, compare it to
                        # the roll, and add it to the list.
                        ( &d(100) <= $object->{$part.'_chance'}) ) {

                    $newobj->{$part}=$newpart->{'content'};
                    if ($part eq 'title'){
                        $newpart->{'content'}="$newpart->{'content'} " ;
                    }elsif ($part eq 'trailer'){
                        $newpart->{'content'}=" $newpart->{'content'}" ;
                    }
                    $newobj->{'content'}.= $newpart->{'content'};
                }
            }
        }
    }
    #FIXME Sloppy as hell but it resolves the multiplying spaces issue
    $newobj->{'content'}=~s/\s+/ /xg;
    # return the slimmed down version
    return $newobj;
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

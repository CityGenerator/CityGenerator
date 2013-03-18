#!/usr/bin/perl -wT
###############################################################################

package ConditionGenerator;

###############################################################################

=head1 NAME

    ConditionGenerator - used to generate Conditions

=head1 DESCRIPTION

 This can be used to create a Condition

=cut

###############################################################################

use strict;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( create_condition );

use CGI;
use Data::Dumper;
use Date::Format qw(time2str);
use Date::Parse qw( str2time );
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = new XML::Simple;

###############################################################################

=head1 Data files

The following datafiles are used by ConditionGenerator.pm:

=over

=item F<xml/conditions.xml>

=back

=cut

###############################################################################
# FIXME This needs to stop using our
our $condition_data= $xml->XMLin( "xml/conditions.xml", ForceContent => 1, ForceArray => [] );

###############################################################################


=head2 create_condition()

This method is used to create a simple condition with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_condition {
    my ($params) = @_;
    my $condition={};

    if (ref $params eq 'HASH'){
        foreach my $key (sort keys %$params){
            $condition->{$key}=$params->{$key};
        }
    }

    if(!defined $condition->{'seed'}){
        $condition->{'seed'}=set_seed();
    }
    $condition->{'original_seed'}=$condition->{'seed'};

    return $condition;
}


###############################################################################

=head2 set_time()

    Set the current time of the conditions.

=cut

###############################################################################
sub set_time {

    my ($condition) = @_;
    set_seed($condition->{'seed'});

    my $timeobj= rand_from_array( $condition_data->{'time'}->{'option'} );
    $condition->{'time_description'}=$timeobj->{'content'}  if (!defined $condition->{'time_description'} );

    $condition->{'time_exact'}=time2str('%H:%M', str2time($timeobj->{'time'})+( d(120)-1)*60   )   if (!defined $condition->{'time_exact'} );
    $condition->{'time_bar_mod'}=$timeobj->{'bar_mod'}  if (!defined $condition->{'time_bar_mod'} );
    $condition->{'time_pop_mod'}=$timeobj->{'pop_mod'}  if (!defined $condition->{'time_pop_mod'} );
}


###############################################################################

=head2 set_temp()

    Set the current temp of the conditions.

=cut

###############################################################################
sub set_temp {

    my ($condition) = @_;
    set_seed($condition->{'seed'});

    my $tempobj= rand_from_array( $condition_data->{'temp'}->{'option'} );
    $condition->{'temp_description'}=$tempobj->{'content'}  if (!defined $condition->{'temp_description'} );
    $condition->{'temp_pop_mod'}=$tempobj->{'pop_mod'}  if (!defined $condition->{'temp_pop_mod'} );
}

1;

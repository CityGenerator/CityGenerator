#!/usr/bin/perl -wT
package NPCGenerator;

###############################################################################

=head1 NAME

    NPCGenerator - used to generate NPCs

=head1 DESCRIPTION

 Use this to create NPCs.

=cut

###############################################################################

use strict;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( generate_npc_names get_races names_data create_npc xml_data);

use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = new XML::Simple;

our $names_data = $xml->XMLin( "xml/npcnames.xml", ForceContent => 1, ForceArray => ['allow'] );
our $xml_data   = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 create_npc( params )

Create an NPC Object and fill it out.

=cut

###############################################################################

sub create_npc{
    my ($params)=@_;
    my $npc={};
    if (defined $params){
        foreach my $key (keys %$params){
            $npc->{$key}= $params->{$key};
        }
    }
    $npc->{'seed'}= GenericGenerator::set_seed($npc->{'seed'});
    if (! defined $npc->{'race'}){
        $npc->{'race'}=GenericGenerator::rand_from_array( [ keys %{$names_data->{'race'}}] );
        $npc->{'race_article'}=$names_data->{'race'}->{$npc->{'race'}}->{'article'}   ;
        $npc->{'race_plural'}=$names_data->{'race'}->{$npc->{'race'}}->{'plural'}   ;
    }
    generate_npc_name($npc->{'race'},$npc);
    $npc->{'skill'}             = roll_from_array( &d(100), $xml_data->{'skill'}->{'level'} )->{'content'};
    $npc->{'behavior'}          = rand_from_array( $xml_data->{'behavioraltraits'}->{'trait'} )->{'type'};
    $npc->{'reputation_scope'}  = rand_from_array( $xml_data->{'area'}->{'scope'} )->{'content'};
    set_attitudes($npc);
    return $npc;
}


###############################################################################

=head2 set_attitudes( npc )

Take a provided npc structure and set the primary, secondary and ternary attitudes
 that the npc displays.

=cut

###############################################################################

sub set_attitudes{
    my ($npc)=@_;
    if ( defined $xml_data->{'attitude'} and ref $xml_data->{'attitude'} eq 'HASH') {
        if (defined $xml_data->{'attitude'}->{'option'} and ref $xml_data->{'attitude'}->{'option'} eq 'ARRAY'){
            my $primary_attitude  = rand_from_array( $xml_data->{'attitude'}->{'option'} );
            $npc->{'primary_attitude'}=$primary_attitude->{'type'};
    
            if (defined $primary_attitude->{'option'} and ref $primary_attitude->{'option'} eq 'ARRAY'){
                my $secondary_attitude  = rand_from_array( $primary_attitude->{'option'});
                $npc->{'secondary_attitude'}=$secondary_attitude->{'type'};
    
                if (defined $secondary_attitude->{'option'} and ref $secondary_attitude->{'option'} eq 'ARRAY'){
                    my $ternary_attitude  = rand_from_array($secondary_attitude->{'option'});
                    $npc->{'ternary_attitude'}=$ternary_attitude->{'type'};
                }
            }
        }
    }
}






###############################################################################

=head2 get_races( )

Return a list of supported races.

=cut

###############################################################################

sub get_races{
    return [ sort keys %{ $names_data->{'race'}}];
}


###############################################################################

=head2 generate_npc_name( race )

generate an npc name if they're available for that race.

=cut

###############################################################################

sub generate_npc_name{
    my($race, $npc)=@_;
    $race= lc $race;

    # Check to see if this is a mutt race like any
    if ( defined $names_data->{'race'}->{ $race} and defined $names_data->{'race'}->{ $race}->{'allow'} ){
        $race= rand_from_array($names_data->{'race'}->{ $race}->{'allow'})->{'content'};
    }

    if (defined $names_data->{'race'}->{ $race}     ){
        my $racenameparts=$names_data->{'race'}->{ $race} ;

        if ( defined $racenameparts->{'firstname'} ){
            $npc->{'firstname'}= parse_object(    $racenameparts->{'firstname'}         )->{'content'};
            if ($npc->{'firstname'} ne ''){
                $npc->{'fullname'}=$npc->{'firstname'};
            }
        }
        if ( defined $racenameparts->{'lastname'} ){
            $npc->{'lastname'}= parse_object(    $racenameparts->{'lastname'}         )->{'content'};
            if ($npc->{'lastname'} ne ''){
                $npc->{'fullname'}=$npc->{'lastname'};
            }
        }
        if ( defined $npc->{'firstname'} and defined $npc->{'lastname'} and $npc->{'firstname'} ne '' and $npc->{'lastname'} ne '' ){
            $npc->{'fullname'}=$npc->{'firstname'} ." ". $npc->{'lastname'};
        }
    }else{
        $npc->{'fullname'}="unnamed $race";
    }
    return $npc->{'fullname'};
}

###############################################################################

=head2 generate_npc_names( race, count )

Return a list of count names from the given race.

=cut

###############################################################################

sub generate_npc_names{
    my($race,$count)=@_;

    if (!  grep( /^$race$/, @{ get_races()} ) ) {
        $race='any';
    }

    if (defined $count and  $count=~/(\d+)/){
        $count= $1;
    }else{
        $count=10;
    }

    my @names;
    for (my $i=0 ; $i < $count ; $i++){
        set_seed($GenericGenerator::seed+$i);
        push @names, generate_npc_name($race);

    }
    return \@names;
}   

1;

__END__


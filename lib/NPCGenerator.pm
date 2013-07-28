#!/usr/bin/perl -wT
###############################################################################

package NPCGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( generate_npc_names get_races names_data create_npc xml_data generate_npc_name );

#TODO make generate_name method for use with namegenerator
###############################################################################

=head1 NAME

    NPCGenerator - used to generate NPCs

=head1 SYNOPSIS

    use NPCGenerator;
    my $npc=NPCGenerator::create_npc();

=cut

###############################################################################

#TODO treat certain data as stats...
use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item * F<xml/data.xml>

=item * F<xml/npcnames.xml>

=item * F<xml/specialists.xml>

=back

=head1 INTERFACE


=cut

###############################################################################
my $xml_data            = $xml->XMLin( "xml/data.xml",           ForceContent => 1, ForceArray => ['option'] );
my $names_data          = $xml->XMLin( "xml/npcnames.xml",       ForceContent => 1, ForceArray => ['allow'] );
my $specialist_data     = $xml->XMLin( "xml/specialists.xml",    ForceContent => 1, ForceArray => [] );

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
    $npc->{'available_races'}= [ keys %{$names_data->{'race'}}] if (!defined $npc->{'available_races'});

    $npc->{'race'}=rand_from_array( $npc->{'available_races'} ) if (! defined $npc->{'race'});
    $npc->{'race'}=lc $npc->{'race'};
    
    $npc->{'race_article'}=$names_data->{'race'}->{$npc->{'race'}}->{'article'}   ;
    $npc->{'race_plural'}=$names_data->{'race'}->{$npc->{'race'}}->{'plural'}   ;
    
    generate_npc_name($npc->{'race'},$npc);
    $npc->{'skill'}             = roll_from_array( &d(100), $xml_data->{'skill'}->{'level'} )->{'content'};
    $npc->{'behavior'}          = rand_from_array( $xml_data->{'behavioraltraits'}->{'trait'} )->{'type'};
    $npc->{'reputation_scope'}  = rand_from_array( $xml_data->{'area'}->{'scope'} )->{'content'};
    set_attitudes($npc);
    set_sex($npc);
    set_profession($npc);
    return $npc;
}


###############################################################################

=head2 set_level()

Take a provided NPC and set their level.

=cut

###############################################################################

sub set_level{
    my ($npc)=@_;
    my $size_modifier=$npc->{'size_modifier'} || 0;

    $npc->{'level'}=d('3d4')+$size_modifier if (!defined $npc->{'level'})   ;
    #keep levels between 1 and 20.
    $npc->{'level'}=max(1, min(20,$npc->{'level'})  );
    return $npc;
}




###############################################################################

=head2 set_sex()

Take a provided NPC and select a sex from the list of available choices.

=cut

###############################################################################

sub set_sex{
    my ($npc)=@_;
    my $sex=roll_from_array( &d(100),$xml_data->{'sex'}->{'option'}) ;

    $npc->{'sex'}       =$sex->{'content'} if (!defined $npc->{'sex'}) ;
    $npc->{'pronoun'}   =$sex->{'pronoun'} if (!defined $npc->{'pronoun'}) ;
    return $npc;
}


###############################################################################

=head2 set_profession( npc, specialistlist )

Take a provided NPC and select a profession from the list of available choices.

=cut

###############################################################################

sub set_profession{
    my ($npc,@specialist_list)=@_;
    if (scalar(@specialist_list) == 0){
        @specialist_list= keys %{$specialist_data->{'option'}};
    }
    shuffle(@specialist_list);
    my $specialty=pop @specialist_list;
    $npc->{'profession'} = $specialty  if (!defined $npc->{'profession'});
    if (!defined $npc->{'business'} ){
        if  (defined $specialist_data->{'option'}->{$specialty} and defined $specialist_data->{'option'}->{$specialty}->{'building'}){
            $npc->{'business'} =$specialist_data->{'option'}->{$specialty}->{'building'}  ;
        }else{
            $npc->{'business'} = $npc->{'profession'} ;
        }
        if ($npc->{'business'} =~/,/x){
            my @businesses=shuffle( split(/,/x,$npc->{'business'}));
            $npc->{'business'}=pop @businesses;
        }
    }

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
    return $npc;
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
                $npc->{'name'}=$npc->{'firstname'};
            }
        }
        if ( defined $racenameparts->{'lastname'} ){
            $npc->{'lastname'}= parse_object(    $racenameparts->{'lastname'}         )->{'content'};
            if ($npc->{'lastname'} ne ''){
                $npc->{'name'}=$npc->{'lastname'};
            }
        }
        if ( defined $npc->{'firstname'} and defined $npc->{'lastname'} and $npc->{'firstname'} ne '' and $npc->{'lastname'} ne '' ){
            $npc->{'name'}=$npc->{'firstname'} ." ". $npc->{'lastname'};
        }
    }else{
        $npc->{'name'}="unnamed $race";
    }
    return $npc->{'name'};
}

###############################################################################

=head2 generate_npc_names( race, count )

Return a list of count names from the given race.

=cut

###############################################################################

sub generate_npc_names{
    my($race,$count)=@_;

    if (!  grep { /^$race$/x } @{get_races()} ) {
        $race='any';
    }

    if (defined $count and  $count=~/(\d+)/x){
        $count= $1;
    }else{
        $count=10;
    }

    my @names;
    for (my $i=0 ; $i < $count ; $i++){
        GenericGenerator::set_seed(GenericGenerator::get_seed()+$i);
        push @names, generate_npc_name($race);

    }
    return \@names;
}   

1;



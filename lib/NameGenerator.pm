#!/usr/bin/perl -wT
###############################################################################
#
package NameGenerator;


use strict;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( generate_npc_names get_races );


use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = new XML::Simple;

our $names_data = $xml->XMLin( "xml/names.xml", ForceContent => 1, ForceArray => ['allow'] );
our $xml_data = $xml->XMLin( "xml/data.xml", ForceContent => 1, ForceArray => [] );


###############################################################################
#
# generate_npc_name - generate an npc name if they're available for that race
#
###############################################################################

sub get_races{
    return [ sort keys %{ $names_data->{'race'}}];
}


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





sub generate_npc_name{
    my($race)=@_;
    $race= lc $race;



    # Check to see if this is a mutt race like other or any.
    if ( defined $names_data->{'race'}->{ $race} and defined $names_data->{'race'}->{ $race}->{'allow'} ){
        $race= rand_from_array($names_data->{'race'}->{ $race}->{'allow'})->{'content'};
    }
    my $npc;
    print Dumper $race ;
    #print Dumper $names_data->{'race'}->{ $race}  ;
    if (defined $names_data->{'race'}->{ $race}     ){
        my $racenameparts=$names_data->{'race'}->{ $race} ;

        #TODO can we use parse_object here?

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
        $npc->{'noname'}="unnamed $race";
    }


    $npc->{'sex'}= roll_from_array( &d(100),    $xml_data->{'sex'}->{'option'}    );
    return $npc->{'fullname'}."   ($race)";
}


1;

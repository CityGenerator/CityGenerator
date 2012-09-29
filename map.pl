#!/usr/bin/perl -w
use strict;
use CGI;
use Data::Dumper;
use GD;
use List::Util 'shuffle', 'min', 'max' ;
use POSIX;
use XML::Simple;
###################################################
# Using findbin to locate our new City.pm module
use FindBin qw/$Bin/;
BEGIN {
    # A rather useless regex, but whatever. 
    # Who woulda throught checking for taint stinks? :D
    if ($Bin =~ m!([\w\.\-/]+)!) {
        $Bin = $1;
    } else {
        print STDOUT "Bad directory $Bin\n";
    }
}
use lib "$Bin/";
###################################################
use City 'build_city', 'd','rand_from_array', 'rand_from_array' ;

my $xml = new XML::Simple;

###########################################################
# Yes, this is sloppy. I am aware, but it's also unique.
# Unique, Ubiquitous Singletons.
our $q = CGI->new;
our $xml_data = $xml->XMLin(   "../data.xml", ForceContent => 1, ForceArray  =>[]  );
our $names_data = $xml->XMLin(   "../names.xml", ForceContent => 1, ForceArray  =>[]  );

#########################################################################
# First thing we need to do is establish a city skeleton of information,
# then fill it in as needed by each subsection of the sample text.
#########################################################################
our $city=build_city($q->param('cityid'));



if (defined $q->param('debug')) {
print "seed: $city->{'seed'}\n";
}
our $height=500;
our $width=500;

our $img = GD::Image->new($width,$height);
our $palette = {
    # create a new image
    # allocate some colors
    'grass' => $img->colorAllocate(17,83,7),
    'ocean' => $img->colorAllocate(14,43,104),
    'road'  => $img->colorAllocate(66,30,3),
    'wall'  => $img->colorAllocate(97,97,97),
};

&draw_ocean();
my $poly= &select_land_pattern();
&city_size();
&place_city();






if (defined $q->param('debug')) {
    exit;
}
$img->string(GD::gdLargeFont,2,10,"$city->{'seed'}",$palette->{'wall'});
&finish();
exit;

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
sub city_size {


}
sub place_city{


}

sub select_land_pattern{

    my $poly = new GD::Polygon;
    my @sides=('north', 'south', 'east', 'west','northeast' );
    my $side=$q->param('side') ;

    if (! defined $side  or "@sides"!~ /\b$side\b/){
        $side=rand_from_array(\@sides);
    }

    #FIXME coast is currently the only one supported, hence the "or 1"
    if ($city->{'location'}->{'name'} eq "on the coast"  or 1){
        # Set base distances
        my ($xbase, $ybase, $xcur, $ycur, $length)= (0,0,0,0,0);
        my $totaldistance=$width;

        #Determine the total distance that needs to be traveled.
        if ($side eq 'north' || $side eq 'south'){
                $totaldistance=$width;
        }elsif ($side eq 'east' || $side eq 'west'){
                $totaldistance=$height;
        }elsif($side eq 'northeast'){
                $totaldistance=int (sqrt( $height**2 + $width**2) );
        }

        # Determine the starting point for that side
        if ($side eq 'south'){
            $poly->addPt(0,$height);
        } elsif ($side eq 'east'){
            $poly->addPt($width,0);
        }elsif($side eq 'north' || $side eq 'west' || $side eq 'northeast'){
            $poly->addPt(0,0);
        }

        # For "backward" sides, set the base to the opposite of 0
        if ($side eq 'south'){
            $ybase=$height;
        }elsif ($side eq 'east'){
            $xbase=$width;
        }
    
        while ($length < $totaldistance){
            my $lengthmod=  &d(20)-5;
            my $depthmod=   &d(24)-12;

            if ($side eq 'north' || $side eq 'south'){
                $xcur+=$lengthmod;
                $length=$xcur;
            } elsif ($side eq 'east' || $side eq 'west'){
                $ycur+=$lengthmod;
                $length=$ycur;
            } elsif ($side eq 'northeast') {
                $ycur+=&d(20)-5;
                $xcur+=&d(20)-5;
                $length=max($xcur, $ycur);
            }
            if ($side eq 'north'){
                $ycur=max( $ycur+$depthmod, $ybase-50);
            } elsif ($side eq 'south'){
                $ycur=min( $ycur+$depthmod, $height);
            } elsif ($side eq 'east'){
                $xcur=min( $xcur+$depthmod, $width);
            } elsif ($side eq 'west'){
                $xcur=max( $xcur+$depthmod, $xbase-50);
            } elsif ($side eq 'northeast'){
                $ycur=max( $ycur+$depthmod, $ybase-50);
                $xcur=max( $xcur+$depthmod, $xbase-50);
        
            }
            if (defined $q->param('debug')  ){
            }
            $poly->addPt($xbase+$xcur,$ybase+$ycur);
        }
        
        if ($side eq 'north'){
            $poly->addPt($width,$height);
            $poly->addPt(0,$height);
            $poly->offset(0,100);
        } elsif ($side eq 'south'){
            $poly->addPt($width,0);
            $poly->addPt(0,0);
            $poly->offset(0,-100);
        } elsif ($side eq 'east'){
            $poly->addPt(0,$height);
            $poly->addPt(0,0);
            $poly->offset(-100,0);
        } elsif ($side eq 'west'){
            $poly->addPt($width,$height);
            $poly->addPt($width,0);
            $poly->offset(100,0);
        } elsif ($side eq 'northeast'){
            $poly->addPt($width,$height+50);
            $poly->addPt(-50,$height+50);
            $poly->addPt(-50,-50);
            $poly->offset(50,-50);
        }
        
    
  }

  print Dumper $poly if (defined $q->param('debug')  );

  $img->filledPolygon($poly,$palette->{'grass'});
 return $poly;
}


sub draw_ocean(){
    $img->filledRectangle( 0, 0, $width, $height, $palette->{'ocean'} );
}

sub finish {
    # make sure we are writing to a binary stream
    $img->interlaced( 'true' );
    binmode STDOUT;
    print $q->header( 'image/png' );
    # Convert the image to PNG and print it on standard output
    print $img->png;
}


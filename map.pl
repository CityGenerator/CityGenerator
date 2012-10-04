#!/usr/bin/perl -w
use strict;
use CGI;
use Data::Dumper;
use GD::Polyline;
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

#########################################################################
# First thing we need to do is establish a city skeleton of information,
# then fill it in as needed by each subsection of the sample text.
#########################################################################
our $city=build_city($q->param('cityid'));
# TODO use towers to determine the number of vertices and wall length to
# determine how big to make the city
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
if (defined $q->param('debug')) {
    print "seed: $city->{'seed'}\n";
}

# Lets set our primary width and height. 
my $height=300;
my $width=300;

my $img     = GD::Image->new($width,$height,24);
my $palette = create_palette($img);


my $ocean   = &generate_ocean( $width, $height );
my $land    = &generate_land( $width, $height );
my $hills   = &generate_hills( $width, $height);
my $cityarea= &generate_city( $land, $width, $height);
my $roads   = &generate_roads( $cityarea, $width, $height  );

$cityarea= &set_direction($cityarea,$width,$height);



$img->filledPolygon( $ocean,                    $palette->{'ocean'} );
$img->filledPolygon( $land,                     $palette->{'grass'});
#$img->copy($hills,0,0,  0,0,$width,$height);
$img->filledPolygon($cityarea,                  $palette->{'extcity'});


my $mainroadcount=$city->{'streets'}->{'mainroads'};
#$img->setAntiAliased($palette->{'road'});
foreach my $road (@$roads){
    if ($mainroadcount-- >0){
        $img->setThickness( int  ($city->{'size_modifier'}+6)/3 );
    }else{
        $img->setThickness(1);
    }
    $img->polyline($road,  $palette->{'road'}    );
}


if  ($city->{'walls'}->{'content'} ne 'none' ){
    my $pct=$city->{'walls'}->{'protectedpercent'} ;
    $cityarea->scale( $pct/100,$pct/100, $cityarea->centroid  );

    for (my $index =0 ; $index < $cityarea->length; $index++ ){
        if ($index%4 !=1){
            $cityarea->deletePt($index);
        }
    }
}

$img->filledPolygon($cityarea,      $palette->{'cityproper'});

if  ($city->{'walls'}->{'content'} ne 'none' ){

    $img->setThickness( int  ($city->{'size_modifier'}+6)/3  );
    $img->openPolygon($cityarea,           $palette->{'wall'});
}


&testinfo($img,$palette);
&finish($img);
exit;

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################

sub generate_hills{
    my ($width,$height)=@_;
    my $hills    = GD::Image->new($width,$height);
    $img->interlaced( 'true' );
    $hills->string(GD::gdSmallFont,2,10,"Peachy Keen",$palette->{'test'});    
    return $hills;
}







sub city_size {
    my ($width,$height)=@_;
    #range from 50px to 220;
    my $basediameter=$width/4+$city->{'size_modifier'}*$width/60;
    return $basediameter;
}



sub plot_rectangle{
    my ($pointtotal,$width,$height, $center,$cityarea,$isrect) =@_ ;
    my $pointcount=0;
    my $origin=$center;
    while($pointcount++ < $pointtotal){
        my $majorjitter=int (d($width/100)-2+$width/100);
        my $minorjitter=int (d($width/100)-2);
        if ($pointcount < $pointtotal*1/4){
            $center->[0]+=   $majorjitter;
            $center->[1]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*2/4){
            $center->[1]+=   $majorjitter*$isrect;
            $center->[0]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*3/4){
            $center->[0]+= - $majorjitter;
            $center->[1]+= - $minorjitter;
        }elsif($pointcount < $pointtotal){
            $center->[1]+= - $majorjitter*$isrect;
            $center->[0]+= - $minorjitter;
        }else{
            $center= $origin ;
        }
        $cityarea->addPt(@$center);
    }
    return $cityarea;
}
sub plot_hexagon{
    my ($pointtotal,$width,$height, $center,$cityarea) =@_ ;
    my $pointcount=0;
    my $origin=$center;
    while($pointcount++ < $pointtotal){
        my $majorXjitter=int $width/100  +  d($width/100)-2;
        my $majorYjitter=int $width/100  +  d($width/100)-2;
        my $minorjitter=int (d($width/100)-2);
        if ($pointcount < $pointtotal*1/6){
            $center->[0]+=   $majorXjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*2/6){
            $center->[1]+=   $majorYjitter;
            $center->[0]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*3/6){
            $center->[0]+= - $majorXjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*4/6){
            $center->[0]+= - $majorXjitter;
            $center->[1]+= - $majorYjitter;
        }elsif($pointcount < $pointtotal*5/6){
            $center->[1]+= - $majorYjitter;
            $center->[0]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*6/6){
            $center->[1]+= - $majorYjitter;
            $center->[0]+=   $majorXjitter;
        }else{
            $center= $origin ;
        }
        $cityarea->addPt(@$center);
    }
    return $cityarea;
}
sub plot_octagonal{
    my ($pointtotal,$width,$height, $center,$cityarea) =@_ ;
    my $pointcount=0;
    my $origin=$center;
    while($pointcount++ < $pointtotal){
        my $majorXjitter=int $width/100  +  d($width/180)-1;
        my $majorYjitter=int $width/100  +  d($width/180)-1;
#        $majorYjitter=$majorXjitter=3;
        my $minorjitter=int (d($width/150)-1);
        if ($pointcount < $pointtotal*1/8){
            $center->[0]+=   $majorXjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*2/8){
            $center->[0]+=   $minorjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*3/8){
            $center->[0]+= - $majorXjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*4/8){
            $center->[0]+= - $majorXjitter;
            $center->[1]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*5/8){
            $center->[0]+= - $majorXjitter;
            $center->[1]+= - $majorYjitter;
        }elsif($pointcount < $pointtotal*6/8){
            $center->[0]+=   $minorjitter;
            $center->[1]+= - $majorYjitter;
        }elsif($pointcount < $pointtotal*7/8){
            $center->[0]+=   $majorXjitter;
            $center->[1]+= - $majorYjitter;
        }elsif($pointcount < $pointtotal*8/8){
            $center->[0]+=   $majorXjitter;
            $center->[1]+=   $minorjitter;
        }else{
            $center= $origin ;
        }
        $cityarea->addPt(@$center);
    }
    return $cityarea;
}

sub plot_circular{
    my ($pointtotal,$width,$height, $center,$size,$cityarea)=@_ ;
    my $pointcount=0;
    $center->[0]=int $center->[0];
    my $offset= int(  $size/2 -($width/50) + d($width/50)*10  );
    $center->[1]= $center->[1]+ $offset ;
    while($pointcount < $pointtotal){
        my $jitterx=d($width/25)-$width/50;
        my $jittery=d($width/25)-$width/50;
        my $length= $size/2 ;
        $cityarea->addPt( $center->[0] + $jitterx  ,      $center->[1] + $length  +  $jittery   )     ;
        $cityarea->rotate( 3.14159*2/$pointtotal , @$center);
        $pointcount++;
    }
    return $cityarea;
}
sub generate_city{
    my ($land,$width,$height)=@_;
    my $size=&city_size($width,$height);
    my $cityarea = new GD::Polyline;
    
    my $pointtotal=int( $size/2 + $city->{'size_modifier'});
    print "Total is $pointtotal "if (defined $q->param('debug')  );
    # if polysize > 4, there is a body of water.
    print "size: $size\n" if (defined $q->param('debug')  );

    my $center=[$width/2,$height/2];
    if ($land->length>4){
        $center=[$land->getPt($land->length/2-2) ]  ;
    }
    if ( $city->{'shape'} eq "a square" ){
        $cityarea=plot_rectangle($pointtotal,$width,$height, $center,$cityarea,1 ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 
    }elsif ( $city->{'shape'} eq "a rectangular" ){
        $cityarea=plot_rectangle($pointtotal,$width,$height, $center,$cityarea,2 ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 
    }elsif ( $city->{'shape'} eq "a hexagonal" ){
        $cityarea=plot_hexagon($pointtotal,$width,$height, $center,$cityarea ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 
    }elsif ( $city->{'shape'} eq "a octagonal" ){
        $cityarea=plot_octagonal($pointtotal,$width,$height, $center,$cityarea ) ;
    }elsif ( $city->{'shape'} eq "an oval" ){
        $cityarea=plot_circular($pointtotal,$width,$height, $center,$size,$cityarea ) ;
        $cityarea->scale(1.3,.8, @$center);
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid());
 
    #circular is currently the default
    }else{
        $cityarea=plot_circular($pointtotal,$width,$height, $center,$size,$cityarea ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 

    }

    for (my $index =0 ; $index < $cityarea->length; $index++ ){
        if ($index%2 !=1){
            $cityarea->deletePt($index);
        }
    }

   # Grow it a little bit.
   $cityarea->scale(1.2, 1.2, $cityarea->centroid())  ;



   return $cityarea;

}


sub generate_roads{
    my ($cityarea,$width,$height)=@_;
    my $roadcount=$city->{'streets'}->{'roads'};
    my $roads=[];
    my $rotation=0;
    while ($roadcount-- >0 ){
        my $road=draw_road( $cityarea,$width,$height  );
        my $twist=3.14159*(d(101)-1)/50;
        my $rotationrange=2;

        if ($city->{'location'}->{'name'} eq "on the coast" ){
            $rotationrange=1;
        }

        $rotation=$rotationrange/$city->{'streets'}->{'roads'}*$roadcount +1/20 ;
        $twist=3.14159*$rotation ;
        $road->rotate($twist,$cityarea->centroid()) ;
        $road=&set_direction($road,$width,$height);
        push @$roads, $road;
    }

    return $roads;
}

sub draw_road{
    my ($cityarea,$width,$height)=@_;
    my $road = new GD::Polyline;


    $road->addPt( $cityarea->centroid());
    my $length=0;
    my $upperBound=$width/5;
    my $lowerBound=-$width/10;
    my $cursor=[$cityarea->centroid()];
    while ($length <$width){
        my $lengthmod=  &d(20)-2;
        my $depthmod=   &d(6)-3;
        $cursor->[0]+=$lengthmod;
        $cursor->[1]+=$depthmod;

        if ($city->{'location'}->{'name'} eq "on the coast" ){
            $cursor->[1]=  max( $cursor->[1] ,$upperBound);
        }

        $road->addPt( @$cursor);
#print "$length  $width \n";
        $length+=$lengthmod;
    }


    return $road;
}

sub generate_land{
    my ($width,$height)=@_;
    my $doublewidth=$width*2;
    my $doubleheight=$height*2;
    my $lowerBound=$doublewidth/5;
    my $upperBound=-$doublewidth/10;
    my $land = new GD::Polyline;

    #FIXME coast is currently the only one supported, hence the "or 1"
    if ($city->{'location'}->{'name'} eq "on the coast" ){
        # Set base distances
        my ( $xcur, $ycur, $length)= (0,0,0);
        my $totaldistance=$doublewidth;

        #Determine the total distance that needs to be traveled.
        $totaldistance=$doublewidth;
        $land->addPt(0,0);
        while ($length < $totaldistance){
            my $lengthmod=  &d(20)-5;
            my $depthmod=   &d(24)-12;
            $xcur+=$lengthmod;
            $ycur=$ycur+$depthmod;
            $length=$xcur;

            #Ensure the coast stays between the bounds.
            $ycur=min( $lowerBound,  max( $ycur,$upperBound));

            $land->addPt($xcur,$ycur);
        }
        $land->addPt($doublewidth,$doubleheight);
        $land->addPt(0,$doubleheight);
        $land->offset(-$doublewidth/4,($doublewidth/5));
    }else{
        $land->addPt(0,0);
        $land->addPt($doublewidth,0);
        $land->addPt($doublewidth,$doubleheight);
        $land->addPt(0,$doubleheight);
        $land->offset(-$doublewidth/4,-$doubleheight/4);
    
    }

    $land   = &set_direction($land,$width,$height);

    return $land;

}


###############################################################################
#
# set_direction - Twist a given layer/image/polygon to the proper direction.
#
###############################################################################


sub set_direction{
    my ($layer,$width,$height)=@_;
    $width=$width/2;
    $height=$height/2;

    my $side=$q->param('side')||$city->{'location'}->{'coastdirection'} ;
    if ($side eq 'north'){

    }elsif($side eq 'northeast'){
        $layer->rotate(3.14159/4,$width,$height) ;

    }elsif($side eq 'east'){
        $layer->rotate(3.14159/2,$width,$height) ;

    }elsif($side eq 'southeast'){
        $layer->rotate(3.14159*3/4,$width,$height) ;

    }elsif($side eq 'south'){
        $layer->rotate(3.14159,$width,$height) ;

    }elsif($side eq 'southwest'){
        $layer->rotate(3.14159*5/4,$width,$height) ;

    }elsif($side eq 'west'){
        $layer->rotate(3.14159*3/2,$width,$height) ;

    }elsif($side eq 'northwest'){
        $layer->rotate(3.14159*7/4,$width,$height) ;
    }
    return $layer;
}


###############################################################################
#
# finish - The final steps needed to print out the image.
#
###############################################################################

sub finish {
    my ($img)=@_;

    #If we're debugging, exit without printing to the screen
    if (defined $q->param('debug')) {
        exit;
    }
    # make sure we are writing to a binary stream
    $img->interlaced( 'true' );
    binmode STDOUT;
    print $q->header( 'image/png' );
    # Convert the image to PNG and print it on standard output
    print $img->png;
}
###############################################################################
#
# create_palette - a list of all the colors we plan on using.
#
###############################################################################

sub create_palette{
    my ($img)=@_;
    my $palette= {
    # create a new image
    # allocate some colors
    'grass'     => $img->colorAllocateAlpha(17,83,7,0),
    'ocean'     => $img->colorAllocateAlpha(14,43,104,0),
    'road'      => $img->colorAllocateAlpha(66,30,3,0),
    'test'      => $img->colorAllocateAlpha(110,110,3,0),
    'cityproper'=> $img->colorAllocateAlpha(97,97,97,0),
    'extcity'   => $img->colorAllocateAlpha(120,120,120,64),
    'wall'      => $img->colorAllocateAlpha(50,50,50,0),
    'text'      => $img->colorAllocateAlpha(0,0,0,0),
    };
    foreach my $key (keys %{$palette} ){
        $img->setAntiAliased($palette->{$key});
    }
    return $palette;
}


###############################################################################
#
# testinfo - If we're testing at the browser, write stats on the image.
#
###############################################################################

sub testinfo{
    my ($width,$height)=@_;
    if (defined $q->param('test')) {
        $img->string(GD::gdLargeFont,2,10,"Name:$city->{'name'} ($city->{'seed'}) ",$palette->{'text'});
        $img->string(GD::gdLargeFont,2,25,"Pop:$city->{'population'}->{'size'} diameter: $city->{'citydiameter'}",$palette->{'text'});
        $img->string(GD::gdLargeFont,2,40,"Roads:$city->{'streets'}->{'roads'} ($city->{'streets'}->{'mainroads'} main)",$palette->{'text'});
        $img->string(GD::gdLargeFont,2,55,"houses:$city->{'housing'}->{'total'}, business: $city->{'businesstotal'}",$palette->{'text'});
        $img->string(GD::gdLargeFont,2,70,"side:$city->{'location'}->{'coastdirection'}, area: $city->{'location'}->{'name'} ",$palette->{'text'});
        $img->string(GD::gdLargeFont,2,85,"shape: $city->{'shape'} protected: $city->{'walls'}->{'protectedpercent'} ",$palette->{'text'});
    }
}


###############################################################################
#
# generate_ocean - draw a simple blue square
#
###############################################################################

sub generate_ocean{
    my ($width,$height)=@_;
    my $ocean = new GD::Polyline;
        $ocean->addPt(0,0);
        $ocean->addPt($width,0);
        $ocean->addPt($width,$height);
        $ocean->addPt(0,$height);
        $ocean->offset(-$width/4,-$height/4);

    return $ocean;
}

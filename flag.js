
// comments? bwahahahah.
// wait, you're serious? let me laugh harder- BWWWWWAAAAAAAAHAHAHAHAHAHA

function create_flag(seed,colorlist) {
    Math.seedrandom(seed);


    var canvas=document.getElementById('flagcanvas');
    var flag=canvas.getContext('2d');

    //This is the flag's colorscheme; at most it'll have a 3 color background
    //var colorlist = select_5_colors();

    // Set the base size of the flag; height will 
    // always be 100, but width may change.
    var ratio=set_ratio( flag );
    var height=100;
    var width=height*ratio;

    //FIXME note that I'm overriding the ratios for now.
//    width=150;
//    height=100;
    flag=set_shape(flag, width, height);
    flag.clip();
    
    // flags have 4 parts; the division, the overlay
    // a symbol, and a border.
    flag=select_division(flag, width, height, colorlist );
    flag=select_overlay( flag, width, height, colorlist );
    flag=select_symbol(  flag, width, height, colorlist );
    flag=select_border(  flag, width, height, colorlist );
}

function set_shape(flag, width, height){
    var shape = getQueryString()['shape'];
    var chance=shape || d( 300 ); 
    if  (chance <5 || shape == 'para'){
        flag.moveTo(    0,        0);
        flag.lineTo(    width,    height/6);
        flag.lineTo(    width,    height-height/6);
        flag.lineTo(    0,        height);
    }else if  (chance <20 || shape == 'tri'){
        flag.moveTo(    0,        0);
        flag.lineTo(    width,    height/2);
        flag.lineTo(    0,        height);
    }else if  (chance <25 || shape == 'pennant'){
        flag.moveTo(    0,        0);
        flag.lineTo(    width,    height/5*2);
        flag.lineTo(    width,    height/5*3);
        flag.lineTo(    0,        height);
    }else if  (chance <40 || shape == 'swallow'){
        flag.moveTo(    0,                0);
        flag.lineTo(    width,            height/3*1);
        flag.lineTo(    width-width/5,    height/2);
        flag.lineTo(    width,            height/3*2);
        flag.lineTo(    0,                height);
    }else if  (chance <45 || shape == 'tongued'){
        flag.moveTo(    0,                0);
        flag.lineTo(    width,            0);
        flag.lineTo(    width,            height/11*1);
        flag.lineTo(    width-width/11,   height/11*1);
        flag.lineTo(    width-width/11,   height/11*2);

        flag.lineTo(    width,            height/11*2);
        flag.lineTo(    width,            height/11*3);
        flag.lineTo(    width-width/11,   height/11*3);
        flag.lineTo(    width-width/11,   height/11*4);

        flag.lineTo(    width,            height/11*4);
        flag.lineTo(    width,            height/11*5);
        flag.lineTo(    width-width/11,   height/11*5);
        flag.lineTo(    width-width/11,   height/11*6);

        flag.lineTo(    width,            height/11*6);
        flag.lineTo(    width,            height/11*7);
        flag.lineTo(    width-width/11,   height/11*7);
        flag.lineTo(    width-width/11,   height/11*8);

        flag.lineTo(    width,            height/11*8);
        flag.lineTo(    width,            height/11*9);
        flag.lineTo(    width-width/11,   height/11*9);
        flag.lineTo(    width-width/11,   height/11*10);

        flag.lineTo(    width,            height/11*10);
        flag.lineTo(    width,            height);
        flag.lineTo(    0,                height);
    }else{
        flag.rect(0,0,width,height);

    }
        flag.fill()
    return flag;
}

// Division should only use colors 0,1 and 2 at most.
function select_division( flag, width, height, colorlist){

    // by making chance possibly a text string, it should become larger than
    // usable and force division to work. kudgy, but functional.
    var division = getQueryString()['division'];
    var chance=division || d( 70 );

    var flag = draw_solid( flag, width, height, colorlist[0] );

    if        (chance <10 || division == 'quads'){
        flag = draw_quads( flag, width, height, colorlist );

    } else if (chance <20 || division == 'diagquad' ){
        flag = draw_quaddiagonals( flag, width, height, colorlist );

    } else if (chance <35 || division == 'diag1'){
        flag = draw_diagonals( flag, width, height, undefined, colorlist );

    } else if (chance <55 || division == 'vert' || division == 'hor' ){
        flag = draw_stripes( flag, width, height, division, undefined, colorlist );

    } else{/*nothing, just the base.*/}

    return flag;
}

// overlay should use colors 3 
function select_overlay(flag,width,height, colorlist){

    var overlay=getQueryString()['overlay'];
    var chance=overlay || d( 150 ) ; 

    if        (chance <10 || overlay=='quaddiag'){
        flag= draw_quaddiagonal(flag, width, height, d( 4 ), colorlist[3] );

    } else if (chance <20 || overlay=='quad'){
        flag= draw_quad(flag, width, height, 1, colorlist[3]);

    } else if (chance <30 || overlay=='stripe'){
        flag= draw_stripe(flag,width, height, undefined, undefined, undefined, colorlist[3]);

    } else if (chance <40 || overlay=='jack'){
        flag= draw_jack(flag,width,height,colorlist[3]);
        flag= draw_jack(flag,width,height,colorlist[2]);

    } else if (chance <50 || overlay=='asterisk'){
        flag= draw_asterisk(flag,width,height,colorlist[3]);
        flag= draw_asterisk(flag,width,height,colorlist[2]);

    } else if (chance <60 || overlay=='x'){
        flag= draw_x(flag,width,height, undefined,colorlist[3]);
        flag= draw_x(flag,width,height, undefined,colorlist[2]);

    } else if (chance <70 || overlay=='cross'){
        flag= draw_cross(flag, width, height, undefined, undefined, undefined, undefined, colorlist[3]);

    } else if (chance <80 || overlay=='diamond'){
        flag= draw_diamond(flag,width,height,colorlist[3]);

    } else if (chance <90 || overlay=='circle'){
        flag=draw_circle(flag,  width, height, 1/2, 1/2, undefined, colorlist[3] );

    } else if (chance <100 || overlay == 'rays'){
        flag = draw_rays( flag, width, height, undefined,undefined,undefined, undefined, colorlist[3] );


    } else{ /* 10% chance of getting nothing! */}
    return flag;
}

function draw_asterisk(flag, width,height,color){
        flag= draw_stripe(flag, width, height, undefined, 5, 3, color);
        flag= draw_x(flag, width, height, undefined, color);
        return flag;
}
function draw_jack(flag, width,height,color){
        flag= draw_cross(flag, width, height, undefined, 1/2, undefined, 1/2, color);
        flag= draw_x(flag,width,height,undefined,color);
        return flag;
}
function select_symbol(flag, width, height, colorlist){
    var symbol = getQueryString()['symbol'];
    var chance= symbol|| d( 60 )  ; 

    if (chance <10 || symbol=='circle'){
        flag=draw_circle(flag,  width, height, undefined, undefined, undefined, colorlist[4] );
    } else if (chance <20 || symbol=='star'){
        flag= draw_star(flag, width, height, undefined, undefined, colorlist[4]);
    }
    return flag;
}


function select_border(flag, width, height, colorlist){
    var border=getQueryString()['border'];
    var chance=border||  d( 30 )  ;
 
    if (chance < 10 || border == 'true'){
        flag=draw_border( flag, width, height, undefined, colorlist  );
    }
    return flag;
}
function draw_solid(flag, width, height, color){
        flag.fillStyle=color||random_color();
        flag.fillRect(0,0, width,height); 
        return flag;

}


function draw_slash(flag, width,height,linesize,direction,color){

    var linesizes=Array(1/6, 1/8, 1/9, 1/10, 1/12, 1/15, 1/20);
    linesize =linesize||linesizes[ d( linesizes.length ) ] ;

    var directions=Array('left','right');
    direction = direction||directions[ d( directions.length ) ] ;
    flag.beginPath();

    var linewidth=linesize*width;
    var lineheight=linesize*height;

    if (direction =='left'){
        flag.moveTo(    0,                      0);
        flag.lineTo(    linewidth,              0);
        flag.lineTo(    width,                  height-lineheight);
        flag.lineTo(    width,                  height);
        flag.lineTo(    width-linewidth,        height);
        flag.lineTo(    0,                      lineheight);
    }else{
        flag.moveTo(    width-linewidth,        0);
        flag.lineTo(    width,                  0);
        flag.lineTo(    width,                  lineheight);
        flag.lineTo(    linewidth,              height);
        flag.lineTo(    0,                      height);
        flag.lineTo(    0,                      height-lineheight);
    }
    flag.fillStyle=color||random_color();
    flag.fill();
    return flag;
}



function draw_x(flag, width, height, thickness, color){
    var linewidths=Array( 1/6, 1/8, 1/9, 1/10, 1/12, 1/15, 1/20);
    thickness = thickness|| linewidths[ d( linewidths.length ) ] ;
    flag=draw_slash(flag,width,height,thickness,'left',color);
    flag=draw_slash(flag,width,height,thickness,'right',color);
    return flag;
}
function draw_cross(flag, width, height, vlinewidth, vlinecenter, hlinewidth, hlinecenter, color){
    flag.fillStyle=color||random_color();

    //var linewidths=Array(1/6,1/4);
    var linewidths=Array( 1/6, 1/8, 1/9, 1/10, 1/12, 1/15, 1/20);
    var linecenters=Array(1/6, 1/4, 1/3, 1/2, 2/3, 3/4, 5/6  );

    vlinewidth  =(vlinewidth || linewidths[ d( linewidths.length )])*width ;
    vlinecenter =(vlinecenter || linecenters[d( linecenters.length )])*width;
    flag.fillRect( vlinecenter-(vlinewidth/2), 0 , vlinewidth,  height );

    hlinewidth  = (hlinewidth||  linewidths[ d(linewidths.length  )])*width ;
    hlinecenter = (hlinecenter|| linecenters[d(linecenters.length )])*height;
    flag.fillRect( 0,hlinecenter-(hlinewidth/2) , width,  hlinewidth );
    return flag;
}



function draw_border(flag, width, height, thickness,colorlist){
    thickness=thickness|| d(10)+2 ;
    var color=colorlist[2] ||random_color();
    flag.beginPath();
    flag.lineWidth=thickness;
    flag.moveTo(0+thickness/2,0+thickness/2);
    flag.lineTo(width-thickness/2,0+thickness/2);
    flag.lineTo(width-thickness/2,height-thickness/2);
    flag.lineTo(0+thickness/2,height-thickness/2);
    flag.lineTo(0+thickness/2,0);
    flag.strokeStyle=color;
    flag.stroke();
    return flag;

}


function draw_rays(  flag, width, height, x, y, count, offset, color ){
    var raycounts=Array(8,9,15 );
    var offsets=Array(0, 1/8, 1/16, 1/4, 1/3, 1/2, 2/3  );
    var axisoffsets=Array(0, 1/8, 1/16, 1/4, 1/3, 1/2, 2/3, 1  );

    // X and Y are the center of the burst
    x=(x||axisoffsets[d(axisoffsets.length)]) * width;
    y=(y||axisoffsets[d(axisoffsets.length)]) * height;

    //count is how many rays
    count=count ||raycounts[d(raycounts.length)];
    // how far from the center they start
    offset=offset ||offsets[d(offsets.length)];

    var angle=360/count;

    flag.fillStyle=color||random_color();
    flag.translate(x,y);
    while (count-- >0){
        flag.beginPath();
        flag.moveTo(0,-offset*width/2);
        flag.lineTo(0,-width*1.5);
        flag.rotate(angle/2 * Math.PI/180);
        flag.lineTo(0,-width*1.5);
        flag.lineTo(0,-offset*width/2);

        flag.closePath();
        flag.fill();
        flag.rotate(angle/2 * Math.PI/180);
    }
    flag.translate(-x,-y);
    return flag;
}


//canvas, x of center, y of center, radius, number of points, fraction of radius for inset).
function draw_star(flag, width, height, points,inset,color) {

    var pointcounts=Array( 4, 5, 6, 8, 12, 20 );
    var insetlist=Array( 1/4, 1/3, 1/2 );

    points = points|| pointcounts[ d( pointcounts.length ) ] ;
    inset  = inset || insetlist[   d( insetlist.length ) ];


    var xaxis=Array( 1/4, 1/2, 3/4 );
    var yaxis=Array( 1/4, 1/2  );
    
    xaxis = xaxis[d( xaxis.length )] ;
    yaxis = yaxis[d( yaxis.length )] ;
    var radius=Math.min( width*xaxis, width*(1-xaxis),height*yaxis, height*(1-yaxis) );

    flag.fillStyle=color||random_color();
    flag.beginPath();
    flag.translate(width*xaxis, height*yaxis);
    flag.moveTo(0,0-radius);
    for (var i = 0; i < points; i++) {
        flag.rotate(Math.PI / points);
        flag.lineTo(0, 0 - (radius*inset));
        flag.rotate(Math.PI / points);
        flag.lineTo(0, 0 - radius);
    }
    flag.fill();
    flag.translate(-width*xaxis,- height*yaxis);
    return flag;
}


function draw_diamond(flag, width, height, color){
    flag.beginPath();
    flag.moveTo(width/2,0);
    flag.lineTo(width,height/2);
    flag.lineTo(width/2,height);
    flag.lineTo(0,height/2);
    flag.fillStyle=color||random_color();
    flag.fill();
    return flag;

}
    //   condensed awesomeness  http://davidbau.com/archives/2010/01/30/random_seeds_coded_hints_and_quintillions.html
    // allows for seeding of random. it's random enough, STFU. 
    (function(j,i,g,m,k,n,o){function q(b){var e,f,a=this,c=b.length,d=0,h=a.i=a.j=a.m=0;a.S=[];a.c=[];for(c||(b=[c++]);d<g;)a.S[d]=d++;for(d=0;d<g;d++)e=a.S[d],h=h+e+b[d%c]&g-1,f=a.S[h],a.S[d]=f,a.S[h]=e;a.g=function(b){var c=a.S,d=a.i+1&g-1,e=c[d],f=a.j+e&g-1,h=c[f];c[d]=h;c[f]=e;for(var i=c[e+h&g-1];--b;)d=d+1&g-1,e=c[d],f=f+e&g-1,h=c[f],c[d]=h,c[f]=e,i=i*g+c[e+h&g-1];a.i=d;a.j=f;return i};a.g(g)}function p(b,e,f,a,c){f=[];c=typeof b;if(e&&c=="object")for(a in b)if(a.indexOf("S")<5)try{f.push(p(b[a],e-1))}catch(d){}return f.length?f:b+(c!="string"?"\0":"")}function l(b,e,f,a){b+="";for(a=f=0;a<b.length;a++){var c=e,d=a&g-1,h=(f^=e[a&g-1]*19)+b.charCodeAt(a);c[d]=h&g-1}b="";for(a in e)b+=String.fromCharCode(e[a]);return b}i.seedrandom=function(b,e){var f=[],a;b=l(p(e?[b,j]:arguments.length?b:[(new Date).getTime(),j,window],3),f);a=new q(f);l(a.S,j);i.random=function(){for(var c=a.g(m),d=o,b=0;c<k;)c=(c+b)*g,d*=g,b=a.g(1);for(;c>=n;)c/=2,d/=2,b>>>=1;return(c+b)/d};return b};o=i.pow(g,m);k=i.pow(2,k);n=k*2;l(i.random(),j)})([],Math,256,6,52);
//==================================================================


function draw_circle(flag, width, height,x, y, radius, color){
    var xaxis=Array(  1/4, 1/2 );
    var radiusmultipliers=Array( 1/2, 3/4, 1 );
    var radiusmultiplier= radiusmultipliers[d( radiusmultipliers.length)];

    x= x || xaxis[d(xaxis.length)];
//    y= y || xaxis[d(xaxis.length)];

    radius=radius||(Math.min( width*(x) , height*(y), width*(1-x) , height*(1-y)  )-10)*radiusmultiplier;

    flag.beginPath(); // Start the path
    flag.arc(width*x,height*y, radius, 0, Math.PI*2, false ); // Draw a circle
    flag.closePath(); // Close the path
    flag.fillStyle=color||random_color();
    flag.fill(); // Fill the path
    return flag;

}

function draw_stripes(flag,width, height, type,stripecount,colorlist){
    var stripecounts=Array(2, 3, 5, 9, 13);
    stripecount = stripecount||stripecounts[d( stripecounts.length )]; 

    types=Array('hor','vert');
    type=type||types[d( types.length)];

    var loop=stripecount;
    var mod=2;
    // if we have 3 stripes, we want 3 colors, otherwise 2 is enough.
    if (stripecount==3){
        mod=3
    }
    while (loop >0){
        flag=draw_stripe(flag, width, height, type, stripecount, loop, colorlist[loop%mod]);
        loop--;
    }
    return flag;
}


function draw_stripe(flag, width, height, type, count, order, color){
    var counts=Array(2, 3, 5, 9, 13);
    var types=Array('hor','vert');
    count = count||counts[Math.floor ( Math.random() * counts.length )];
    order = order||Math.floor ( Math.random() *count );
    type=type||types[ d( types.length)];

    flag.fillStyle=color||random_color();

    if (type=='hor'){
        flag.fillRect(0,Math.floor(height/count*(order-1)),width, Math.ceil(height/count) );
    }else if (type=='vert'){
        flag.fillRect(Math.floor(width/count*(order-1)),  0,Math.ceil(width/count), height );
    }
    return flag;
}


function draw_quad(flag, width, height, quad, color){
    var a=0,b=0,c=width/2, d=height/2;
    if (quad == 2 || quad == 4 ){
        a=width/2;
    }
    if (quad == 3 || quad == 4 ){
        b=height/2;
    }
    flag.fillStyle=color||random_color();
    flag.fillRect( a, b, c, d );
    return flag;
}


function draw_quads(flag,width,height,colorlist){

    flag=draw_quad(flag, width, height, 1,colorlist[0]);
    flag=draw_quad(flag, width, height, 2,colorlist[1]);
    flag=draw_quad(flag, width, height, 3,colorlist[1]);
    flag=draw_quad(flag, width, height, 4,colorlist[0]);
    return flag
}


function draw_quaddiagonals(flag, width, height, colorlist){
    flag=draw_quaddiagonal(flag, width, height, 1, colorlist[0]);
    flag=draw_quaddiagonal(flag, width, height, 2, colorlist[1]);
    flag=draw_quaddiagonal(flag, width, height, 3, colorlist[0]);
    flag=draw_quaddiagonal(flag, width, height, 4, colorlist[1]);
    return flag
}
function draw_quaddiagonal(flag, width, height, side, color){
    var a=0, b=0, c=0,d=0;
    if (side==2 ){a=width}
    if (side==3 ){b=height}
    if (side==1 || side==2 ||side==3){c=width}
    if (side==2 || side==3 ||side==4){d=height}

    flag.beginPath();
    flag.moveTo(a,b);
    flag.lineTo(c,d);
    flag.lineTo(width/2,height/2);
    flag.fillStyle=color||random_color();
    flag.fill();
    return flag;
}



function draw_diagonal(flag, point1, point2, point3,color ){
    flag.beginPath();
    flag.moveTo(point1[0],point1[1]);
    flag.lineTo(point2[0],point2[1]);
    flag.lineTo(point3[0],point3[1]);
    flag.fillStyle=color||random_color();
    flag.fill();
    return flag;
}


function draw_diagonals(flag, width, height, direction, colorlist ){
    direction=direction || Math.floor ( Math.random() * 2 );

    var point1=Array(0,0); 
    var point2=Array(width,height);

    if (direction==1){
        point1=Array(width,0);
        point2=Array(0,height);
    }

    flag=draw_diagonal(flag, point1, Array(point1[0],point2[1]), point2,colorlist[0]) ;
    flag=draw_diagonal(flag, point1, Array(point2[0],point1[1]), point2,colorlist[1]) ;
    return flag;
}

//-==================================================================================================

function set_ratio(flag){
    // http://www.crwflags.com/fotw/flags/xf-size.html
    // like, expand your worldview man.
    var ratios=Array(1, 1.15, 1.25, 1.33, 1.32, 1.38, 1.39, 1.50, 1.6, 1.67, 1.9, 2.0, 2.55 );
    var ratio = ratios[d( ratios.length )]; 
    return ratio;
}
function set_base_color(flag, width,height){
    flag.fillStyle=random_color();
    flag.fillRect(0,0, width,height); 
    return flag;
}
function random_color(){

    var color=Array('00', '44', '88', 'CC', 'FF','FF','FF','00','00');
    var finalcolor = color.splice( d( color.length ),1); 
    finalcolor    += color.splice( d( color.length ),1); 
    finalcolor    += color.splice( d( color.length ),1);
    return "#"+finalcolor;
}
function getQueryString() {
    var result = {}, queryString = location.search.substring(1),
        re = /([^&=]+)=([^&]*)/g, m;
    while (m = re.exec(queryString)) {
        result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
    }
    return result;
}

/* ************************************************************* */
/*
/*  This is a quick and dirty function to select five
/*  non-repeating colors for the flag.
/*  colors[0] is the base
/*  colors[1] is the division secondary
/*  colors[2] is the division tertiary (optional)
/*  colors[3] is the overlay
/*  colors[4] is the symbol
/*
/* ************************************************************* */
function select_5_colors(){
    var colors=Array();
    while (colors.length < 5){
        var newcolor=random_color();
        if (colors.indexOf(newcolor)== -1){
            colors.push(newcolor);
        }
    }
    return colors;
}

// yes, a single letter function. it stands for dice, as in "roll a d20"
// the only difference is this one rolls 0-19 rather than 1-20, but
// since it's only really used against arrays that's ok.
function d(num){
    return Math.floor ( Math.random() * num ) ;
}


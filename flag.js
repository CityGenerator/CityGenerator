
function create_flag(seed) {
        Math.seedrandom(seed);

        var division=getQueryString()['division'];
        var canvas=document.getElementById('flagcanvas');
        var full_flag=canvas.getContext('2d');
//======================================================================

        var ratio=set_ratio(full_flag);
        var height=100;
        var width=height*ratio;
        
        full_flag=select_division(full_flag, division, width, height);
        full_flag=select_overlay(full_flag,width,height);

}



function select_overlay(flag,width,height){
        var chance=  Math.floor ( Math.random() * 100 )  ; 

        if (chance <10){
            flag= draw_quaddiagonal(flag, width, height,  Math.floor ( Math.random() * 4 ) );
        } else if (chance <20){
            flag= draw_quad(flag, width, height, 1 );
        } else if (chance <30){
            var stripes= Math.floor ( Math.random() * 2 )+2 ;
            var stripeid=Math.floor ( Math.random() * (stripes-1) )+1 ;

            flag= draw_stripe(flag,'hor',width,height,stripes, stripeid );
        } else if (chance <40){
            flag=draw_circle(flag,  width, height );
        }
    return flag;


}



    //   condensed awesomeness  http://davidbau.com/archives/2010/01/30/random_seeds_coded_hints_and_quintillions.html
    // allows for seeding of random. it's random enough, STFU. 
    (function(j,i,g,m,k,n,o){function q(b){var e,f,a=this,c=b.length,d=0,h=a.i=a.j=a.m=0;a.S=[];a.c=[];for(c||(b=[c++]);d<g;)a.S[d]=d++;for(d=0;d<g;d++)e=a.S[d],h=h+e+b[d%c]&g-1,f=a.S[h],a.S[d]=f,a.S[h]=e;a.g=function(b){var c=a.S,d=a.i+1&g-1,e=c[d],f=a.j+e&g-1,h=c[f];c[d]=h;c[f]=e;for(var i=c[e+h&g-1];--b;)d=d+1&g-1,e=c[d],f=f+e&g-1,h=c[f],c[d]=h,c[f]=e,i=i*g+c[e+h&g-1];a.i=d;a.j=f;return i};a.g(g)}function p(b,e,f,a,c){f=[];c=typeof b;if(e&&c=="object")for(a in b)if(a.indexOf("S")<5)try{f.push(p(b[a],e-1))}catch(d){}return f.length?f:b+(c!="string"?"\0":"")}function l(b,e,f,a){b+="";for(a=f=0;a<b.length;a++){var c=e,d=a&g-1,h=(f^=e[a&g-1]*19)+b.charCodeAt(a);c[d]=h&g-1}b="";for(a in e)b+=String.fromCharCode(e[a]);return b}i.seedrandom=function(b,e){var f=[],a;b=l(p(e?[b,j]:arguments.length?b:[(new Date).getTime(),j,window],3),f);a=new q(f);l(a.S,j);i.random=function(){for(var c=a.g(m),d=o,b=0;c<k;)c=(c+b)*g,d*=g,b=a.g(1);for(;c>=n;)c/=2,d/=2,b>>>=1;return(c+b)/d};return b};o=i.pow(g,m);k=i.pow(2,k);n=k*2;l(i.random(),j)})([],Math,256,6,52);
//==================================================================


function draw_circle(flag, width, height, radius, color){
    var vert_count=Math.floor ( Math.random() * 4 )+2;
    var hor_count =Math.floor ( Math.random() * 4 )+2;
    var vert_place=Math.floor ( Math.random() * (vert_count-1) )+1;
    var hor_place =Math.floor ( Math.random() * (hor_count-1) )+1;

    radius=Math.min( width/(hor_count)-5 , height/(vert_count)-5 );

    width=width/hor_count*hor_place;;
    height=height/vert_count*vert_place;
    
    color=color||random_color();
    flag.beginPath(); // Start the path
    flag.arc(width,height, radius,0, Math.PI*2, false ); // Draw a circle
    flag.closePath(); // Close the path
    flag.fillStyle=color;
    flag.fill(); // Fill the path
    return flag;

}

        function select_division( flag, division, width, height){
            if (division == undefined){
                var divisions=Array('solid', 'vert2', 'hor2', 'vert3','hor3', 'quads','hor9', 'vert9','vert13','diag1','diag2','diagquad');
                division = divisions[Math.floor ( Math.random() * divisions.length )];
            }

            if (division == 'solid'){
                flag.fillStyle=random_color();
                flag.fillRect(00,0, width,height); 
            } else if (  /vert\d/.test(division)  ){
                var stripecount = division.match(/\d{1,2}/);
                flag=draw_stripes(flag,'vert',stripecount,width,height);
            } else if (  /hor\d/.test(division)  ){
                var stripecount = division.match(/\d{1,2}/);
                flag=draw_stripes(flag,'hor',stripecount,width,height);
            } else if (/quads/.test(division) ){
                flag=draw_quads(flag,width,height);
            } else if (/diag1/.test(division) ){
                flag=draw_diagonals(flag, new Array(width,0) ,new Array(0,height));
            } else if (/diag2/.test(division) ){
                flag=draw_diagonals(flag, new Array(0,0) ,new Array(width,height));
            } else if (/diagquad/.test(division) ){
                flag=draw_quaddiagonals(flag, width, height);
            }
            return flag;
        }


        function draw_stripes(flag,type,stripecount,width,height){
            var loop=stripecount;
            var colors;
            if (stripecount >3){
                colors=Array(random_color(),random_color() ,random_color() );
            }
            while (loop >0){
                if (stripecount >3){
                        flag=draw_stripe(flag,type, width, height,stripecount,loop,colors[loop%2]);
                }else{
                        flag=draw_stripe(flag,type, width, height,stripecount,loop);
                }
                loop--;
            }
            return flag;
        }


        function draw_stripe(flag, type, width, height,count,order,color){
            color=color||random_color();
            flag.fillStyle=color;
            if (type=='hor'){
                flag.fillRect(0,height/count*(order-1),width, height/count );
            }else if (type=='vert'){
                flag.fillRect(width/count*(order-1),  0,width/count, height );
            }
            return flag;
        }


        function draw_quad(flag, width, height, quad, color){
            color=color||random_color();
            var a=0,b=0,c=width/2, d=height/2;
            if (quad == 2 || quad == 4 ){
                a=width/2;
            }
            if (quad == 3 || quad == 4 ){
                b=height/2;
            }
            flag.fillStyle=color;
            flag.fillRect(a,b ,c, d );
            return flag;
        }


        function draw_quads(flag,width,height,color1,color2){

            color1=color1||random_color();
            color2=color2||random_color();
            flag=draw_quad(flag, width, height, 1,color1);
            flag=draw_quad(flag, width, height, 2,color2);
            flag=draw_quad(flag, width, height, 3,color2);
            flag=draw_quad(flag, width, height, 4,color1);
            return flag
        }


        function draw_quaddiagonals(flag, width, height, color1, color2){
            color1=color1||random_color();
            color2=color2||random_color();
            flag=draw_quaddiagonal(flag, width, height, 1, color1);
            flag=draw_quaddiagonal(flag, width, height, 2, color2);
            flag=draw_quaddiagonal(flag, width, height, 3, color1);
            flag=draw_quaddiagonal(flag, width, height, 4, color2);
            return flag
        }
        function draw_quaddiagonal(flag, width, height, side, color1){
            color1=color1||random_color();
            var a=0, b=0, c=0,d=0;

            if (side==2 ){a=width}
            if (side==3 ){b=height}
            if (side==1 || side==2 ||side==3){c=width}
            if (side==2 || side==3 ||side==4){d=height}

            flag.beginPath();
            flag.moveTo(a,b);
            flag.lineTo(c,d);
            flag.lineTo(width/2,height/2);
            flag.fillStyle=color1;
            flag.fill();
            return flag;
        }



        function draw_diagonal(flag, point1, point2, point3,color1 ){
            color1=color1||random_color();
            flag.beginPath();
            flag.moveTo(point1[0],point1[1]);
            flag.lineTo(point2[0],point2[1]);
            flag.lineTo(point3[0],point3[1]);
            flag.fillStyle=color1;
            flag.fill();
            return flag;
        }


        function draw_diagonals(flag, point1, point2, color1, color2){
            color1=color1||random_color();
            color2=color2||random_color();
            flag=draw_diagonal(flag, point1, Array(point1[0],point2[1]), point2,color1 ) ;
            flag=draw_diagonal(flag, point1, Array(point2[0],point1[1]), point2,color2 ) ;
            return flag;
        }

//-==================================================================================================

        function set_ratio(full_flag){
            // http://www.crwflags.com/fotw/flags/xf-size.html
            // like, expand your worldview man.
            var ratios=Array(1, 1.15, 1.25, 1.33, 1.32, 1.38, 1.39, 1.50, 1.6, 1.67, 1.9, 2.0, 2.55 );
            var ratio = ratios[Math.floor ( Math.random() * ratios.length )]; 
            return ratio;
        }
        function set_base_color(full_flag, width,height){
            full_flag.fillStyle=random_color();
            full_flag.fillRect(0,0, width,height); 
            return full_flag;
        }
        function random_color(){

            var color=Array('00',  '88',  'FF');
            var finalcolor = color[Math.floor ( Math.random() * color.length )]; 
            finalcolor += color[Math.floor ( Math.random() * color.length )]; 
            finalcolor += color[Math.floor ( Math.random() * color.length )];
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


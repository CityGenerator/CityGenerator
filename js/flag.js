

function create_flag(params,flagcanvas,jsonblock) {
    
    if (document.getElementById(jsonblock) ){
        document.getElementById(jsonblock).innerHTML = JSON.stringify(params);
    }
    var canvas=document.getElementById(flagcanvas);
    params.canvas=canvas;
    console.log(params);
    var flag=params.canvas.getContext('2d');
    params.flag=flag;
    
    params.canvas.width=canvas.height*params.ratio;
    params.flag=set_shape( params );
    params.flag.clip();
    
    params.flag=select_division( params );
    params.flag=select_overlay( params );
    params.flag=select_symbol( params );
    //flag=select_border( params );

}

//    // overlay should use colors 3 
function select_overlay( params ){
    var color=params.colors[3].hex;
    switch(params.overlay.name){
            case 'quaddiag':
                params.flag= draw_quaddiagonal(params, params.overlay.side, color);
                break;
            case 'quad':
                params.flag= draw_quad(params, params.overlay.side, color);
                break;
            case 'stripe':
                params.flag = draw_stripe(params, params.overlay.side, params.overlay.count, params.overlay.count_selected, color);
                break;
            case 'diamond':
                params.flag = draw_diamond(params); //TODO pass in 2 colors so it can be used as a symbol
                break;
            case 'circle':
                params.flag=draw_circle(params );
                break;
            case  'rays':
                params.flag = draw_rays( params );
                break;

            case 'cross':
                params.flag= draw_cross(params);
                break;
            case 'slash':
                params.flag= draw_slash(params,'left-to-right');
                break;
            case 'jack':
                params.flag= draw_slash(params,'left-to-right');
                params.flag= draw_slash(params,'right-to-left');
                params.flag= draw_cross(params);
                break;
            case 'x':
                params.flag= draw_slash(params,'left-to-right');
                params.flag= draw_slash(params,'right-to-left');
                break;
    }
    return params.flag;
}


function draw_cross(params){

    params.flag = draw_vertical_crossbar(params);
    params.flag = draw_horizontal_crossbar(params);
    return params.flag;
}

function draw_vertical_crossbar(params){
    var width=params.canvas.width*params.overlay.vertwidth;
    var length=params.canvas.width*params.overlay.vertlength;

    var startx=params.canvas.width/2 - width/2;
    var starty= (params.canvas.height-length)/2
    params.flag.fillStyle=params.colors[3].hex;
    
    params.flag.fillRect( startx, starty, width,  length );
    return params.flag;

}
function draw_horizontal_crossbar(params){

    var width=params.canvas.height*params.overlay.horwidth;
    var length=params.canvas.width*params.overlay.horlength;

    var startx=(params.canvas.width-length)/2 ;
    var starty=params.canvas.height*params.overlay.horpos - width/2

    params.flag.fillStyle=params.colors[3].hex;
    params.flag.fillRect( startx, starty,length,width);
    
    
    
    
    return params.flag;

}




function select_symbol(params){

    console.log(params.symbol.name);
    if (params.symbol.name == 'circle'){
        params.flag=draw_circle_symbol( params );

    } else if (params.symbol.name == 'star'){
        params.flag= draw_star(params);

    } else if (params.symbol.name=='letter'){
        params.flag= draw_letter(params);
    }
    return params.flag;
}

function draw_circle_symbol(params){

    var radius;
    radius=params.symbol.radius*params.canvas.height
    var width=params.canvas.width*params.symbol.xlocation
    var height=params.canvas.height*params.symbol.ylocation
    params.flag.save()
    params.flag.beginPath(); // Start the path
    params.flag.arc(width,height, radius, 0, Math.PI*2, false ); // Draw a circle
    params.flag.closePath(); // Close the path
    params.flag.fillStyle=params.colors[5].hex;
    params.flag.fill(); // Fill the path
    params.flag.restore();

    return params.flag;

}

function draw_letter(params){
    params.flag.fillStyle=params.colors[5].hex;
    var fontsize=Math.min( params.canvas.height*params.symbol.size  );
    var font= fontsize + "px "+params.symbol.fontfamily;

    if (! params.symbol.letter){
        var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        params.symbol.letter=possible.charAt(Math.floor(Math.random() * possible.length));
    }


    params.flag.textBaseline = 'middle';
    params.flag.font=font;
    console.log(font);
    params.flag.fillText(params.symbol.letter, (params.canvas.width*params.symbol.xlocation)-fontsize/2   ,(params.canvas.height*params.symbol.ylocation) );

    return params.flag;
}


//    function select_border(flag, width, height, colorlist){
//        var border=getQueryString()['border'];
//        var chance=border||  d( 30 )  ;
//     
//        if (chance < 10 || border == 'true'){
//            flag=draw_border( flag, width, height, undefined, colorlist  );
//        }
//        return flag;
//    }


function draw_solid( params){
        params.flag.fillStyle=params.colors[0].hex;
        params.flag.fillRect(0,0, params.canvas.width,params.canvas.height); 
        return params.flag;

}


function draw_slash(params, direction){

    params.flag.beginPath();

    if (! direction){
        direction = params.overlay.direction 
    }


    var linewidth=params.canvas.width * params.overlay.width;
    var lineheight=params.canvas.height * params.overlay.width;
    if (direction =='left-to-right'){
        params.flag.moveTo(    0,                               0);
        params.flag.lineTo(    linewidth,                       0);
        params.flag.lineTo(    params.canvas.width,             params.canvas.height-lineheight);
        params.flag.lineTo(    params.canvas.width,             params.canvas.height);
        params.flag.lineTo(    params.canvas.width-linewidth,   params.canvas.height);
        params.flag.lineTo(    0,                               lineheight);
    }else{
        params.flag.moveTo(    params.canvas.width-linewidth,   0);
        params.flag.lineTo(    params.canvas.width,             0);
        params.flag.lineTo(    params.canvas.width,             lineheight);
        params.flag.lineTo(    linewidth,                       params.canvas.height);
        params.flag.lineTo(    0,                               params.canvas.height);
        params.flag.lineTo(    0,                               params.canvas.height-lineheight);
    }
    params.flag.fillStyle=params.colors[3].hex;
    params.flag.fill();
    return params.flag;
}


//    
//    function draw_x(flag, width, height, thickness, color){
//        var linewidths=Array( 1/6, 1/8, 1/9, 1/10, 1/12, 1/15, 1/20);
//        thickness = thickness|| linewidths[ d( linewidths.length ) ] ;
//        flag=draw_slash(flag,width,height,thickness,'left',color);
//        flag=draw_slash(flag,width,height,thickness,'right',color);
//        return flag;
//    }



//    function draw_border(flag, width, height, thickness,colorlist){
//        thickness=thickness|| d(10)+2 ;
//        var color=colorlist[2] ||random_color();
//        flag.beginPath();
//        flag.lineWidth=thickness;
//        flag.moveTo(0+thickness/2,0+thickness/2);
//        flag.lineTo(width-thickness/2,0+thickness/2);
//        flag.lineTo(width-thickness/2,height-thickness/2);
//        flag.lineTo(0+thickness/2,height-thickness/2);
//        flag.lineTo(0+thickness/2,0);
//        flag.strokeStyle=color;
//        flag.stroke();
//        return flag;
//    
//    }
//    
//    
function draw_rays(  params){

    var count=params.overlay.count;
    var angle=360/count;
    var x=params.canvas.width *params.overlay.xlocation
    var y=params.canvas.height*params.overlay.ylocation
    x=params.canvas.width/2;
    y=params.canvas.height/2;
    var offset=params.overlay.offset;
    params.flag.save();
    params.flag.fillStyle=params.colors[3].hex;
    params.flag.translate(x,y);
    while (count-- >0){
        params.flag.beginPath();
        params.flag.moveTo(0,-offset*params.canvas.width/2);
        params.flag.lineTo(0,-params.canvas.width*2.5);
        params.flag.rotate(angle/2 * Math.PI/180);
        params.flag.lineTo(0,-params.canvas.width*2.5);
        params.flag.lineTo(0,-offset*params.canvaswidth/2);

        params.flag.closePath();
        params.flag.fill();
        params.flag.rotate(angle/2 * Math.PI/180);
    }
    params.flag.translate(-x,-y);
    params.flag.restore();
    return params.flag;
}


function draw_star(params) {


    var xaxis=params.symbol.xlocation;
    var yaxis=params.symbol.ylocation;
    
    var radius=Math.min( params.canvas.width*xaxis, params.canvas.width*(1-xaxis),params.canvas.height*yaxis, params.canvas.height*(1-yaxis) );
    params.flag.fillStyle=params.colors[5].hex;
    params.flag.beginPath();
    params.flag.translate(params.canvas.width*xaxis, params.canvas.height*yaxis);
console.log("x "+ (params.canvas.width)+" y "+(params.canvas.height));
console.log("x "+ (xaxis)+" y "+(yaxis));
console.log("x "+ (params.canvas.width*xaxis)+" y "+(params.canvas.height*yaxis));
    params.flag.moveTo(0,0-radius);
    for (var i = 0; i < params.symbol.points; i++) {
        params.flag.rotate(Math.PI / params.symbol.points);
        params.flag.lineTo(0, 0 - (radius*params.symbol.inset));
        params.flag.rotate(Math.PI / params.symbol.points);
        params.flag.lineTo(0, 0 - radius);
    }
    params.flag.fill();
    params.flag.translate(-params.canvas.width*xaxis,- params.canvas.height*yaxis);
    return params.flag;
}


function draw_diamond(params){
    params.flag.save();
    params.flag.beginPath();
    params.flag.moveTo(    params.canvas.width/2,  0  );
    params.flag.lineTo(    params.canvas.width,    params.canvas.height/2 );
    params.flag.lineTo(    params.canvas.width/2,  params.canvas.height );
    params.flag.lineTo(    0,                      params.canvas.height/2 );
    params.flag.fillStyle=params.colors[3].hex;
    params.flag.fill();
    params.flag.restore();
    if (params.overlay.outline=="false"){
        params.flag.save();
        params.flag.beginPath();
        params.flag.lineWidth=10;
        params.flag.moveTo(    params.canvas.width/2,  0  );
        params.flag.lineTo(    params.canvas.width,    params.canvas.height/2 );
        params.flag.lineTo(    params.canvas.width/2,  params.canvas.height );
        params.flag.lineTo(    0,                      params.canvas.height/2 );
        params.flag.lineTo(    params.canvas.width/2,  0  );
        params.flag.strokeStyle=params.colors[4].hex;
        params.flag.stroke();
        params.flag.restore();
    }

    return params.flag;

}

function draw_circle(params){

    var radius;
    if (params.overlay.radius_direction =="horizontal"){
        radius=params.overlay.radius*params.canvas.width
    }else{
        radius=params.overlay.radius*params.canvas.height
    }
    var width=params.canvas.width*params.overlay.xlocation
    var height=params.canvas.height*params.overlay.ylocation
    params.flag.save()
    params.flag.beginPath(); // Start the path
    params.flag.arc(width,height, radius, 0, Math.PI*2, false ); // Draw a circle
    params.flag.closePath(); // Close the path
    params.flag.fillStyle=params.colors[3].hex;
    params.flag.fill(); // Fill the path
    params.flag.restore();

    if (params.overlay.outline =="true"){
        params.flag.save()
        params.flag.beginPath(); // Start the path
        params.flag.lineWidth=params.overlay.outline_width;
        params.flag.arc(width,height, radius, 0, Math.PI*2, false ); // Draw a circle
        params.flag.closePath(); // Close the path
        params.flag.strokeStyle=params.colors[4].hex;
        params.flag.stroke(); // Fill the path
        params.flag.restore();
    }

    return params.flag;

}

    function draw_stripes(params){
        for (var i=0; i<=params.division.count; i++){
            params.flag=draw_stripe(params, params.division.side, params.division.count, i);
        }
        return params.flag;
    }
    
    
    function draw_stripe(params, side, count, id,color){
    
        if (! color){
            var colorid=id % params.division.color_count;
            color=params.colors[colorid].hex;
        }
        params.flag.fillStyle=color;
    
        if (side=="horizontal"){
            var thickness=Math.floor(params.canvas.height/count);
            params.flag.fillRect(0, (thickness*id)   ,params.canvas.width,thickness);
            
        }else {
            var thickness=Math.floor(params.canvas.width/count);
            params.flag.fillRect( (thickness*id),0 ,thickness  ,params.canvas.height);
        }
        return params.flag;
    }
    
    
function draw_quad(params, quadrant, color){
    var a=0,b=0,c=params.canvas.width/2, d=params.canvas.height/2;
    if (quadrant == "ne" || quadrant == "se" ){
        a=params.canvas.width/2;
    }
    if (quadrant == "se" || quadrant == "sw" ){
        b=params.canvas.height/2;
    }


    if ( color == undefined) {
        if (quadrant == "nw" || quadrant == "se" ){
            color=params.colors[0].hex;
        }else{
            color=params.colors[1].hex;
        }
    }

    
    params.flag.fillStyle=color;

    params.flag.fillRect( a, b, c, d );
    return params.flag;
}


function draw_quads(params){

    params.flag=draw_quad( params, "nw" );
    params.flag=draw_quad( params, "ne" );
    params.flag=draw_quad( params, "sw" );
    params.flag=draw_quad( params, "se" );
    return params.flag
}


function draw_quaddiagonals(params){
     params.flag=draw_quaddiagonal( params, "north" );
     params.flag=draw_quaddiagonal( params, "south" );
     params.flag=draw_quaddiagonal( params, "east"  );
     params.flag=draw_quaddiagonal( params, "west"  );
     return params.flag;
}


function draw_quaddiagonal(params, side, color){
    var a=0, b=0, c=0,d=0;
    if (side=="east" ){a=params.canvas.width}
    if (side=="south" ){b=params.canvas.height}
    if (side=="north" || side=="east"  ||side=="south"){c=params.canvas.width}
    if (side=="east"  || side=="south" ||side=="west" ){d=params.canvas.height}
 
    if (!color ){
        if (side == "north" || side == "south"){
            color=params.colors[0].hex;
        }else{
            color=params.colors[1].hex;
        }
    }
    params.flag.save();
    params.flag.beginPath();
    params.flag.moveTo(a,b);
    params.flag.lineTo(c,d);
    params.flag.lineTo(params.canvas.width/2,params.canvas.height/2);
    params.flag.fillStyle=color;
    params.flag.fill();
    params.flag.restore();

    return params.flag;
 }
 
 
function draw_diagonal(params, side, color ){
    var start,mid,end;

    if (side == "north" && params.division.direction == "left-to-right"){
        start=[0,0];
        mid=[params.canvas.width,0];
        end=[params.canvas.width,params.canvas.height];

    }else if (side == "south" && params.division.direction == "left-to-right"){
        start=[0,0];
        mid=[0,params.canvas.height];
        end=[params.canvas.width,params.canvas.height];

    }else if (side == "north" && params.division.direction == "right-to-left"){
        start=[params.canvas.width,0];
        mid=[0,0];
        end=[0,params.canvas.height];

    }else if (side == "south" && params.division.direction == "right-to-left"){
        start=[params.canvas.width,0];
        mid=[params.canvas.width,params.canvas.height];
        end=[0,params.canvas.height];
    }
    if (! color){
        if (side == "north"){
            color=params.colors[0].hex;
        }else{
            color=params.colors[1].hex;
        }
    }

    params.flag.save(); 
    params.flag.beginPath();
    params.flag.moveTo(start[0],start[1]);
    params.flag.lineTo(mid[0],mid[1]);
    params.flag.lineTo(end[0],end[1]);
    params.flag.fillStyle=color;
    params.flag.fill();
    params.flag.restore(); 
    return params.flag;
}


function draw_diagonals(params ){

    params.flag=draw_diagonal(params, "north") ;
    params.flag=draw_diagonal(params, "south") ;
    return params.flag;
}
//    
//    function getQueryString() {
//        var result = {}, queryString = location.search.substring(1),
//            re = /([^&=]+)=([^&]*)/g, m;
//        while (m = re.exec(queryString)) {
//            result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
//        }
//        return result;
//    }

//    /* ************************************************************* */
//    /*
//    /*  This is a quick and dirty function to select five
//    /*  non-repeating colors for the flag.
//    /*  colors[0] is the base
//    /*  colors[1] is the division secondary
//    /*  colors[2] is the division tertiary (optional)
//    /*  colors[3] is the overlay
//    /*  colors[4] is the symbol
//    /*
//    /* ************************************************************* */

function set_shape(params){
    var width=params.canvas.width;
    var height=params.canvas.height;
    params.flag.save();
    params.flag.fillStyle = "rgba(0, 0, 0, .0)"
    params.flag.lineWidth = 1
    switch(params.shape.name){
        case 'para':
            params.flag.moveTo(    0,        0);
            params.flag.lineTo(    width,    height/6);
            params.flag.lineTo(    width,    height-height/6);
            params.flag.lineTo(    0,        height);
            break;
        case 'tri':
            params.flag.moveTo(    0,        0);
            params.flag.lineTo(    width,    height/2);
            params.flag.lineTo(    0,        height);
            break;
        case 'pennant':
            params.flag.moveTo(    0,        0);
            params.flag.lineTo(    width,    height/5*2);
            params.flag.lineTo(    width,    height/5*3);
            params.flag.lineTo(    0,        height);
            break;
        case 'swallow':
            params.flag.moveTo(    0,                0);
            params.flag.lineTo(    width,            height/3*1);
            params.flag.lineTo(    width-width/5,    height/2);
            params.flag.lineTo(    width,            height/3*2);
            params.flag.lineTo(    0,                height);
            break;
        case 'tongued':
            params.flag.moveTo(    0,                0);
            params.flag.lineTo(    width,            0);

            var tonguecount=params.shape.count;
            var depth=params.shape.depth;
            for (var i = 0 ; i < tonguecount ; i++){ 
                params = draw_tongue_slot(params,tonguecount,i,depth,params.shape.type); 
            }

            params.flag.lineTo(    width,            height);
            params.flag.lineTo(    0,                height);
            break;
        default:
            params.flag.rect(0,0,width,height);
    }
    params.flag.fill();
    params.flag.save();
    return params.flag;
}

function draw_tongue_slot(params,count,id,depth,type){

    var x = params.canvas.width;
    var height=params.canvas.height/(count*2-1);
    var y = height*(id*2-1);
    depth=params.canvas.width*depth;
    params.flag.lineTo(x,y);
    if (type == "square"){
        params.flag.lineTo(x-depth,y);
        params.flag.lineTo(x-depth,y+height);
    }else if (type=="triangle"){
        params.flag.lineTo(x-depth,y+height/2);
    }else if (type=="scallop"){
        params.flag.arc(x, y+height/2 ,height/2 ,1.5 * Math.PI, 0.5*Math.PI,true);
    }else if (type=="sine"){
        params.flag.arc(x-height/2, y-height/2,          height/2,   0*Math.PI, 0.5*Math.PI,false);
        params.flag.arc(x-height/2, y+height/2,   height/2, 1.5*Math.PI, 0.5*Math.PI,true);
        params.flag.arc(x-height/2, y+height*1.5,          height/2,  1.5*Math.PI, 0*Math.PI,false);
    }
    params.flag.lineTo(x      ,y+height);
    return params;
}



// Division should only use colors 0,1 and 2 at most.
function select_division( params){

    switch(params.division.name){
        case 'quads':
            params.flag = draw_quads( params );
            break;
        case 'diagquad':
            params.flag = draw_quaddiagonals( params );
            break;
        case 'diagonal':
            params.flag = draw_diagonals( params );
            break;
        case 'stripes':
            params.flag = draw_stripes( params );
            break;
        default:
            params.flag = draw_solid( params );
    }
    return params.flag;
}

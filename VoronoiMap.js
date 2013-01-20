

/* ========================================================================= */
/* VoronoiMap is an abstracted class used to create the world and city maps.
/* This is roughly based on Amit Patel's Flash Mapgen code
/*     buildGraph()
/*     generateRandomPoints( num_points )
/*     improveRandomPoints()
/*     paintDot( canvas, x, y, radius, color )
/*     paintCell( canvas, cell, color, border )
/*     paintCells( canvas,cells, color, border )
/*     render(canvas)
/*     paintBackground(canvas,color)
/*     triangulatePosition(va,vb,vc)
/* ========================================================================= */

function  VoronoiMap(width,height,num_points) {

    // Base Parameters
    this.width=width;
    this.height=height;


    this.xmultiplier=1
    this.ymultiplier=1
    this.xoffset=0
    this.yoffset=0
    // colors are used by world and regional maps.
    this.colors = [ '255,105,100', '139,0,0', '255,140,0', '255,255,0', '124,252,0', '127,255,212', '95,158,160', '30,144,255', '238,130,238',  '128,0,128','12,12,120','220,12,12','220,100,12'      ];

    // default constant values
    this.num_lloyd_iterations=2;
//    this.scale=1
    // These are important bits to track
    this.voronoi = new Voronoi();

    //First generate points,
    this.points=this.generateRandomPoints(num_points);

    // then compute the virinoi
    this.buildGraph();

    // make those points pretty and more regularly organized
    this.improveRandomPoints();
}

/* ========================================================================= */
/*  
/* 
/* ========================================================================= */

VoronoiMap.prototype.resizeGraph = function(width,height){
    for (var i=0; i<this.points.length; i++) {
        var point = this.points[i]
        point.x = this.translatePoint( point.x, 0, this.width,  width);
        point.y = this.translatePoint( point.y, 0, this.height, height);
        this.points[i]=point
    }

    var diagram = this.voronoi.compute(this.points, {xl:0,xr:width,yt:0,yb:height });
    for (var i=0; i<this.diagram.cells.length; i++) {
        diagram.cells[i].elevation=this.diagram.cells[i].elevation
        diagram.cells[i].moisture=this.diagram.cells[i].moisture
        diagram.cells[i].radius=this.diagram.cells[i].radius
        diagram.cells[i].ocean=this.diagram.cells[i].ocean
        diagram.cells[i].river=this.diagram.cells[i].river
        diagram.cells[i].lake=this.diagram.cells[i].lake
        diagram.cells[i].coast=this.diagram.cells[i].coast
        diagram.cells[i].kingdom=this.diagram.cells[i].kingdom
        diagram.cells[i].upslope=this.diagram.cells[i].upslope
        diagram.cells[i].color=this.diagram.cells[i].color
        diagram.cells[i].terrain=this.diagram.cells[i].terrain
        diagram.cells[i].border=this.diagram.cells[i].border
    
    }
    this.diagram=diagram

    this.width  = width
    this.height = height

}

/* ========================================================================= */
/*  build the actual voronoi diagram  
/* 
/* ========================================================================= */

VoronoiMap.prototype.buildGraph = function(){
    this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.generateRandomPoints = function(num_points){
    var points = [];
    var margin=0;
    for (var i=0; i<num_points; i++) {
        var x = Math.round((Math.random()*(this.width  -margin*2) )*10)/10 +margin
        var y = Math.round((Math.random()*(this.height -margin*2) )*10)/10 +margin
        points.push({ x:x, y:y  }); 
    }      
    return points 
}  


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.improveRandomPoints = function(){
    //    console.log("improve me")
    var points=[];
    for (var i = 0; i < this.num_lloyd_iterations; i++) {
        points=[];
        for(cellid in this.diagram.cells) {
            var cell = this.diagram.cells[cellid];
            cell.site.x = 0.0;
            cell.site.y = 0.0;
            var count=0;
            for (hedgeid in cell.halfedges) {
                var he = cell.halfedges[hedgeid];
                var hestart=he.getStartpoint();
                if (hestart.x != NaN && hestart.y != NaN){
                    cell.site.x += hestart.x||0;
                    cell.site.y += hestart.y||0;
                    count++;
                }
                var heend=he.getEndpoint();
                if (heend.x != NaN && heend.y != NaN){

                    cell.site.x += heend.x||0;
                    cell.site.y += heend.y||0;
                    count++;
                }
            }
            var px = parseInt(cell.site.x / count);
            var py = parseInt(cell.site.y / count);
            points.push({x:px, y:py });
        }
        this.voronoi.reset();
        this.points=points;
        this.buildGraph();
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.paintDot = function(canvas,x,y,radius,color){
    var ctx = canvas.getContext('2d');
//    ctx.scale(this.scale,this.scale);


    ctx.strokeStyle=color;
    ctx.fillStyle=color;
    ctx.beginPath();

    //TODO refactor this to use ctx.rect()
    var xa=this.xoffset+this.xmultiplier*x
    var ya=this.yoffset+this.ymultiplier*y
    ctx.lineTo(this.xoffset+this.xmultiplier*(x-radius),this.yoffset+this.ymultiplier*(y-radius))
    ctx.lineTo(this.xoffset+this.xmultiplier*(x+radius),this.yoffset+this.ymultiplier*(y-radius))
    ctx.lineTo(this.xoffset+this.xmultiplier*(x+radius),this.yoffset+this.ymultiplier*(y+radius))
    ctx.lineTo(this.xoffset+this.xmultiplier*(x-radius),this.yoffset+this.ymultiplier*(y+radius))

    ctx.closePath();
    ctx.fill();
    ctx.stroke();
}

/* ========================================================================= */
/* Given a cell on a canvas,
/* 
/* ========================================================================= */

VoronoiMap.prototype.paintCell = function( canvas, cell, color, border ){
    if ( color == null ){
        color = cell.color
        if ( color == null ){
            color = '#ff00ff' // this default color is purposfully ugly.
        }
    }
    var polyfill = canvas.getContext( '2d' );
//    ctx.scale(this.scale,this.scale);

    polyfill.fillStyle = color;
    polyfill.strokeStyle = color;
    polyfill.beginPath() ;
    // draw a line for each edge, A to B.
    for ( var i = 0 ; i < cell.halfedges.length ; i++ ) {

        var vertexa = cell.halfedges[i].getStartpoint();
        polyfill.lineTo( this.xoffset+this.xmultiplier*vertexa.x, this.yoffset+this.ymultiplier*vertexa.y );

        var vertexb = cell.halfedges[i].getEndpoint();
        polyfill.lineTo( this.xoffset+this.xmultiplier*vertexb.x, this.yoffset+this.ymultiplier*vertexb.y);
    }
    //close the path and fill it in with the provided color
    polyfill.closePath();

    polyfill.fill();
    if ( border ){
        polyfill.stroke();
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.paintCells = function(canvas,cells,color,border){
    for (var i = 0; i < cells.length; i++) {
        var cell=cells[i];
        this.paintCell( canvas, cell, color, border );
    }
}


/* ========================================================================= */
/*  render uses the edges from the diagram, then mark the points.
/* 
/* ========================================================================= */

VoronoiMap.prototype.render = function(canvas){
    var ctx = canvas.getContext('2d');
//    ctx.scale(this.scale,this.scale);

    //First lets draw all of the edges.
    // This can probably be refactored
    ctx.strokeStyle="rgba(0,0,0,.2)";
    ctx.lineWidth=1;
    ctx.beginPath();
    var edges = this.diagram.edges;
    var iEdge = edges.length;
    var edge, v;
    while (iEdge--) {
        edge = edges[iEdge];
        v = edge.va;
        ctx.moveTo(this.xoffset+this.xmultiplier*v.x,this.yoffset+this.ymultiplier*v.y);
        v = edge.vb;
        ctx.lineTo(this.xoffset+this.xmultiplier*v.x,this.yoffset+this.ymultiplier*v.y);
        }
    ctx.stroke();

    ctx.fillStyle = 'rgba(255,200,200,.2)';
    ctx.beginPath();
    var msites = this.points,
        iSite = this.points.length;
    while (iSite--) {
        v = msites[iSite];
        ctx.rect(this.xoffset+this.xmultiplier*v.x-2/3,this.yoffset+this.ymultiplier*v.y-2/3,2,2);
        }
    ctx.fill();

    //TODO add the centers to the render list.
}


/* ========================================================================= */
/*  paintBackground is relatively simple- it just draws the 
/*  background rectangle.
/* ========================================================================= */

VoronoiMap.prototype.paintBackground = function(canvas,color,scale,region){
    var ctx = canvas.getContext('2d');
    ctx.scale(scale,scale);
//        console.log(region)
    if (region != undefined){
        ctx.translate(-region.minx, -region.miny);
    }
    ctx.globalAlpha = 1;
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.rect(0,0,canvas.width,canvas.height);
    ctx.fill();
}


/* ========================================================================= */
/* triangulatePosition uses magic to randomly select a point from a triangle.
/* This is currently used to place cities within cells.
/* ========================================================================= */

VoronoiMap.prototype.triangulatePosition = function(va,vb,vc){
    var t=Math.random()
    var s=Math.random()
    // The following awesome magic was taken from the book "Graphic Gems"
    // I do not understand it, which makes me ashamed.
    if (t+s > 1){
        s=1-s
        t=1-t
    }
    var a = 1-s-t,
        b = s, 
        c = t
    var randx=va.x*a +vb.x*b + vc.x*c
    var randy=va.y*a +vb.y*b + vc.y*c
    return {x:randx,y:randy}
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.translatePoint = function(point,min,max,totallength){
    return Math.round(      (point-min)*totallength/(max-min)    );
}
VoronoiMap.prototype.translatePoint2 = function(point,oldmin,oldmax,newmin,newmax){
    //TODO integrate newmin; currently 0 is used
    point.x= Math.round(      (point.x-oldmin.x)*newmax.x/(oldmax.x-oldmin.x)    );
    point.y= Math.round(      (point.y-oldmin.y)*newmax.y/(oldmax.y-oldmin.y)    );
    return point
}




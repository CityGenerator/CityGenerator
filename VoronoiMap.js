
function  VoronoiMap(width,height,num_points) {
    // Base Parameters
    this.width=width;
    this.height=height;
    this.num_points = num_points;

    // default constant values
    this.num_lloyd_iterations=2;

    // These are important bits to track
    this.voronoi = new Voronoi();

    //First generate points,
    this.generateRandomPoints();

    // then compute the virinoi
    this.buildGraph();
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.buildGraph = function(){
    this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
    this.improveRandomPoints();
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.improveRandomPoints = function(){
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
            points.push({x:px,
                        y:py
                        });
        }

        this.voronoi.reset();
        this.points=points;
        this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
    }
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.generateRandomPoints = function(){
    var points = [];
    var margin=0;
    for (var i=0; i<this.num_points; i++) {
        points.push({ 
                    x:Math.round((Math.random()*(this.width  -margin*2) )*10)/10 +margin,
                    y:Math.round((Math.random()*(this.height -margin*2) )*10)/10 +margin
                    }); 
    }       
    this.points=points;
}  
/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.colorPolygon = function(cell,canvas,mode,color,noborder){
    if (color == null){
        if (mode=='elevation'){  //note that there is a two-tone color difference between land and ocean
            //not intentional, but s exxpected.
                var c= parseInt(Math.floor(cell.elevation*128))*2;
                cell.color= 'rgb(' + c + "," + c + "," + c + ")";
        }else if (mode=='moisture'){
            var c= parseInt(Math.floor(cell.moisture*128))*2;
            cell.color= 'rgb(' + c + "," + c + "," + c + ")";

        }else if (mode=='biomes'){
            if (cell.ocean){
                cell.color=this.getOceanColor(cell);
            }else{
               cell.color=this.terrain[ cell.terrain].color;
            }
        }else if (mode=='land elevation'){
            if ( cell.ocean){
                cell.color=this.getOceanColor(cell);
            }else{
                var c= parseInt(Math.floor(cell.elevation*128))*2; //The closer the elevation is to 0
                cell.color= 'rgb(' + c + "," + c + "," + c + ")";
            }
        }
    }else{
        cell.color=color;
    }
    var polyfill = canvas.getContext('2d');

    polyfill.fillStyle=cell.color;
    polyfill.strokeStyle=cell.color;
    polyfill.beginPath();
    // draw a line for each edge, A to B.
    console.log(cell)
    for (var i=0; i<cell.halfedges.length; i++) {

        var vertexa=cell.halfedges[i].getStartpoint();
        polyfill.lineTo(vertexa.x,vertexa.y);
        var vertexb=cell.halfedges[i].getEndpoint();
        polyfill.lineTo(vertexb.x,vertexb.y);
    }
    //close the path and fill it in with the provided color
    polyfill.closePath();
    polyfill.fill();
    if (!noborder){
        polyfill.stroke();
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.colorPolygon = function(cell,canvas,mode,color,noborder){
    if (color == null){
        if (mode=='elevation'){  //note that there is a two-tone color difference between land and ocean
            //not intentional, but s exxpected.
                var c= parseInt(Math.floor(cell.elevation*128))*2;
                cell.color= 'rgb(' + c + "," + c + "," + c + ")";
        }else if (mode=='moisture'){
            var c= parseInt(Math.floor(cell.moisture*128))*2;
            cell.color= 'rgb(' + c + "," + c + "," + c + ")";

        }else if (mode=='biomes'){
            if (cell.ocean){
                cell.color=this.getOceanColor(cell);
            }else{
               cell.color=this.terrain[ cell.terrain].color;
            }
        }else if (mode=='land elevation'){
            if ( cell.ocean){
                cell.color=this.getOceanColor(cell);
            }else{
                var c= parseInt(Math.floor(cell.elevation*128))*2; //The closer the elevation is to 0
                cell.color= 'rgb(' + c + "," + c + "," + c + ")";
            }
        }
    }else{
        cell.color=color;
    }
    var polyfill = canvas.getContext('2d');

    polyfill.fillStyle=cell.color;
    polyfill.strokeStyle=cell.color;
    polyfill.beginPath();
    // draw a line for each edge, A to B.
    console.log(cell)
    for (var i=0; i<cell.halfedges.length; i++) {

        var vertexa=cell.halfedges[i].getStartpoint();
        polyfill.lineTo(vertexa.x,vertexa.y);
        var vertexb=cell.halfedges[i].getEndpoint();
        polyfill.lineTo(vertexb.x,vertexb.y);
    }
    //close the path and fill it in with the provided color
    polyfill.closePath();
    polyfill.fill();
    if (!noborder){
        polyfill.stroke();
    }
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

VoronoiMap.prototype.paintdot = function(canvas,x,y,radius,color){
    var polyfill = canvas.getContext('2d');

    polyfill.strokeStyle=color;
    polyfill.fillStyle=color;
    polyfill.beginPath();

    polyfill.moveTo(x-radius,y-radius);
    polyfill.lineTo(x+radius,y-radius);
    polyfill.lineTo(x+radius,y+radius);
    polyfill.lineTo(x-radius,y+radius);

    polyfill.closePath();
    polyfill.fill();
    polyfill.stroke();
}

/* ========================================================================= */
/*  render uses the edges from the diagram, then mark the points.
/* 
/* ========================================================================= */

VoronoiMap.prototype.render = function(canvas){
    var ctx = canvas.getContext('2d');

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
        ctx.moveTo(v.x,v.y);
        v = edge.vb;
        ctx.lineTo(v.x,v.y);
        }
    ctx.stroke();

    // Now lets draw some red dots at the 
    // point for each cell (note, not the center)
    // This can probably be refactored
    ctx.fillStyle = 'rgba(255,200,200,.2)';
    ctx.beginPath();
    var msites = this.points,
        iSite = this.points.length;
    while (iSite--) {
        v = msites[iSite];
        //TODO this doesn't need to be a rectangle; simplify with a dot if possible
        ctx.rect(v.x-2/3,v.y-2/3,2,2);
        }
    ctx.fill();

    //TODO add the centers to the render list.
}


/* ========================================================================= */
/*  paintBackground is relatively simple- it just draws the 
/*  background rectangle.
/* ========================================================================= */

VoronoiMap.prototype.paintBackground = function(canvas,color){
        var ctx = canvas.getContext('2d');
        ctx.globalAlpha = 1;
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.rect(0,0,canvas.width,canvas.height);
        ctx.fill();
}


VoronoiMap.prototype.triangulatePosition = function(va,vb,vc){
    var t=Math.random()
    var s=Math.random()
    if (t+s > 1){
        s=1-s
        t=1-t
    }
    var a = 1-s-t
    var b = s
    var c = t
    var randx=va.x*a +vb.x*b + vc.x*c
    var randy=va.y*a +vb.y*b + vc.y*c
    return {x:randx,y:randy}
}


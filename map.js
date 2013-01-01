/* **************************************************************** */
/*  Lets generate a worldmap!
/* **************************************************************** */

function  WorldMap(width,height,point_count) {
    // Base Parameters
    this.width=width;
    this.height=height;
    this.num_points = point_count;
    
    // default constant values
    this.lake_threshold=0.3;
    this.num_lloyd_iterations=2;

    // These are important bits to track
    this.points=Array();
    this.centers=Array();
    this.corners=Array();
    this.edges=Array();
    this.voronoi = new Voronoi();


    // Now lets actually make stuff. 
    //First generate points,
    this.generateRandomPoints();
    // then compute the virinoi
    this.buildGraph();
    //
}


/* **************************************************************** */
/*  buildGraph uses the points, width and height that were 
/*  previously set to generate a voronoi diagram.
/*  From there, the edges, centers and corners are calculated.
/* **************************************************************** */
WorldMap.prototype.buildGraph = function(){
    this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
    this.improveRandomPoints();
    this.assignElevations()

    //TODO is edges really what I want/need?
    //TODO calculate centers
    //TODO calculate corners
}

/* **************************************************************** */
/*  generateRandomPoints  generate a random set of points using
/*  the previously provided width, height, and number of points.
/* **************************************************************** */
WorldMap.prototype.generateRandomPoints = function(){
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

/* **************************************************************** */
/*  assignElevations
/*  
/* **************************************************************** */
WorldMap.prototype.assignElevations = function() {
    var sim = new SimplexNoise() ;
    var min=1;
    var max=0;
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        var width  = this.width;
        var height = this.height;
        var x = cell.site.x;
        var y = cell.site.y;
        var centerx = width/2;
        var centery = height/2;
        var lesser  = width < height ? width : height;
        var minradius= Math.sqrt(   Math.pow(lesser,2) + Math.pow(lesser,2))/2 ;

        var adjustedx=x-centerx;
        var adjustedy=y-centery;
        var noise= sim.noise2D(Math.abs(adjustedx),Math.abs(adjustedy)); 
        cell.radius=  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2));
        var percent= Math.abs(cell.radius/minradius) ;// +noise/10;
        cell.debug=adjustedx+" "+adjustedy + " radius:"+cell.radius+"  minradius:"+minradius+" percent: "+percent;

        percent=Math.pow(percent,2)-.6+sim.noise2D(x/200,y/200)/4;
        cell.elevation=Math.round( percent*300)/100 ;
        if (cell.elevation < min){min=cell.elevation};
        if (cell.elevation > max){max=cell.elevation};
    }
//    alert(min +" --"+max );
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        //adjust min and max to be on the proper scale.
        cell.elevation=(cell.elevation-min)/max;
        if (cell.elevation > .5){
            cell.ocean=true;
        }
        cell.debug='\nocean:'+ cell.ocean +"\n" ;
    }
}

/* **************************************************************** */
/*  colorPolygon make a pretty polygon given a cellid and a canvas
/*  to draw on. This is currently broken, which makes me a sad panda.
/* **************************************************************** */
WorldMap.prototype.colorPolygon = function(cellid,canvas,mode,color){
    var cell = this.diagram.cells[cellid];
    var ctx = canvas.getContext('2d');

    ctx.beginPath();
    // draw a line for each edge, A to B.
    for (var i=0; i<cell.halfedges.length; i++) {

        var vertexa=cell.halfedges[i].getStartpoint();
        ctx.lineTo(vertexa.x,vertexa.y);
        var vertexb=cell.halfedges[i].getEndpoint();
        ctx.lineTo(vertexb.x,vertexb.y);
    }
    //close the path and fill it in with the provided color
    ctx.closePath();
    if (color == null){
        if (mode=='elevation'){ 
            var c= parseInt(Math.floor(cell.elevation*128))*2; //The closer the elevation is to 0
            cell.color= 'rgb(' + c + "," + c + "," + c + ")";
        }else if (mode=='land/ocean'){ 
            if (cell.ocean){
                cell.color='#3366ff';
            }else{
                cell.color='#996633';
            }
        }else if (mode=='land/shallows'){
            var c= parseInt(Math.floor(cell.elevation*2))*128; //The closer the elevation is to 0
            cell.color= 'rgb(' + c + "," + c + "," + c + ")";
        }
    }else{
        cell.color=color;
    }
    ctx.fillStyle=cell.color;
    ctx.fill();

}

/* **************************************************************** */
/*  render uses the edges from the diagram, then mark the points.
/* **************************************************************** */
WorldMap.prototype.render = function(canvas){
        var ctx = canvas.getContext('2d');
       
        //First lets draw all of the edges.
        // This can probably be refactored
        ctx.beginPath();
        ctx.strokeStyle='#aaaaaa';
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
        ctx.beginPath();
        ctx.fillStyle = '#faa';
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


/* **************************************************************** */
/*  paintBackground is relatively simple- it just draws the 
/*  background rectangle.
/* **************************************************************** */
WorldMap.prototype.paintBackground = function(canvas){
        var ctx = canvas.getContext('2d');
        ctx.globalAlpha = 1;
        ctx.beginPath();
        ctx.rect(0,0,this.width,this.height);
        ctx.fillStyle = 'white';
        ctx.fill();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
//
//    function go(){
//    
//        //The go function appears to be the core of the map class
//        //reset();
//        //=== Place Points ===
//            this.points=generateRandomPoints()
//        //=== Improve Points ===
//            improveRandomPonts(this.points);
//        //=== build graph ===
//            //magic happens here.
//            //this.voronoi= new Voronoi(points,null,rectangle); // I do not have this!!!
//            //buildGraph(points,voronoi)
//            //improveCorners();
//    
//        //=== Assign elevations ===
//            assignCornerElevations();
//            assignOceanCoastAndLand();
//            redistributeElevations(landCorners(this.corners));
//            for ( corner in this.corners){
//                if (corner.ocean ||corner.coast){
//                    corner.elevation=0.0;
//                }
//            }
//            assignPolygonElevations();
//        //=== Assign Moisture ===
//            calculateDownslopes();
//            calculate_watersheds();
//            createRivers();
//            assignCornerMoisture();
//            redistributeMoisture(landCorners(this.corners));
//            assignPolygonMoisture();
//        //=== Decorate Map
//            assignBiomes();
//    }
//
//
//    function improveRandomPonts(){
//        //TODO use lloyd relaxation on this.points
WorldMap.prototype.improveRandomPoints = function(){
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
//        // requires Voronoi voodoo
//    }
//    function improveCorners(){
//        // TODO This is truthfully icing that isn't needed immediately.
//
//    }    
//
//    //I do not currently understand the purpose of this method.
//    function landCorners(){
//        var locations=Array();
//        for (corner in this.corners){
//          if (!corner.ocean && !corner.coast) {
//            locations.push(corner);
//          }
//        }
//        return locations;
//    }
//
//
WorldMap.prototype.assignCornerElevations = function(){


        // TODO yeah this one as well.
    }
//    function redistributeElevations(locations){
//        // TODO yeah this one as well.
//    }
//    function redistributeMoisture(locations){
//        // TODO yeah this one as well.
//    }
//    function assignOceanCoastAndLand(){
//        // TODO
//    }
//    function assignPolygonElevations(){
//        //TODO
//    }
//    function calculateDownslopes(){
//        for (corner in this.corners){
//            //tempcorner finds the lowest adjacent corner to mark as a downslope
//            // and the default is itself.
//            var tempcorner=corner;
//            for (adjacent_corner in corner.adjacent){
//                if (adjacent_corner.elevation <= tempcorner.elevation){
//                    tempcorner=adjacent_corner;
//                }
//            }
//            corner.downslope=tempcorner;
//        }
//    }
//    function calculateWatersheds(){
//        for (corner in this.corners){
//            corner.wathershed=corner
//            if (!corner.ocean && !corner.coast) {
//            corner.watershed=corner.downslope;
//            }
//        }
//        //TODO finish this
//    }
//    function createRivers(){
//        //TODO finish this
//    }
//    function assignCornerMoisture(){
//        //TODO finish this
//    }
//    function assignPolygonMoisture(){
//        //TODO finish this
//    }
//
//    function getBiome(p) {
//      if (p.ocean) {
//        return 'OCEAN';
//      } else if (p.water) {
//        if (p.elevation < 0.1) return 'MARSH';
//        if (p.elevation > 0.8) return 'ICE';
//        return 'LAKE';
//      } else if (p.coast) {
//        return 'BEACH';
//      } else if (p.elevation > 0.8) {
//        if (p.moisture > 0.50) return 'SNOW';
//        else if (p.moisture > 0.33) return 'TUNDRA';
//        else if (p.moisture > 0.16) return 'BARE';
//        else return 'SCORCHED';
//      } else if (p.elevation > 0.6) {
//        if (p.moisture > 0.66) return 'TAIGA';
//        else if (p.moisture > 0.33) return 'SHRUBLAND';
//        else return 'TEMPERATE_DESERT';
//      } else if (p.elevation > 0.3) {
//        if (p.moisture > 0.83) return 'TEMPERATE_RAIN_FOREST';
//        else if (p.moisture > 0.50) return 'TEMPERATE_DECIDUOUS_FOREST';
//        else if (p.moisture > 0.16) return 'GRASSLAND';
//        else return 'TEMPERATE_DESERT';
//      } else {
//        if (p.moisture > 0.66) return 'TROPICAL_RAIN_FOREST';
//        else if (p.moisture > 0.33) return 'TROPICAL_SEASONAL_FOREST';
//        else if (p.moisture > 0.16) return 'GRASSLAND';
//        else return 'SUBTROPICAL_DESERT';
//      }
//    }
//   
// 
//    function assignBiomes() {
//      var p;
//      for (p in centers) {
//          p.biome = getBiome(p);
//        }
//    }
//
//
//    function lookupEdgeFromCenter(leftcenter,riftcenter) {
//      for ( edge in leftcenter.borders) {
//            if (edge.d0 == rightcenter || edge.d1 == rightcenter){
//                return edge;
//            }
//        }
//      return null;
//    }
//
//    function lookupEdgeFromCorner(leftcorner,rightcorner) {
//        for (edge in  leftcorner.protrudes) {
//            if (edge.v0 == rightcorner || edge.v1 == rightcorner) {
//                return edge;
//            }
//        }
//      return null;
//    }
//
//    function inside(p) {
//        //TODO magic
//    }
//
//}
//
//

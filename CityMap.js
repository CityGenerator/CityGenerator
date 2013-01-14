
function build_city(  params      ){

    Math.seedrandom(params.seed)
    var citycanvas=params.canvas

    var width =350;
    var height=300;
    citycanvas.height=height;citycanvas.width=width;
    //params.size=12
    var citysitecount=200+params.size*20 // should range between 50 cells and 220




    var city=new CityMap(width, height,citysitecount);
    city.render(citycanvas)

    var basecolor=document.map.currentcitycell.color
    document.map.paintBackground(citycanvas,basecolor);
    city.citycells=[]
    var citycellcount=Math.floor(citysitecount*(20+params.size)/100);
    for (var i = 0; i < Math.floor( citycellcount) ; i++) {
        city.citycells.push(city.findCenterCell(citycanvas))
    }

    for (var i = 0; i < city.citycells.length; i++) {
        var cell=city.citycells[i];
        city.colorPolygon(cell,citycanvas,'highlight','rgba(255,255,255,1)',false);
    }
    
    city.getCityWalls()

    city.drawCityWalls(citycanvas,  Math.ceil(params.wallheight/10)   )

    for (var i = 0; i < params.districts.length; i++) {
//        city.getDistrict(i,6);
        console.log(params.districts[i])
    }


    city.render(citycanvas)
    city.drawRoads(citycanvas, params.roads, params.mainroads)
}





function  CityMap(width,height,point_count) {
    // Base Parameters
    this.width=width;
    this.height=height;
    this.num_points = point_count;
    //TODO I should add oceans here...    
    // default constant values
    this.lake_threshold=0.3;
    this.num_lloyd_iterations=2;

    // These are important bits to track
    this.points=Array();
    this.centers=Array();
    this.voronoi = new Voronoi();


    // Now lets actually make stuff. 
    //First generate points,
    this.generateRandomPoints();
    // then compute the virinoi
    this.buildGraph();
    //
}

CityMap.prototype.findCenterCell = function(canvas){
    var width  = this.width;
    var height = this.height;

    var centerx = width/2;
    var centery = height/2;
    var lesser  = Math.min(width, height);

    var closestpoint;
    var shortestradius=10000;

    for (var i=0; i<this.diagram.cells.length; i++) {
        var cell=this.diagram.cells[i];
        var x = cell.site.x
        var y = cell.site.y
        var randx= (Math.random()*x - x/2)/4
        var randy= (Math.random()*y - y/2)/4


        var adjustedx=x-centerx+randx;
        var adjustedy=y-centery+randy;
        var radius=  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2));
        if (!cell.incity &&    shortestradius> radius ){ // if edge is shared, give a 50% change of allowing
            shortestradius=radius
            closestpoint=cell
        }
    }
    closestpoint.incity=true
    return closestpoint
}



CityMap.prototype.generateRandomPoints = function(){
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
CityMap.prototype.buildGraph = function(){
    this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
    this.improveRandomPoints();
}
CityMap.prototype.improveRandomPoints = function(){
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

/* **************************************************************** */
CityMap.prototype.colorPolygon = function(cell,canvas,mode,color,noborder){
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

CityMap.prototype.drawRoads = function(canvas,roads,mainroads){
    var corners=[]
    for(var i=0; i<this.outline.length; i++){
        corners.push(this.outline[i])
    }
    var roadwidth=3
    for (var i=0; i<roads; i++){
        if (mainroads-->0){
            roadwidth=6
        }else{
            roadwidth=3
        }
        var va=corners.splice( Math.floor(Math.random()*corners.length) ,1)[0];
        this.drawRoad(canvas,va,roadwidth);
    }
}




CityMap.prototype.drawRoad = function(canvas,va,roadwidth){
    var road=[va]
    var loop=30

    var focus;
    var minx=Math.min(va.x,canvas.width-va.x);
    var miny=Math.min(va.y,canvas.height-va.y);

    var targetva=null
    var candidatecells=[]
    var cells=this.diagram.cells
    if (minx/canvas.width < miny/canvas.height){ // X is closer than Y
        if ( minx == va.x ) {
            while (va.x >0 ){ //bear west
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate
                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.x < va.x){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                    road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.x < va.x){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }else{
            while (va.x <canvas.width ){//bear east
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate
                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.x > va.x){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.x > va.x){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }
    }else{    
        if ( miny == va.y ) {
            while (va.y >0 ){ // bear north
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate
                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.y < va.y){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.y < va.y){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }else{
            while (va.y <canvas.height ){//bear south
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate
                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.y > va.y){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.y > va.y){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }
    }


    var c = canvas.getContext('2d');

    c.strokeStyle='#5E2605';
    c.lineWidth=roadwidth;
    c.beginPath();
    var originalposition=null
    for (var j=0; j < road.length; j++){
        c.lineTo(road[j].x, road[j].y);
    }
    c.lineCap = 'butt';
    c.stroke()
    this.paintdot(canvas, road[0].x, road[0].y, roadwidth/2,'rgba(100,100,100,.9)') // final gateway

}









CityMap.prototype.paintdot = function(canvas,x,y,radius,color){
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

CityMap.prototype.drawCityWalls = function(canvas,wallsize){
    var polyline = canvas.getContext('2d');
    polyline.beginPath();
    for (var i=0; i<this.outline.length; i++){
        var vertex= this.outline[i];
        polyline.lineTo(vertex.x,vertex.y);
    }
    polyline.lineWidth=wallsize;
    //console.log(wallsize)
    polyline.strokeStyle="rgba(0,0,0,0.7)";
    //polyline.fillStyle="rgba(200,0,0,0.3)";
    polyline.fillStyle=this.color;
    polyline.lineCap = 'butt';
    polyline.stroke();
    //    polyline.fill();
    polyline.closePath();

}
// Determine if halfedge has a side that is not in the kingdom list
CityMap.prototype.isKingdomEdge = function(ids,halfedge){
    if (  ids.indexOf( halfedge.edge.lSite.voronoiId) ==-1 || ids.indexOf( halfedge.edge.rSite.voronoiId) ==-1  ){
        return true
    }else{
        return false
    }
}


//TODO refactor with getKingdomPolygon
CityMap.prototype.getCityWalls = function(){
        var ids=[]
        for (var i=0; i < this.citycells.length ; i++ ){ ids.push(this.citycells[i].site.voronoiId)}
        //Get a list of all external edges
        var edges=[];
        for (var i=0; i < this.citycells.length ; i++ ){
            var cell=this.citycells[i];
            for (var j=0; j < cell.halfedges.length ; j++ ){
                var he=cell.halfedges[j];
                if (  this.isKingdomEdge(ids,he) ){
                    edges.push(he);
                }
            }
        }

        //loop through the edges and push them onto the outline list for drawing later
        var minx=1000000
        var pos;
        for (var i=0; i < edges.length ; i++ ){
            minx=Math.min(minx,edges[i].edge.va.x, edges[i].edge.va.x)
            if (edges[i].edge.va.x == minx){
                pos=edges[i].edge.va
            } else if (edges[i].edge.vb.x == minx){
                pos=edges[i].edge.vb
            }
        }

        this.outline=[pos];
        var maxfail=edges.length;
        while(edges.length >0){
            var testedge=edges.pop()
            if (testedge.edge.va == pos ){
                    pos=testedge.edge.vb;
                    this.outline.push(pos);
                    maxfail=edges.length;
            }else if (testedge.edge.vb == pos ){
                    pos=testedge.edge.va;
                    this.outline.push(pos);
                    maxfail=edges.length;
            }else{
                maxfail--;
                if (maxfail== 0){
                    break;
                }
                edges.unshift(testedge);
            }
        }
        return this;
}



/* **************************************************************** */
/*  render uses the edges from the diagram, then mark the points.
/* **************************************************************** */
CityMap.prototype.render = function(canvas){
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

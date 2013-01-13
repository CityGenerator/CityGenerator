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
        var adjustedx=x-centerx;
        var adjustedy=y-centery;
        var radius=  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2));
        if (shortestradius> radius && ! cell.incity){
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
        if (i==2){
            this.drawRoad(canvas,va,roadwidth);
        }
    }
}


CityMap.prototype.getCandidates = function(canvas,va){
    var candidates =[]

    var closex= Math.min( va.x ,  (canvas.width- va.x) )
    var closey= Math.min( va.y ,  (canvas.height- va.y) )
 
    for (var i=0; i < this.diagram.cells.length; i++){
        var cell=this.diagram.cells[i]
        if ( ! cell.incity){
            if (  (closex < closey)    &&  ( (cell.site.x < va.x && va.x < canvas.width - va.x ) ||  (cell.site.x > va.x && va.x > canvas.width - va.x ) )  ){
                candidates.push(cell)
            }else if (  (closex > closey)   &&  ((cell.site.y < va.y && va.y < canvas.height - va.y ) ||  (cell.site.y > va.y && va.y > canvas.height - va.y ) )  ){ 
                candidates.push(cell)
            }
        }
    }
    return candidates
}

CityMap.prototype.selectTarget = function(canvas,va,candidates){
    var closex= Math.min( va.x ,  (canvas.width- va.x) )
    var closey= Math.min( va.y ,  (canvas.height- va.y) )
    var target=null

    for (var i=0; i < candidates.length; i++){
        var cell=candidates[i]
        this.paintdot(canvas, cell.site.x, cell.site.y, 6,'rgba(20,20,20,.1)') //marks the direction

        for (var j=0; j < cell.corners.length; j++){
                
            if ( cell.corners[j] == va   ){
                if (target == null ||  ( closex<closey && cell.site.x < target.site.x  ) || ( closex>closey && cell.site.y < target.site.y  )  ){
                    target=cell
                }//XXX
            }

        }
    }
    return target
}
CityMap.prototype.selectTargetCorner = function(target,va){
    var targetcorner=null
    for (var j=0; j < target.halfedges.length; j++){
        var edge=target.halfedges[j].edge;
        if (edge.va ==va || edge.vb == va ){ // This edge is a potential edge
            if (edge.va ==va ){
                if (targetcorner == null || edge.vb.x< targetcorner.x){
                    targetcorner=edge.vb
                }
            }else if (edge.vb == va){
                if (targetcorner == null || edge.va.x< targetcorner.x){
                    targetcorner=edge.va
                }
            }
        }
    }
    return targetcorner
    
}
CityMap.prototype.drawRoad = function(canvas,va,roadwidth){
    var road=[va]
    var loop=30
    this.paintdot(canvas, va.x, va.y, 6,'rgba(200,100,250,.5)') // Initial gateway
    while (loop-- >0){ // this loop should never get to 30; this is a failsafe
        console.log(loop)
    
        var candidates=this.getCandidates(canvas,va)
        var target    =this.selectTarget(canvas,va,candidates)

        if (target == null){
            break
        }else{
            var targetcorner=this.selectTargetCorner(target,va);
            //this.paintdot(canvas, va.x, va.y, 6,'rgba(200,0,50,.1)')
            if (targetcorner !=null){
                console.log(this)
                if (this.outline.indexOf(targetcorner) == -1){ // targetcorner is allowe because it's not part of the outline
                    road.push(targetcorner)
                }else {
                    road=[targetcorner]
                }
                va=targetcorner
            }
        }
    }


    this.paintdot(canvas, road[0].x, road[0].y, 6,'rgba(100,100,100,.9)') // final gateway
    var c = canvas.getContext('2d');

    c.strokeStyle='#5E2605';
    c.lineWidth=roadwidth;
    c.beginPath();
    for (var j=0; j < road.length; j++){
        c.lineTo(road[j].x, road[j].y);
    }
    c.stroke()
    //determine which side is closest
    // determine which cells are closer to target side
    // determine which cells share va
    // determine which cell is closest to target side
    // determine which edges contain va, determine which

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

CityMap.prototype.drawCityPolygon = function(canvas,wallsize){
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
CityMap.prototype.getCityPolygon = function(){
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
    ctx.strokeStyle="rgba(0,0,0,.5)";
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
    ctx.fillStyle = '#faa';
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

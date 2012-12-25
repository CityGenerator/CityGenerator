/* Over my Head*/
function  worldMap(size) {
    this.size=size;
    this.num_points = 200;
    this.lake_threshold=0.3;
    this.num_lloyd_iterations=2;
    
    this.points=Array();
    this.centers=Array();
    this.corners=Array();
    this.edges=Array();


    function newIsland(seed) {
        this.islandShape = IslandShape(seed);
    }

    function go(){
    
        //The go function appears to be the core of the map class
        reset();
        //=== Place Points ===
            this.points=generateRandomPoints()
        //=== Improve Points ===
            improveRandomPonts(this.points);
        //=== build graph ===
            //magic happens here.
            //this.voronoi= new Voronoi(points,null,rectangle); // I do not have this!!!
            //buildGraph(points,voronoi)
            //improveCorners();
    
        //=== Assign elevations ===
            assignCornerElevations();
            assignOceanCoastAndLand();
            redistributeElevations(landCorners(this.corners));
            this.corners.forEach(corner){
                if (corner.ocean ||corner.coast){
                    corner.elevation=0.0;
                }
            }
            assignPolygonElevations();
        //=== Assign Moisture ===
            calculateDownslopes();
            calculate_watersheds();
            createRivers();
            assignCornerMoisture();
            redistributeMoisture(landCorners(this.corners));
            assignPolygonMoisture();
        //=== Decorate Map
            assignBiomes();
    }

    function generateRandomPoints(){
        // TODO
        // return an array of points, which contain x and y coordinates, possibly more.
        // make sure to give a 10 pixel buffer from the edges
    }      

    function improveRandomPonts(){
        //TODO use lloyd relaxation on this.points
        // requires Voronoi voodoo
    }
    function improveCorners(){
        // TODO This is truthfully icing that isn't needed immediately.

    }    

    //I do not currently understand the purpose of this method.
    function landCorners(){
        var locations=Array();
        this.corners.forEach(corner){
          if (!corner.ocean && !corner.coast) {
            locations.push(corner);
          }
        }
        return locations;
    }

    function buildGraph(points,voronoi){
        // I have no clue how to implement this without a voronoi object. 
    }

    function assignCornerElevations(){
        // TODO yeah this one as well.
    }
    function redistributeElevations(locations){
        // TODO yeah this one as well.
    }
    function redistributeMoisture(locations){
        // TODO yeah this one as well.
    }
    function assignOceanCoastAndLand(){
        // TODO
    }
    function assignPolygonElevations(){
        //TODO
    }
    function calculateDownslopes(){
        for (corner in this.corners){
            //tempcorner finds the lowest adjacent corner to mark as a downslope
            // and the default is itself.
            var tempcorner=corner;
            for (adjacent_corner in corner.adjacent){
                if (adjacent_corner.elevation <= tempcorner.elevation){
                    tempcorner=adjacent_corner;
                }
            }
            corner.downslope=tempcorner;
        }
    }
    function calculateWatersheds(){
        for (corner in this.corners){
            corner.wathershed=corner
            if (!corner.ocean && !corner.coast) {
            corner.watershed=corner.downslope;
            }
        }
        //TODO finish this
    }
    function createRivers(){
        //TODO finish this
    }
    function assignCornerMoisture(){
        //TODO finish this
    }
    function assignPolygonMoisture(){
        //TODO finish this
    }

    function getBiome(p) {
      if (p.ocean) {
        return 'OCEAN';
      } else if (p.water) {
        if (p.elevation < 0.1) return 'MARSH';
        if (p.elevation > 0.8) return 'ICE';
        return 'LAKE';
      } else if (p.coast) {
        return 'BEACH';
      } else if (p.elevation > 0.8) {
        if (p.moisture > 0.50) return 'SNOW';
        else if (p.moisture > 0.33) return 'TUNDRA';
        else if (p.moisture > 0.16) return 'BARE';
        else return 'SCORCHED';
      } else if (p.elevation > 0.6) {
        if (p.moisture > 0.66) return 'TAIGA';
        else if (p.moisture > 0.33) return 'SHRUBLAND';
        else return 'TEMPERATE_DESERT';
      } else if (p.elevation > 0.3) {
        if (p.moisture > 0.83) return 'TEMPERATE_RAIN_FOREST';
        else if (p.moisture > 0.50) return 'TEMPERATE_DECIDUOUS_FOREST';
        else if (p.moisture > 0.16) return 'GRASSLAND';
        else return 'TEMPERATE_DESERT';
      } else {
        if (p.moisture > 0.66) return 'TROPICAL_RAIN_FOREST';
        else if (p.moisture > 0.33) return 'TROPICAL_SEASONAL_FOREST';
        else if (p.moisture > 0.16) return 'GRASSLAND';
        else return 'SUBTROPICAL_DESERT';
      }
    }
   
 
    function assignBiomes() {
      var p;
      for (p in centers) {
          p.biome = getBiome(p);
        }
    }


    function lookupEdgeFromCenter(leftcenter,riftcenter) {
      for ( edge in leftcenter.borders) {
            if (edge.d0 == rightcenter || edge.d1 == rightcenter){
                return edge;
            }
        }
      return null;
    }

    function lookupEdgeFromCorner(leftcorner,rightcorner) {
        for (edge in  leftcorner.protrudes) {
            if (edge.v0 == rightcorner || edge.v1 == rightcorner) {
                return edge;
            }
        }
      return null;
    }

    function inside(p) {
        //TODO magic
    }


  }
}


function IslandShape() {

    this.island_factor=1.07;  
    function makePerlin(seed){
        // haha, I have no idea how to implement this. TODO learn math.
    }
  
}

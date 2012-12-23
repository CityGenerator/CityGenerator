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
            corners.foreach(corner){
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
    
    }
    //---------------------------------------------------------------------//
    //--------- The division between javascript and actionscript ----------//
    //---------------------------------------------------------------------//

    // Create an array of corners that are on land only, for use by
    // algorithms that work only on land. We return an array instead
    // of a vector because the redistribution algorithms want to sort
    // this array using Array.sortOn.
    public function landCorners(corners:Vector.<Corner>):Array {
      var q:Corner, locations:Array = [];
      for each (q in corners) {
          if (!q.ocean && !q.coast) {
            locations.push(q);
          }
        }
      return locations;
    }

    
    // Build graph data structure in 'edges', 'centers', 'corners',
    // based on information in the Voronoi results: point.neighbors
    // will be a list of neighboring points of the same type (corner
    // or center); point.edges will be a list of edges that include
    // that point. Each edge connects to four points: the Voronoi edge
    // edge.{v0,v1} and its dual Delaunay triangle edge edge.{d0,d1}.
    // For boundary polygons, the Delaunay edge will have one null
    // point, and the Voronoi edge may be null.
    public function buildGraph(points:Vector.<Point>, voronoi:Voronoi):void {
      var p:Center, q:Corner, point:Point, other:Point;
      var libedges:Vector.<com.nodename.Delaunay.Edge> = voronoi.edges();
      var centerLookup:Dictionary = new Dictionary();

      // Build Center objects for each of the points, and a lookup map
      // to find those Center objects again as we build the graph
      for each (point in points) {
          p = new Center();
          p.index = centers.length;
          p.point = point;
          p.neighbors = new Vector.<Center>();
          p.borders = new Vector.<Edge>();
          p.corners = new Vector.<Corner>();
          centers.push(p);
          centerLookup[point] = p;
        }
      
      // Workaround for Voronoi lib bug: we need to call region()
      // before Edges or neighboringSites are available
      for each (p in centers) {
          voronoi.region(p.point);
        }
      
      // The Voronoi library generates multiple Point objects for
      // corners, and we need to canonicalize to one Corner object.
      // To make lookup fast, we keep an array of Points, bucketed by
      // x value, and then we only have to look at other Points in
      // nearby buckets. When we fail to find one, we'll create a new
      // Corner object.
      var _cornerMap:Array = [];
      function makeCorner(point:Point):Corner {
        var q:Corner;
        
        if (point == null) return null;
        for (var bucket:int = int(point.x)-1; bucket <= int(point.x)+1; bucket++) {
          for each (q in _cornerMap[bucket]) {
              var dx:Number = point.x - q.point.x;
              var dy:Number = point.y - q.point.y;
              if (dx*dx + dy*dy < 1e-6) {
                return q;
              }
            }
        }
        bucket = int(point.x);
        if (!_cornerMap[bucket]) _cornerMap[bucket] = [];
        q = new Corner();
        q.index = corners.length;
        corners.push(q);
        q.point = point;
        q.border = (point.x == 0 || point.x == SIZE
                    || point.y == 0 || point.y == SIZE);
        q.touches = new Vector.<Center>();
        q.protrudes = new Vector.<Edge>();
        q.adjacent = new Vector.<Corner>();
        _cornerMap[bucket].push(q);
        return q;
      }
    
      for each (var libedge:com.nodename.Delaunay.Edge in libedges) {
          var dedge:LineSegment = libedge.delaunayLine();
          var vedge:LineSegment = libedge.voronoiEdge();

          // Fill the graph data. Make an Edge object corresponding to
          // the edge from the voronoi library.
          var edge:Edge = new Edge();
          edge.index = edges.length;
          edge.river = 0;
          edges.push(edge);
          edge.midpoint = vedge.p0 && vedge.p1 && Point.interpolate(vedge.p0, vedge.p1, 0.5);

          // Edges point to corners. Edges point to centers.
          edge.v0 = makeCorner(vedge.p0);
          edge.v1 = makeCorner(vedge.p1);
          edge.d0 = centerLookup[dedge.p0];
          edge.d1 = centerLookup[dedge.p1];

          // Centers point to edges. Corners point to edges.
          if (edge.d0 != null) { edge.d0.borders.push(edge); }
          if (edge.d1 != null) { edge.d1.borders.push(edge); }
          if (edge.v0 != null) { edge.v0.protrudes.push(edge); }
          if (edge.v1 != null) { edge.v1.protrudes.push(edge); }

          function addToCornerList(v:Vector.<Corner>, x:Corner):void {
            if (x != null && v.indexOf(x) < 0) { v.push(x); }
          }
          function addToCenterList(v:Vector.<Center>, x:Center):void {
            if (x != null && v.indexOf(x) < 0) { v.push(x); }
          }
          
          // Centers point to centers.
          if (edge.d0 != null && edge.d1 != null) {
            addToCenterList(edge.d0.neighbors, edge.d1);
            addToCenterList(edge.d1.neighbors, edge.d0);
          }

          // Corners point to corners
          if (edge.v0 != null && edge.v1 != null) {
            addToCornerList(edge.v0.adjacent, edge.v1);
            addToCornerList(edge.v1.adjacent, edge.v0);
          }

          // Centers point to corners
          if (edge.d0 != null) {
            addToCornerList(edge.d0.corners, edge.v0);
            addToCornerList(edge.d0.corners, edge.v1);
          }
          if (edge.d1 != null) {
            addToCornerList(edge.d1.corners, edge.v0);
            addToCornerList(edge.d1.corners, edge.v1);
          }

          // Corners point to centers
          if (edge.v0 != null) {
            addToCenterList(edge.v0.touches, edge.d0);
            addToCenterList(edge.v0.touches, edge.d1);
          }
          if (edge.v1 != null) {
            addToCenterList(edge.v1.touches, edge.d0);
            addToCenterList(edge.v1.touches, edge.d1);
          }
        }
    }


    // Determine elevations and water at Voronoi corners. By
    // construction, we have no local minima. This is important for
    // the downslope vectors later, which are used in the river
    // construction algorithm. Also by construction, inlets/bays
    // push low elevation areas inland, which means many rivers end
    // up flowing out through them. Also by construction, lakes
    // often end up on river paths because they don't raise the
    // elevation as much as other terrain does.
    public function assignCornerElevations():void {
      var q:Corner, s:Corner;
      var queue:Array = [];
      
      for each (q in corners) {
          q.water = !inside(q.point);
        }

      for each (q in corners) {
          // The edges of the map are elevation 0
          if (q.border) {
            q.elevation = 0.0;
            queue.push(q);
          } else {
            q.elevation = Infinity;
          }
        }
      // Traverse the graph and assign elevations to each point. As we
      // move away from the map border, increase the elevations. This
      // guarantees that rivers always have a way down to the coast by
      // going downhill (no local minima).
      while (queue.length > 0) {
        q = queue.shift();

        for each (s in q.adjacent) {
            // Every step up is epsilon over water or 1 over land. The
            // number doesn't matter because we'll rescale the
            // elevations later.
            var newElevation:Number = 0.01 + q.elevation;
            if (!q.water && !s.water) {
              newElevation += 1;
            }
            // If this point changed, we'll add it to the queue so
            // that we can process its neighbors too.
            if (newElevation < s.elevation) {
              s.elevation = newElevation;
              queue.push(s);
            }
          }
      }
    }

    
    // Change the overall distribution of elevations so that lower
    // elevations are more common than higher
    // elevations. Specifically, we want elevation X to have frequency
    // (1-X). To do this we will sort the corners, then set each
    // corner to its desired elevation.
    public function redistributeElevations(locations:Array):void {
      // SCALE_FACTOR increases the mountain area. At 1.0 the maximum
      // elevation barely shows up on the map, so we set it to 1.1.
      var SCALE_FACTOR:Number = 1.1;
      var i:int, y:Number, x:Number;

      locations.sortOn('elevation', Array.NUMERIC);
      for (i = 0; i < locations.length; i++) {
        // Let y(x) be the total area that we want at elevation <= x.
        // We want the higher elevations to occur less than lower
        // ones, and set the area to be y(x) = 1 - (1-x)^2.
        y = i/(locations.length-1);
        // Now we have to solve for x, given the known y.
        // * y = 1 - (1-x)^2
        // * y = 1 - (1 - 2x + x^2)
        // * y = 2x - x^2
        // * x^2 - 2x + y = 0
        // From this we can use the quadratic equation to get:
        x = Math.sqrt(SCALE_FACTOR) - Math.sqrt(SCALE_FACTOR*(1-y));
        if (x > 1.0) x = 1.0; // TODO: does this break downslopes?
        locations[i].elevation = x;
      }
    }


    // Change the overall distribution of moisture to be evenly distributed.
    public function redistributeMoisture(locations:Array):void {
      var i:int;
      locations.sortOn('moisture', Array.NUMERIC);
      for (i = 0; i < locations.length; i++) {
        locations[i].moisture = i/(locations.length-1);
      }
    }


    // Determine polygon and corner types: ocean, coast, land.
    public function assignOceanCoastAndLand():void {
      // Compute polygon attributes 'ocean' and 'water' based on the
      // corner attributes. Count the water corners per
      // polygon. Oceans are all polygons connected to the edge of the
      // map. In the first pass, mark the edges of the map as ocean;
      // in the second pass, mark any water-containing polygon
      // connected an ocean as ocean.
      var queue:Array = [];
      var p:Center, q:Corner, r:Center, numWater:int;
      
      for each (p in centers) {
          numWater = 0;
          for each (q in p.corners) {
              if (q.border) {
                p.border = true;
                p.ocean = true;
                q.water = true;
                queue.push(p);
              }
              if (q.water) {
                numWater += 1;
              }
            }
          p.water = (p.ocean || numWater >= p.corners.length * LAKE_THRESHOLD);
        }
      while (queue.length > 0) {
        p = queue.shift();
        for each (r in p.neighbors) {
            if (r.water && !r.ocean) {
              r.ocean = true;
              queue.push(r);
            }
          }
      }
      
      // Set the polygon attribute 'coast' based on its neighbors. If
      // it has at least one ocean and at least one land neighbor,
      // then this is a coastal polygon.
      for each (p in centers) {
          var numOcean:int = 0;
          var numLand:int = 0;
          for each (r in p.neighbors) {
              numOcean += int(r.ocean);
              numLand += int(!r.water);
            }
          p.coast = (numOcean > 0) && (numLand > 0);
        }


      // Set the corner attributes based on the computed polygon
      // attributes. If all polygons connected to this corner are
      // ocean, then it's ocean; if all are land, then it's land;
      // otherwise it's coast.
      for each (q in corners) {
          numOcean = 0;
          numLand = 0;
          for each (p in q.touches) {
              numOcean += int(p.ocean);
              numLand += int(!p.water);
            }
          q.ocean = (numOcean == q.touches.length);
          q.coast = (numOcean > 0) && (numLand > 0);
          q.water = q.border || ((numLand != q.touches.length) && !q.coast);
        }
    }
  

    // Polygon elevations are the average of the elevations of their corners.
    public function assignPolygonElevations():void {
      var p:Center, q:Corner, sumElevation:Number;
      for each (p in centers) {
          sumElevation = 0.0;
          for each (q in p.corners) {
              sumElevation += q.elevation;
            }
          p.elevation = sumElevation / p.corners.length;
        }
    }

    
    // Calculate downslope pointers. At every point, we point to the
    // point downstream from it, or to itself. This is used for
    // generating rivers and watersheds.
    public function calculateDownslopes():void {
      var q:Corner, s:Corner, r:Corner;
      
      for each (q in corners) {
          r = q;
          for each (s in q.adjacent) {
              if (s.elevation <= r.elevation) {
                r = s;
              }
            }
          q.downslope = r;
        }
    }


    // Calculate the watershed of every land point. The watershed is
    // the last downstream land point in the downslope graph. TODO:
    // watersheds are currently calculated on corners, but it'd be
    // more useful to compute them on polygon centers so that every
    // polygon can be marked as being in one watershed.
    public function calculateWatersheds():void {
      var q:Corner, r:Corner, i:int, changed:Boolean;
      
      // Initially the watershed pointer points downslope one step.
      for each (q in corners) {
          q.watershed = q;
          if (!q.ocean && !q.coast) {
            q.watershed = q.downslope;
          }
        }
      // Follow the downslope pointers to the coast. Limit to 100
      // iterations although most of the time with NUM_POINTS=2000 it
      // only takes 20 iterations because most points are not far from
      // a coast. TODO: can run faster by looking at
      // p.watershed.watershed instead of p.downslope.watershed.
      for (i = 0; i < 100; i++) {
        changed = false;
        for each (q in corners) {
            if (!q.ocean && !q.coast && !q.watershed.coast) {
              r = q.downslope.watershed;
              if (!r.ocean) q.watershed = r;
              changed = true;
            }
          }
        if (!changed) break;
      }
      // How big is each watershed?
      for each (q in corners) {
          r = q.watershed;
          r.watershed_size = 1 + (r.watershed_size || 0);
        }
    }


    // Create rivers along edges. Pick a random corner point, then
    // move downslope. Mark the edges and corners as rivers.
    public function createRivers():void {
      var i:int, q:Corner, edge:Edge;
      
      for (i = 0; i < SIZE/2; i++) {
        q = corners[mapRandom.nextIntRange(0, corners.length-1)];
        if (q.ocean || q.elevation < 0.3 || q.elevation > 0.9) continue;
        // Bias rivers to go west: if (q.downslope.x > q.x) continue;
        while (!q.coast) {
          if (q == q.downslope) {
            break;
          }
          edge = lookupEdgeFromCorner(q, q.downslope);
          edge.river = edge.river + 1;
          q.river = (q.river || 0) + 1;
          q.downslope.river = (q.downslope.river || 0) + 1; // TODO: fix double count
          q = q.downslope;
        }
      }
    }


    // Calculate moisture. Freshwater sources spread moisture: rivers
    // and lakes (not oceans). Saltwater sources have moisture but do
    // not spread it (we set it at the end, after propagation).
    public function assignCornerMoisture():void {
      var q:Corner, r:Corner, newMoisture:Number;
      var queue:Array = [];
      // Fresh water
      for each (q in corners) {
          if ((q.water || q.river > 0) && !q.ocean) {
            q.moisture = q.river > 0? Math.min(3.0, (0.2 * q.river)) : 1.0;
            queue.push(q);
          } else {
            q.moisture = 0.0;
          }
        }
      while (queue.length > 0) {
        q = queue.shift();

        for each (r in q.adjacent) {
            newMoisture = q.moisture * 0.9;
            if (newMoisture > r.moisture) {
              r.moisture = newMoisture;
              queue.push(r);
            }
          }
      }
      // Salt water
      for each (q in corners) {
          if (q.ocean || q.coast) {
            q.moisture = 1.0;
          }
        }
    }


    // Polygon moisture is the average of the moisture at corners
    public function assignPolygonMoisture():void {
      var p:Center, q:Corner, sumMoisture:Number;
      for each (p in centers) {
          sumMoisture = 0.0;
          for each (q in p.corners) {
              if (q.moisture > 1.0) q.moisture = 1.0;
              sumMoisture += q.moisture;
            }
          p.moisture = sumMoisture / p.corners.length;
        }
    }


    // Assign a biome type to each polygon. If it has
    // ocean/coast/water, then that's the biome; otherwise it depends
    // on low/high elevation and low/medium/high moisture. This is
    // roughly based on the Whittaker diagram but adapted to fit the
    // needs of the island map generator.
    static public function getBiome(p:Center):String {
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
    
    public function assignBiomes():void {
      var p:Center;
      for each (p in centers) {
          p.biome = getBiome(p);
        }
    }


    // Look up a Voronoi Edge object given two adjacent Voronoi
    // polygons, or two adjacent Voronoi corners
    public function lookupEdgeFromCenter(p:Center, r:Center):Edge {
      for each (var edge:Edge in p.borders) {
          if (edge.d0 == r || edge.d1 == r) return edge;
        }
      return null;
    }

    public function lookupEdgeFromCorner(q:Corner, s:Corner):Edge {
      for each (var edge:Edge in q.protrudes) {
          if (edge.v0 == s || edge.v1 == s) return edge;
        }
      return null;
    }

    
    // Determine whether a given point should be on the island or in the water.
    public function inside(p:Point):Boolean {
      return islandShape(new Point(2*(p.x/SIZE - 0.5), 2*(p.y/SIZE - 0.5)));
    }
  }
}


// Factory class to build the 'inside' function that tells us whether
// a point should be on the island or in the water.
import flash.geom.Point;
import flash.display.BitmapData;
import de.polygonal.math.PM_PRNG;
class IslandShape {
  // This class has factory functions for generating islands of
  // different shapes. The factory returns a function that takes a
  // normalized point (x and y are -1 to +1) and returns true if the
  // point should be on the island, and false if it should be water
  // (lake or ocean).

  
  // The radial island radius is based on overlapping sine waves
  static public var ISLAND_FACTOR:Number = 1.07; // 1.0 means no small islands; 2.0 leads to a lot
  static public function makeRadial(seed:int):Function {
    var islandRandom:PM_PRNG = new PM_PRNG();
    islandRandom.seed = seed;
    var bumps:int = islandRandom.nextIntRange(1, 6);
    var startAngle:Number = islandRandom.nextDoubleRange(0, 2*Math.PI);
    var dipAngle:Number = islandRandom.nextDoubleRange(0, 2*Math.PI);
    var dipWidth:Number = islandRandom.nextDoubleRange(0.2, 0.7);
    
    function inside(q:Point):Boolean {
      var angle:Number = Math.atan2(q.y, q.x);
      var length:Number = 0.5 * (Math.max(Math.abs(q.x), Math.abs(q.y)) + q.length);

      var r1:Number = 0.5 + 0.40*Math.sin(startAngle + bumps*angle + Math.cos((bumps+3)*angle));
      var r2:Number = 0.7 - 0.20*Math.sin(startAngle + bumps*angle - Math.sin((bumps+2)*angle));
      if (Math.abs(angle - dipAngle) < dipWidth
          || Math.abs(angle - dipAngle + 2*Math.PI) < dipWidth
          || Math.abs(angle - dipAngle - 2*Math.PI) < dipWidth) {
        r1 = r2 = 0.2;
      }
      return (length < r1 || (length > r1*ISLAND_FACTOR && length < r2));
    }

    return inside;
  }


  // The Perlin-based island combines perlin noise with the radius
  static public function makePerlin(seed:int):Function {
    var perlin:BitmapData = new BitmapData(256, 256);
    perlin.perlinNoise(64, 64, 8, seed, false, true);
    
    return function (q:Point):Boolean {
      var c:Number = (perlin.getPixel(int((q.x+1)*128), int((q.y+1)*128)) & 0xff) / 255.0;
      return c > (0.3+0.3*q.length*q.length);
    };
  }


  
}

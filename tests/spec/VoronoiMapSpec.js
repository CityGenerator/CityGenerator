

describe("VoronoiMap", function() {

    var voronoimap;

  beforeEach(function() {
    voronoimap=new VoronoiMap(500,500,1000);
  });


  it("should have a width of 500", function() {
    expect(voronoimap.width).toBe(500);
  });
  it("should have a height of 500", function() {
    expect(voronoimap.height).toBe(500);
  });
  it("should have a xmultiplier of 1 then 5, then 7", function() {
    expect(voronoimap.xmultiplier).toBe(1);
    voronoimap.setMultiplier(5)
    expect(voronoimap.xmultiplier).toBe(5);
    voronoimap.setMultiplier(7,1)
    expect(voronoimap.xmultiplier).toBe(7);
  });
  it("should have a ymultiplier of 1, then 5, then 1", function() {
    expect(voronoimap.ymultiplier).toBe(1);
    voronoimap.setMultiplier(5)
    expect(voronoimap.ymultiplier).toBe(5);
    voronoimap.setMultiplier(7,1);                // 7 is set for the x multiplier
    expect(voronoimap.ymultiplier).toBe(1);
  });

  it("should have a xoffset of 0", function() {
    expect(voronoimap.xoffset).toBe(0);
  });
  it("should have a yoffset of 0", function() {
    expect(voronoimap.yoffset).toBe(0);
  });

  it("should have 13 colors", function() {
    expect(voronoimap.colors.length).toBe(13);
    expect(voronoimap.colors[0]).toEqual('255,105,100');
  });





	//    this.num_lloyd_iterations=2;
	//    this.voronoi = new Voronoi();
	//
	//    this.points=this.generateRandomPoints(num_points);
	//
	//    this.buildGraph();
	//    this.improveRandomPoints();


});

public class DetailedView extends PApplet {
  ControlP5 cp5;
  Chart [] bars = new Chart[3];
  
  public void setup() {
    cp5 = new ControlP5(this);
  }
  
  public void draw() {
    background(backgroundcol);
    if ( updateForDetailed ) { update(); }
    if ( bars[0] != null ) { 
      School [] activeSchools = controller.getActiveSchools();
      for ( int i = 0 ; i < activeSchools.length ; i++ ) {
        try {
        bars[0]
          .unshift("incoming", 
            controller.dataPoint( activeSchools[i], controller.filters[controller.selectedFilter[0]]));
        } catch (Exception ex) {
          // skip
        }
      }
    }
    //bars[0].push("incoming", (sin(frameCount*0.1)*10));

  }
  
  public void update() {
    if ( controller.selectedFilter[0] != -1 )  {
      initBar(0, controller.filters[controller.selectedFilter[0]]);
    }
    updateForDetailed = false;
  }
  
  public void initBar( int barsi, Filter filt ) {
    if ( bars[barsi] != null ) {
      bars[barsi].remove();
    }
    School [] activeSchools = controller.getActiveSchools();
    float [] lowhi = controller.lowAndHighFor( activeSchools, filt );
    bars[barsi] = cp5.addChart(filt.getDisplayName())
              .setCaptionLabel(filt.getDisplayName())
              .setPosition(10 + barsi*width/3, 10)
              .setRange(lowhi[0],lowhi[1])
              .setSize((int) width/3 - 20, height-20)
              .setView(Chart.BAR_CENTERED)
              .setStrokeWeight(1.5)
              .setColorCaptionLabel(color(40))
              ;
    bars[barsi].addDataSet("incoming");
    bars[barsi].setData("incoming", new float[activeSchools.length]);
    for ( int i = 0 ; i < activeSchools.length ; i++ ) {
      try {
        bars[barsi]
          .unshift("incoming", controller.dataPoint( activeSchools[i], filt ));
      } catch (Exception ex) {
          // skip
      }
    }
  }
  
}

/*
class BarChart {
  float xmin, ymin, xmax, ymax, xsize, ysize; 
  Filter filt = null;
  
  BarChart(float xmin, float ymin, float xmax, float ymax, Filter filt) {
    this.xmin = xmin;
    this.ymin = ymin;
    this.xmax = xmax;
    this.ymax = ymax;
    this.filt = filt;
    xsize = xmax - xmin;
    ysize = ymax - ymin;
  }
  
  boolean ready() { return filt != null; }
  
  public void draw() {
    stroke(153);
    line(xsize * 0.2, ysize - (ysize * 0.2), xsize * 0.2, ysize * 0.2);
    line(xsize * 0.2, ysize - (ysize * 0.2), xsize - (xsize * 0.2), ysize - (ysize * 0.2));
    
    fill(128,128,128);
    textAlign(CENTER);
    text(filt.getDisplayName(), xsize/2, ysize * 0.98);
    //text("", xsize * 0.05, ysize/2);
  }
}*/





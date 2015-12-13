public class DetailedView extends PApplet {
  
  class BarChart {
    float xmin, ymin, xmax, ymax, xsize, ysize;  
    boolean initialized = false;
    boolean filterChanged = false;
    float [] lowHi = new float[2];
    Filter filt = null;
    School [] activeSchools = null;
    
    BarChart() {
      // remains unitialized      
    }
    
    BarChart(float xmin, float ymin, float xsize, float ysize, Filter filt) {
      initialize(  xmin,  ymin,  xsize,  ysize, filt );      
    }
    
    public void initialize( float xmin, float ymin, float xsize, float ysize, Filter filt) {
      this.xmin = xmin;
      this.ymin = ymin;
      xmax = xmin + xsize;
      ymax = ymin + ysize;
      this.filt = filt;
      this.xsize = xsize;
      this.ysize = ysize;
      getFiltVals();
      initialized = true;
    }
    
    private void getFiltVals() {
      activeSchools = controller.getActiveSchools();
      lowHi = controller.lowAndHighFor( activeSchools, filt );
    }
    
    public void draw() {
      pushMatrix();
      translate(xmin,0);
      innerdraw();
      popMatrix();
    }
    
    private void innerdraw() {
      // draw axis
      stroke(153);
      strokeWeight(1);
      line(xsize * 0.2, ysize - (ysize * 0.2), xsize * 0.2, ysize * 0.2);
      line(xsize * 0.2, ysize - (ysize * 0.2), xsize - (xsize * 0.2), ysize*0.8);
      
      // draw chart label
      fill(128,128,128);
      textAlign(CENTER);
      textSize(14);
      text(filt.getDisplayName(), xsize/2, ysize * 0.8 + 20);
      //text("", xsize * 0.05, ysize/2);
      
      
      float xdistance = xsize * 0.6 / activeSchools.length;
      float xstart = xsize * 0.2;
      float ydistance = ysize * 0.6 / lowHi[1];
      float ystart = ysize * 0.8;
      float barsize = (xsize * 0.6) / (activeSchools.length * 1.5);
      
      // vertical labels
      fill(10,10,10);
      textAlign(RIGHT);
      
      int ticks = 5;
      for( int i = 0; i <= ticks; i++ ) {
        float val = i * lowHi[1] / ticks;
        String vallab = ""; 
        if       ( filt.getType() == 1 )  { vallab += ((int) val);      }
        else if  ( filt.getType() == 2)   { vallab += ((int) (val*100)) + "%";  }
        else                              { vallab += val;              }
        textSize(13); 
        text( vallab, xsize * 0.15, ysize * 0.8 - (i * ysize * 0.6 / ticks) );
      }
      
      /*******   draw bars    ******/
      // mouse location adjusted for scan and zoom
      float transX = (mouseX - leftshift) / zoom ; 
      float transY = (mouseY - topshift) / zoom ;
      xstart = xstart + (barsize/4);
      for ( int i = 0; i < activeSchools.length; i++ ) {
        float xloc = xstart + xdistance * i;
        float ysize;
        float datapoint;
        try {
          datapoint = controller.dataPoint(activeSchools[i], filt);
          ysize = ydistance * datapoint * -1;
        } catch (Exception ex) {
          datapoint = MIN_FLOAT;
          ysize = 0;
        }
        //if mouse over this bar
        if ( transX >= xmin + xloc && transX <= xmin + xloc + barsize 
          && transY >= ystart + ysize && transY <= ystart ) {
          fill( color(255,255,0) );  
        } else {
          fill( activeSchools[i].col );
        }
        rect(xloc, ystart, barsize, ysize);
      }
      // second loop so words appear on top
      for ( int i = 0; i < activeSchools.length; i++ ) {
        float xloc = xstart + xdistance * i;
        float ysize;
        float datapoint;
        try {
          datapoint = controller.dataPoint(activeSchools[i], filt);
          ysize = ydistance * datapoint * -1;
        } catch (Exception ex) {
          datapoint = MIN_FLOAT;
          ysize = 0;
        }
        //if mouse over this bar
        if ( transX >= xmin + xloc && transX <= xmin + xloc + barsize 
          && transY >= ystart + ysize && transY <= ystart ) {
            String valuepair = "(" + activeSchools[i].name + ",";
            if (datapoint == MIN_FLOAT) {
              valuepair += "value not in data" +")";  
            } else { 
              valuepair += datapoint + ")";
            }
            fill(10,10,10);
            textAlign(CENTER);
            text(valuepair, xloc + barsize/2, ystart + ysize - xdistance/4);
        }
      }
      
      // horizontal labels
      fill(10,10,10);
      textAlign(RIGHT);
      for( int i = 0; i < activeSchools.length ; i++ ) {
        float x = xsize * 0.2 + (xdistance * i) + (barsize * 0.75) + 2;
        float y = ysize *0.89;
        pushMatrix();
        translate(x,y);
        rotate(HALF_PI *3);
        textSize(9);
        text( activeSchools[i].name, 0, 0);
        popMatrix();
      }
      
    }
  }
  
  BarChart [] barcharts = new BarChart[] {
    new BarChart(), new BarChart(), new BarChart()
  };
  
  float zoom       = 1;
  float leftshift  = 0;
  float topshift = 0;
  int startX, startY;
  int moveAction = 0; //0 = zoom, 1 = scan
  
  public void setup() {
    size(displayWidth,(int)(displayHeight*0.37));
  }
  
  public void mousePressed() {
    startX = mouseX;
    startY = mouseY;
    if (  25 > sqrt( sq(mouseX - (width - 60)) + sq(mouseY - ((height-22)/2 - 72)))) {
      moveAction = 0; // zoom
    } else if (  25 > sqrt( sq(mouseX - (width - 60)) + sq(mouseY - ((height-22) - 92)))) {
      moveAction = 1; // scan
    }
  }
  public void mouseDragged() {
    float dx = mouseX - startX;
    float dy = mouseY - startY;
    switch (moveAction) {
      case 0:  
        zoom += dy / 100.0;
        break;
      case 1: 
        leftshift += dx; 
        topshift += dy; 
        break;
      case -1:
        // do nothing
        break;
    }   
    startX = mouseX;
    startY = mouseY; 
  }
  
  public void draw() {
    if ( updateForDetailed ) {
      for ( int i = 0; i < barcharts.length; i++ ) {
        if  ( controller.selectedFilters[i] != -1 )  {
          float windowSize = width/((float) barcharts.length) - (70 / barcharts.length);
          float chartWidth = windowSize - 20;
          barcharts[i].initialize(10 + i*windowSize, 
                10, 
                chartWidth, 
                height-60, 
                controller.filters[controller.selectedFilters[i]]);
        }
      }
      updateForDetailed = false;
    }
    pushMatrix();
    background(backgroundcol);
    scale(zoom);
    // translation with a centered zoom
    translate(leftshift - (zoom-1)*width/(zoom*2), 
               topshift - (zoom-1)*height/(zoom*2));
    
    
    for ( int i = 0; i < barcharts.length; i++ ) {
      if ( barcharts[i].initialized ) {
        barcharts[i].draw();
      } else if  ( controller.selectedFilters[i] != -1 )  {
        float windowSize = width/((float) barcharts.length) - (120 / barcharts.length);
        float chartWidth = windowSize - 20;
        barcharts[i].initialize(10 + i*windowSize, 
              10, 
              chartWidth, 
              height-60, 
              controller.filters[controller.selectedFilters[i]]);
      }
    } // end for
    popMatrix();
    drawControls();
    
  }
  
  private void drawControls() {
    fill( backgroundcol ); 
    stroke( color(25,0,75));
    strokeWeight(2);
    rect(width - 110, 10, 100, height - 20, 10);
    
    fill(10,10,10);
    textSize(27);
    textAlign(CENTER);
    text("Zoom", width - 60, (height-22)/2 - 12 );
    text("Scan", width - 60, (height-22) - 32 );
    
    
    
    // zoom
    if ( moveAction == 0 ) { fill(255,255,0); } else { fill(110,70,110); }
    if (  25 > sqrt( sq(mouseX - (width - 60)) + sq(mouseY - ((height-22)/2 - 72)))) {
      strokeWeight(2);
      stroke(10,200,27);
    } else {
      strokeWeight(1);
      stroke(110,78,128);    
    }
    ellipse(width - 60, (height-22)/2 - 72, 50, 50 );
    
    // scan
    if ( moveAction == 1) { fill(255,255,0); } else { fill(110,70,110); }
    if (  25 > sqrt( sq(mouseX - (width - 60)) + sq(mouseY - ((height-22) - 92)))) {
      strokeWeight(2);
      stroke(10,200,27);
    } else {
      strokeWeight(1);
      stroke(110,78,128);
    }  
    ellipse(width - 60, (height-22)   - 92, 50, 50 );
    
       
  }
  
} 
// end detailed view class
  /*
  
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
*/









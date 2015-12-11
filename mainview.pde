public class MainView extends PApplet {
  Filter [] filters;
  School [] schools;
  
  int leftMar   = 100;
  int rightMar  = 100;
  int xmargin   = leftMar + rightMar;
  int topMar    = 70;
  int botMar    = 70;
  int ymargin   = topMar + botMar;
  
  color primary    = color(7,33,190);
  color secondary  = color(7,33,190);
  
  public void setup() {
    schools = controller.getActiveSchools();
    filters = controller.getActiveFilters();        
  }
  
  public void draw() {
    if (updateForMain) update();
    background(255);
    drawDataBars();
    drawCurves();
  }
  
  public void update() {
    schools = controller.getActiveSchools();
    filters = controller.getActiveFilters();
    updateForMain = false; 
  }
  
  void drawDataBars() {
    float distance = (width - xmargin)  / filters.length;
    float wide     = distance/4.0;
    float tall     = height - ymargin; 
    strokeWeight(1);
    stroke(primary);
    for ( int i = 0; i < filters.length ; i++ ) {
      // draw the bar
      noFill();
      float left = leftMar + i*distance + wide;
      rect(left, topMar, wide, tall, 22);
      // draw the low and high values
      float [] vals = controller.lowAndHighFor( schools, filters[i] );
      fill(textcol);
      textAlign(CENTER);
      textSize(14);
      text(vals[1], left+wide/2, topMar-20);
      text(vals[0]+"\n"+filters[i].getDisplayName(), left+wide/2, topMar+tall+20);
    }
  }
  void drawCurves() {
    float distance = (width - xmargin)  / filters.length;
    float start    = leftMar + distance*0.375;
    float tall     = height - ymargin; 
    noFill();
    for ( int i = 0 ; i < schools.length ; i++ ) {
      strokeWeight(2);
      stroke(schools[i].col);
      for ( int j = 0 ; j < filters.length-1 ; j++ ) {
        try {
          float left = start + j*distance;
          float [] vals1   = controller.lowAndHighFor( schools, filters[j] );
          float lowVal1    = vals1[0];
          float highVal1   = vals1[1];
          float pointVal1  = controller.dataPoint( schools[i], filters[j] );
          float scaledVal1;
          if ( highVal1 - lowVal1 == 0 ) {
            scaledVal1 = tall/2;
          } else {
            scaledVal1 = tall * (pointVal1 - lowVal1) / (highVal1 - lowVal1);
          }
          float [] vals2   = controller.lowAndHighFor( schools, filters[j+1] );
          float lowVal2    = vals2[0];
          float highVal2   = vals2[1];
          float pointVal2  = controller.dataPoint( schools[i], filters[j+1] );
          float scaledVal2;
          if ( highVal2 - lowVal2 == 0 ) {
            scaledVal2 = tall/2;
          } else {
            scaledVal2 = tall * (pointVal2 -lowVal2) / (highVal2 - lowVal2);
          }
          float delta      = scaledVal2 - scaledVal1;
          bezier(left,  height - (botMar+scaledVal1), 
              left+distance*0.25, height - (botMar+scaledVal1+delta), 
              left+distance*0.75, height - (botMar+scaledVal2-delta), 
              left+distance, height - (botMar+scaledVal2) );
        } catch (Exception ex) {
          if (DEBUG) println("No data for " + schools[i].name + " for field " + filters[j].getQName());
        }
      } // end for j
    } // end for i
  }
  
}


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
  color secondary  = color(0,100,255);
  
  boolean useDataLess = true;             // should we show empty filters
  String caption = "";                    // caption for empty filter toggle
  float captionWidth;
  
  public void setup() {
    textSize(14);
    captionWidth = textWidth("Drop empty");
    update();    
  }
  
  public void draw() {
    if (updateForMain) update();
    background(backgroundcol);
    drawData();
    drawDropButton();
  }
  
  boolean clickToggled() {
    if ( mouseX > width-(captionWidth+40) 
    && mouseX < width-(captionWidth+40) + 150 
    && mouseY > 150 
    && mouseY < 184) {
      useDataLess = !useDataLess;
      updateForMain = true;
      return true;
    } else {
      return false;
    }  
  }
  
  void drawDropButton() { 
    
    fill(primary);
    if ( mouseX > width-(captionWidth+40) 
    && mouseX < width-(captionWidth+40) + 150 
    && mouseY > 150 
    && mouseY < 184) { 
      strokeWeight(3);
      stroke(highlightStrokeCol);
      fill(primary);
    } else {
      strokeWeight(1);
      stroke(secondary);
    }
    rect(width-(captionWidth+40), 150, captionWidth+20, 34);
    
    textSize(14);
    textAlign(CENTER);
    fill(255);
    text(caption, width-(captionWidth/2 + 30), 170);
  }
  
  public void update() {
    schools  = controller.getActiveSchools();
    filters  = controller.getActiveFilters();
    if (useDataLess) {
      caption = "Keep empty";      
    } else {
      filters = dataFullFilters();
      caption = "Drop empty";
    }
    updateForMain = false; 
  }
  
  void mouseClicked() {
    if ( clickToggled() ) {
      return;
    }
    float distance = (width - xmargin)  / filters.length;
    float wide     = distance/4.0;
    float tall     = height - ymargin;
    for ( int i = 0; i < filters.length ; i++ ) {
      float left = leftMar + i*distance + wide;
      if ( mouseX > left && mouseX < left+wide
        && mouseY > topMar && mouseY < topMar+tall) {
          controller.selectedFilters[controller.next] = controller.getFilterIndex(filters[i]);
          controller.next++;
          if ( controller.next >= controller.selectedFilters.length ) {
            controller.next = 0;
          }
          updateForDetailed = true;
        }
    }
  }
  
  Filter [] dataFullFilters() {
    ArrayList<Filter> datafull = new ArrayList<Filter>();
    for( int i = 0; i < filters.length; i++ ) {
      if ( controller.schoolsHaveData(schools, filters[i]) ) {
        datafull.add(filters[i]);
      }
    }
    return datafull.toArray(new Filter[0]);
  }
  
  void drawData() {

    float distance = (width - xmargin)  / filters.length;
    float wide     = distance/8.0;
    float tall     = height - ymargin; 
    
    // draw each of the data bars
    for ( int i = 0; i < filters.length ; i++ ) {
      // draw the bar
      float left = leftMar + i*distance + 2.5*wide;
      if ( mouseX > left && mouseX < left+wide  ) {
        strokeWeight(2);
        stroke(highlightStrokeCol);
      } else {
        strokeWeight(1);
        stroke(primary);
      }
      noFill();
      rect(left, topMar, wide, tall, 22);
      // draw the low and high values
      float [] vals = controller.lowAndHighFor( schools, filters[i] );
      fill(textcol);
      textAlign(CENTER);
      textSize(14);
      if (filters[i].getType() == 1) {
        text(((int)vals[1]), left+wide/2, topMar-20);
        text(((int)vals[0])+"\n"+filters[i].getDisplayName(), left+wide/2, topMar+tall+20);
      } else if (filters[i].getType() == 2) {
        text((100*vals[1])+"%", left+wide/2, topMar-20);
        text((100*vals[0])+"%\n"+filters[i].getDisplayName(), left+wide/2, topMar+tall+20);
      } else {
        text(vals[1], left+wide/2, topMar-20);
        text(vals[0]+"\n"+filters[i].getDisplayName(), left+wide/2, topMar+tall+20);
      }
    }
    drawCurves( distance, tall, wide );
  }
  
  void drawCurves(float distance, float tall, float wide) {

    float start    = leftMar + distance*0.375;

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
              left+distance*0.35,  height - (botMar+scaledVal2),
              left+distance*0.65,  height - (botMar+scaledVal1),
              left+distance, height - (botMar+scaledVal2));
          //bezier(left,  height - (botMar+scaledVal1), 
          //    left+distance*0.35, height - (botMar+scaledVal1+delta), 
          //    left+distance*0.65, height - (botMar+scaledVal2-delta), 
          //    left+distance, height - (botMar+scaledVal2) );
        } catch (Exception ex) {
          if (DEBUG) println("No data for " + schools[i].name + " for field " + filters[j].getQName());
        }
      } // end for j
    } // end for i
  }
  
}



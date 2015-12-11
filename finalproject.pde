import http.requests.*;
import javax.swing.*;
import controlP5.*;

boolean DEBUG = false;
ControlP5 cp5;
Controller controller = new Controller();
color textcol = color(0,0,0);
color bcol1 = color(100,1,1);
color bcol2 = color(200,100,100);

color [] schoolcols = {color(100,170,106),color(179,112,206),color(197,87,127), color(176,154,60),
                       color(102,187,188),color(148,217,77) ,color(130,134,179),color(65,45,110),
                       color(200,170,106),color(179,212,206),color(197,187,127),color(0,154,100),
                       color(202,187,128),color(148,17,77)  ,color(130,34,179),
                    color(200,170,6),color(179,12,236),color(107,57,107), color(206,104,0),
                       color(202,187,8),color(48,217,177) ,color(230,104,179),color(65,45,110),
                       color(200,20,16),color(179,212,206),color(97,107,157)};

boolean updateForMain = false;
boolean updateForDetailed = false;

void setup() {
  
  size(displayWidth,(int)(displayHeight*0.25)); 
  smooth();
  cp5 = new ControlP5(this);
  cp5.addSlider("slider")
    .setPosition(30,10)
    .setWidth(width-60)
    .setHeight((int)(height*0.15))
    .setRange(controller.years[0], controller.years[controller.years.length-1])
    .setDecimalPrecision(0)
    .setSliderMode(Slider.FLEXIBLE);
    
    int distance = (width - 60)/controller.schools.length;
    int buttonwidth = (int)(distance*0.85);
    for( int i = 0 ; i < controller.schools.length ; i++ ) {
      cp5.addButton(controller.schools[i].name)
       .setValue(i)
       .setPosition((distance*0.07) + 30 + i*distance ,(int)(height*0.25))
       .setColorBackground( schoolcols[i] )
       .setSwitch(true)
       .setColorActive(100)
       .setSize(buttonwidth,20)
       ;
     }
  // reposition the Label for controller 'slider'
  //cp5.getController("slider").getValueLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  //cp5.getController("slider").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);  
    
  // Create other views
  new PFrame(new DetailedView(),0,(int)(displayHeight*0.02),displayWidth,(int)(displayHeight*0.27) ); 
  new PFrame(new MainView(),    0,(int)(displayHeight*0.30),displayWidth,(int)(displayHeight*0.30) );
  
  //println(controller.json);
  //JSONArray values = controller.json.getJSONArray("results");
  //JSONObject results = values.getJSONObject(0);
}

void draw() {
  background(255); 
}

void slider(float val) {
  controller.selectedYear = val;
}


public void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getName() + (int)theEvent.getController().getValue() );
  String schoolname = theEvent.getController().getName();
  int schoolindex = (int)theEvent.getController().getValue();
  if ( controller.schools.length > schoolindex 
    && schoolname == controller.schools[schoolindex].name) {
      controller.toggleSchool(schoolindex);
  }
} 


public class PFrame extends JFrame {
  public PFrame(PApplet s, int left, int top, int w, int h) {
    setBounds(left, top, w, h);
    setUndecorated(true); 
    add(s);   
    s.init();
    show();
  }
}


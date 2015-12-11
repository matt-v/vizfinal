import http.requests.*;
import javax.swing.*;
import controlP5.*;

ControlP5 cp5;
boolean DEBUG = false;

color textcol = color(0,0,0);
color bcol1 = color(100,1,1);
color bcol2 = color(200,100,100);

VController controller = new VController();

boolean updateForMain = false;
boolean updateForDetailed = false;

Button [] filtButs = new Button [controller.filters.length];

void setup() {
  
  size(displayWidth,(int)(displayHeight*0.25)); 
  smooth();
  cp5 = new ControlP5(this);
  
  /**** INITIALIZING SLIDER ******/
  cp5.addSlider("slider")
    .setPosition(30,10)
    .setWidth(width-60)
    .setHeight((int)(height*0.15))
    .setRange(controller.years[0], controller.years[controller.years.length-1])
    .setDecimalPrecision(0)
    .setSliderMode(Slider.FLEXIBLE);
    
    /**** INITIALIZING SCHOOL BUTTONS ******/
    CallbackListener clickschool = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        int schoolindex = (int)theEvent.getController().getValue();
        controller.toggleSchool(schoolindex);
      }
    }; 
    int distance = (width - 60)/controller.schools.length;
    int buttonwidth = (int)(distance*0.85);
    for( int i = 0 ; i < controller.schools.length ; i++ ) {
      cp5.addButton(controller.schools[i].name)
       .setValue(i)
       .setPosition((distance*0.07) + 30 + i*distance ,(int)(height*0.25))
       .setColorBackground( 100 )
       .setSwitch(true)
       .setColorActive(controller.schools[i].col)
       .setSize(buttonwidth,20)
       .onClick(clickschool)
       ;
     }
     
     /**** INITIALIZING FILTER BUTTONS ******/
     distance = (width - 60)/controller.filters.length;
     buttonwidth = (int)(distance*0.85);
     CallbackListener ondrag = new CallbackListener() {
       public void controlEvent( CallbackEvent theEvent ) {
         Controller fbut = theEvent.getController();
         fbut.setPosition(mouseX-(fbut.getWidth()/2), mouseY-(fbut.getHeight()/2));
       }
     };
     CallbackListener ondragend = new CallbackListener() {
       public void controlEvent( CallbackEvent theEvent ) {
         int distance = (width - 60)/controller.filters.length;
         int buttonwidth = (int)(distance*0.85);
         Controller fbut = theEvent.getController();
         int filtindex = (int) fbut.getValue();
         boolean foundLocation = false;
         for( int i = 0 ; i < controller.filters.length ; i++ ) {
           float leftx = (distance*0.07) + 30 + i*distance;
           // if this filter button is within the x bounds of a filter location
           if ( mouseX > leftx && mouseX < leftx + buttonwidth ) {
             foundLocation = true;
             fbut.setPosition((distance*0.07) + 30 + i*distance,(int)(height*0.5));
             if ( i != filtindex ) {
               fbut.setValue(i);
               filtButs[filtindex]
                 .setPosition((distance*0.07) + 30 + filtindex*distance,(int)(height*0.5))
                 .setValue(filtindex);
               controller.swapFilters(i, filtindex);
               
             }
           }
         }
         if ( !foundLocation ) { 
           fbut.setPosition((distance*0.07) + 30 + filtindex*distance,(int)(height*0.5));
         }
       }
     };
          
     for( int i = 0 ; i < controller.filters.length ; i++ ) {
       filtButs[i] = cp5.addButton(controller.filters[i].getDisplayName())
       .setPosition((distance*0.07) + 30 + i*distance,(int)(height*0.5))
       .setSwitch(true)
       .setOn()
       .setValue(i)
       .setSize(buttonwidth,20)
       .onDrag(ondrag)
       .onEndDrag(ondragend)
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


public class PFrame extends JFrame {
  public PFrame(PApplet s, int left, int top, int w, int h) {
    setBounds(left, top, w, h);
    setUndecorated(true); 
    add(s);   
    s.init();
    show();
  }
}


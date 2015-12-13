import http.requests.*;
import javax.swing.*;
import controlP5.*;

ControlP5 cp5;
boolean DEBUG = false;

color textcol = color(0,0,0);
color backgroundcol = color(245,245,245);
color filtOnCol     = color(44,32,147);
color filtOffCol    = color(44,32,67);
color filtActiveCol = color(84,52,87);
// our controller, for filter/school/slider changes
// additionally, that's where the school & filter classes are
// It's a little confusing since, controlP5 uses the same name for it's
// event handler. Oops.
VController controller = new VController();

// whether there are updates pending (each window get a flag)
boolean updateForMain = false;
boolean updateForDetailed = false;
boolean updateForControlView = false;

// for mouse click and drag
boolean dragflag = false;

void setup() {
  
  size(displayWidth,(int)(displayHeight*0.20)); 
  smooth();
  cp5 = new ControlP5(this);
  
  /**** INITIALIZING SLIDER ******/
  cp5.addSlider("slider")
    .setPosition(30,10)
    .setWidth(width-60)
    .setHeight((int)(height*0.15))
    .setRange(controller.years[0], controller.years[controller.years.length-1])
    .setValue(2010)
    .setDecimalPrecision(0)
    .setSliderMode(Slider.FLEXIBLE);
    
    /**** INITIALIZING SCHOOL BUTTONS ******/
    CallbackListener pressschool = new CallbackListener() {
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
       .setSwitch(true).setOn()
       .setColorActive(controller.schools[i].col)
       .setSize(buttonwidth,20)
       .onPress(pressschool)
       ;
     }
     
     /**** INITIALIZING FILTER BUTTONS ******/
     distance = (width - 60)/controller.filters.length;
     buttonwidth = (int)(distance*0.85);
     CallbackListener onclickfilt = new CallbackListener() {
       public void controlEvent( CallbackEvent theEvent ) {
         dragflag = false;
       }
     };
     CallbackListener onreleasefilt = new CallbackListener() {
       public void controlEvent( CallbackEvent theEvent ) {
         if ( !dragflag ) {
           // I promise this cast is safe (we only use buttons)
           // if we put another controller in the filter class
           // we'd have a problem...
           Button fbut = (Button) theEvent.getController();
           int index = controller.getFilterIndex( fbut );
           controller.toggleFilter(index);
         }
       }
     };
     
     CallbackListener ondrag = new CallbackListener() {
       public void controlEvent( CallbackEvent theEvent ) {
         dragflag = true;
         Controller fbut = theEvent.getController();
         fbut.setPosition(mouseX-(fbut.getWidth()/2), mouseY-(fbut.getHeight()/2));
       }
     };
     // draggable filter buttons 
     CallbackListener ondragend = new CallbackListener() {
       public void controlEvent( CallbackEvent theEvent ) {
         int distance = (width - 60)/controller.filters.length;
         int buttonwidth = (int)(distance*0.85);
         Controller fbut = theEvent.getController();
         int currindex = controller.getFilterIndex( fbut );
         boolean foundLocation = false;
         for( int i = 0 ; i < controller.filters.length ; i++ ) {
           float leftx = (distance*0.07) + 30 + i*distance;
           // if this filter button is within the x bounds of a filter location
           if ( mouseX > leftx && mouseX < leftx + buttonwidth ) {
             foundLocation = true;
             //if ( i != currindex ) { controller.swapFilters(i, currindex); }
             controller.swapFilters(i, currindex);
           }
         }
         if ( !foundLocation ) { 
           fbut.setPosition((distance*0.07) + 30 + currindex*distance,(int)(height*0.5));
         }
       }
     };
          
     /* link buttons to filters, so the controller knows what buttons need to move
      * with what fitler when they're dragged */     
     for( int i = 0 ; i < controller.filters.length ; i++ ) {
       controller.filters[i].linkButton(
         cp5.addButton(controller.filters[i].getDisplayName())
           .setPosition((distance*0.07) + 30 + i*distance,(int)(height*0.5))
           .setSize(buttonwidth,20)
           .onDrag(ondrag)
           .onEndDrag(ondragend)
           .onClick(onclickfilt)
           .setColorBackground( filtOnCol )
           .onRelease(onreleasefilt));
     }
  // reposition the Label for controller 'slider'
  //cp5.getController("slider").getValueLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  //cp5.getController("slider").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);  
    
  // Create other views
  new PFrame(new DetailedView(),0,(int)(displayHeight*0.02),displayWidth,(int)(displayHeight*0.37) ); 
  new PFrame(new MainView(),    0,(int)(displayHeight*0.40),displayWidth,(int)(displayHeight*0.30) );
  
}

void draw() {
  if ( updateForControlView ) {
    update();
  }
  background(backgroundcol); 
  int distance = (width - 60)/controller.filters.length;
  int buttonwidth = (int)(distance*0.85);
  for( int i = 0 ; i < controller.filters.length ; i++ ) {
         fill(128);
         stroke(100);
         rect((distance*0.07) + 28 + i*distance,(height * 0.5) - 2, buttonwidth + 4, 24);
  }
}

void update() {
  int distance = (width - 60)/controller.filters.length;
  int buttonwidth = (int)(distance*0.85);
  for( int i = 0 ; i < controller.filters.length ; i++ ) {
    color fcol;
    if ( controller.filters[i].isChecked() ) {
      fcol = filtOnCol;
    } else {
      fcol = filtOffCol; 
    }
    controller.filters[i].fbutton
     .setColorBackground(fcol)
     .setPosition((distance*0.07) + 30 + i*distance,(int)(height*0.5));
  }
  updateForControlView = false;   
}

void slider(float val) {
  controller.selectedYear = val;
}


/* makes additional windows */
public class PFrame extends JFrame {
  public PFrame(PApplet s, int left, int top, int w, int h) {
    setBounds(left, top, w, h);
    setUndecorated(true); 
    add(s);   
    s.init();
    show();
  }
}


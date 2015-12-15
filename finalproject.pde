import http.requests.*;
import javax.swing.*;
import controlP5.*;

ControlP5 cp5;
DropdownList d1;
boolean DEBUG = false;

color textcol            = color(10,10,10);
color controlButtonCol   = color(128,128,128);
color backgroundcol      = color(253,254,252);
color filtOnCol          = color(44,32,147);
color filtOffCol         = color(44,32,67);
color filtActiveCol      = color(84,52,87);
color highlightCol       = color(255, 255, 0);
color highlightStrokeCol = color(10,240,27);
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
  
  // Create other views
  new PFrame(new DetailedView(),2,(int)(displayHeight*0.01),displayWidth-4,(int)(displayHeight*0.32) ); 
  new PFrame(new MainView(),    2,(int)(displayHeight*0.33),displayWidth-4,(int)(displayHeight*0.27) );

  size(displayWidth-4,(int)(displayHeight*0.30));
  smooth();
  cp5 = new ControlP5(this);
  
  // *** INITIALIZING SLIDER ****
  cp5.addSlider("slider")
    .setPosition(30,10)
    .setWidth(width-60)
    .setHeight((int)(height*0.15))
    .setRange(controller.years[0], controller.years[controller.years.length-1])
    .setValue(2010)
    .setDecimalPrecision(0)
    .setSliderMode(Slider.FLEXIBLE);
    
    //          SCHOOL DROP DOWN       ****
    
//    CallbackListener dropcontrol = new CallbackListener() {
//      public void controlEvent(CallbackEvent theEvent) {
//        controller.schools[(int) theEvent.getController().getValue()].checked = true;
//        controller.update();
//        //println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
//      }
//    };
//    
//    d1 = cp5.addDropdownList("addSchool")
//          .setPosition(width-100, 10)
//          .onChange(dropcontrol)
//          ;
//    d1.setBackgroundColor(color(190));
//    d1.setItemHeight(20);
//    d1.setBarHeight(15);
//    d1.setCaptionLabel("Add a school");
//    for (int i = 0; i < controller.schools.length; i++) {
//      d1.addItem(controller.schools[i].name, i);
//    }
//    d1.setColorBackground(color(60));
//    d1.setColorActive(color(255, 128)); 
    
    
    //   INITIALIZING SCHOOL BUTTONS *****
    CallbackListener pressschool = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        int schoolindex = (int)theEvent.getController().getValue();
        controller.toggleSchool(schoolindex);
      }
    }; 
    
    int distance = (width - 60)/(controller.schools.length/2 +1);
    int buttonwidth = (int)(distance*0.85);
    for( int i = 0 ; i < controller.schools.length ; i++ ) {
      Button temp = cp5.addButton(controller.schools[i].name)
       .setValue(i)
       .setColorBackground( 100 )
       .setSwitch(true).setOn()
       .setColorActive(controller.schools[i].col)
       .setSize(buttonwidth,25)
       .onPress(pressschool)
       ;
      if ( i <= controller.schools.length/2 )  {
        temp.setPosition((distance*0.07) + 30 + i*distance ,(int)(height*0.25));
      } else {
        temp.setPosition((distance*0.07) + 30 + (i - 1 - controller.schools.length/2 )*distance ,(int)(height*0.25) + 35);
      }
     }
     
     // all schools off button
     CallbackListener schoolsoff = new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        controller.allSchoolsOff();
        for (School s : controller.schools) {
          ((Button) cp5.get(s.name)).setOff();
        }
      }
    }; 
     cp5.addButton("No schools")
       .setColorBackground( 100 )
       .setSize(buttonwidth,25)
       .onPress(schoolsoff)
       .setPosition((distance*0.07) + 30,(int)(height*0.25) + 70);
       ;
     
     //  INITIALIZING FILTER BUTTONS ****
     distance = (width - 60)/(controller.filters.length/2 +1);
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
         int distance = (width - 60)/(controller.filters.length/2 + 1);
         int buttonwidth = (int)(distance*0.85);
         Controller fbut = theEvent.getController();
         int currindex = controller.getFilterIndex( fbut );
         boolean foundLocation = false;
         for( int i = 0 ; i < controller.filters.length ; i++ ) {
           float leftx, topy;
           if ( i <= controller.filters.length/2 ) {
             leftx = (distance*0.07) + 30 + i*distance;
             topy  = (height*0.85) - 35;
           } else {
             leftx = (distance*0.07) + 30 + (i - 1 - controller.filters.length/2) * distance;
             topy  = height*0.85;
           }
           // if this filter button is within the x bounds of a filter location
           if ( mouseX > leftx && mouseX < leftx + buttonwidth && mouseY > topy && mouseY < topy + 20 ) {
             foundLocation = true;
             //if ( i != currindex ) { controller.swapFilters(i, currindex); }
             controller.swapFilters(i, currindex);
           }
         }
         if ( !foundLocation ) {
           if ( currindex <= controller.filters.length/2 )  {
              fbut.setPosition((distance*0.07) + 30 + currindex*distance ,(int)(height*0.85) - 35);
            } else {
              fbut.setPosition((distance*0.07) + 30 + (currindex - 1 - controller.filters.length/2 )*distance ,(int)(height*0.85));
            }
         //if ( !foundLocation ) { 
         //  fbut.setPosition((distance*0.07) + 30 + currindex*distance,(int)(height*0.85));
         }
       }
     };
          
     // link buttons to filters, so the controller knows what buttons need to move
     // with what fitler when they're dragged     
     for( int i = 0 ; i < controller.filters.length ; i++ ) {
       controller.filters[i].linkButton(
         cp5.addButton(controller.filters[i].getDisplayName())
           //.setPosition((distance*0.07) + 30 + i*distance,(int)(height*0.85))
           .setSize(buttonwidth,20)
           .onDrag(ondrag)
           .onEndDrag(ondragend)
           .onClick(onclickfilt)
           .setColorBackground( filtOnCol )
           .onRelease(onreleasefilt));
        if ( i <= controller.filters.length/2 )  {
          controller.filters[i].fbutton.setPosition((distance*0.07) + 30 + i*distance ,(int)(height*0.85) - 35);
        } else {
          controller.filters[i].fbutton.setPosition((distance*0.07) + 30 + (i - 1 - controller.filters.length/2 )*distance ,(int)(height*0.85));
        }
     }
  // reposition the Label for controller 'slider'
  //cp5.getController("slider").getValueLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  //cp5.getController("slider").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);  
      
}

void draw() {
  if ( updateForControlView ) {
    update();
  }
  background(backgroundcol); 
  int distance = (width - 60)/(controller.filters.length/2 +1);
  int buttonwidth = (int)(distance*0.85);
  for( int i = 0 ; i < controller.filters.length ; i++ ) {
     fill(128);
     stroke(100);
     if ( i <= controller.filters.length/2 )  {
       rect((distance*0.07) + 28 + i*distance ,(int)(height*0.85) - 37, buttonwidth + 4, 24 );
     } else {
       rect((distance*0.07) + 28 + (i - 1 - controller.filters.length/2 )*distance,(height * 0.85) - 2, buttonwidth + 4, 24);
     }
  }
}

void update() {
  int distance = (width - 60)/(controller.filters.length/2 + 1);
  int buttonwidth = (int)(distance*0.85);
  for( int i = 0 ; i < controller.filters.length ; i++ ) {
    color fcol;
    if ( controller.filters[i].isChecked() ) {
      fcol = filtOnCol;
    } else {
      fcol = filtOffCol; 
    }
    controller.filters[i].fbutton
     .setColorBackground(fcol);
     if ( i <= controller.filters.length/2 )  {
        controller.filters[i].fbutton.setPosition((distance*0.07) + 30 + i*distance ,(int)(height*0.85) - 35);
      } else {
        controller.filters[i].fbutton.setPosition((distance*0.07) + 30 + (i - 1 - controller.filters.length/2 )*distance ,(int)(height*0.85));
      }
  }
  updateForControlView = false;   
}

void slider(float val) {
  controller.changeYear(val);
}


// makes additional windows 
public class PFrame extends JFrame {
  public PFrame(PApplet s, int left, int top, int w, int h) {
    setBounds(left, top, w, h);
    setUndecorated(true); 
    add(s);   
    s.init();
    show();
  }
}


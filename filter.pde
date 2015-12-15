public class Filter {
  private String  displayname;
  private String  fieldname;
  // field types
  // INT   = 1
  // FLOAT = 2
  private int     fieldtype;
  private boolean checked;
  Button fbutton = null;
  
  Filter( String displayname, String fieldname, int fieldtype, boolean checked ) {
    this.displayname = displayname;
    this.fieldname   = fieldname;
    this.fieldtype   = fieldtype;
    this.checked     = checked;
  }
  
  void toggle()           { checked = !checked; }
  boolean isChecked()     { return checked;     }
  String getDisplayName() { return displayname; }
  String getQName()       { return fieldname;   }
  int getType()           { return fieldtype;   }
  
  void linkButton( Button fbutton ) {
   if ( this.fbutton == null ) this.fbutton = fbutton;
   else { println("Cant relink button! " + fieldname); System.exit(-1); }
  }
  Button getButton() { return fbutton; }
    
  String getQueryForYears (int [] years ) {
    String qString = "";
    for ( int i = 0 ; i < years.length ; i++ ) {
      if ( i > 0 ) { 
        qString += ","; 
      }
      qString += years[i] + "." + fieldname;
    }
    return qString;
  }
}

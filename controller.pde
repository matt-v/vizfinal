public class Filter {
  private String  displayname;
  private String  fieldname;
  /* field types */
  // 1    = 1
  // 2  = 2
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
public class School {
  String name, id;
  boolean checked;
  color col;
  School(String name, String id, color col, boolean checked) {
    this.name = name;
    this.id = id;
    this.col = col;
    this.checked = checked;
  }
  void toggle() { checked = !checked; }
  boolean isChecked() { return checked; }
}

class VController {
    int [] selectedFilter = new int[] {-1,-1,-1};
    float selectedYear = 2010; // it's a float so we can have a smooth animation as we move the slider
    int [] years = new int[] {2007,2008,2009, 2010, 2011, 2012, 2013};
    JSONObject json = null; // Data from query
  /* should be pulling filters and schools from cvs ... but this will due in a crunch */
    Filter [] filters = new Filter[]
    { new Filter ("Mid SAT"   , "admissions.sat_scores.average.overall", 1, true),
      new Filter ("Admission rate", "admissions.admission_rate.overall", 2, true),
      new Filter ("Number of students", "student.size", 1, true),
      new Filter ("Earnings after ten years", "earnings.10_yrs_after_entry.median", 1, true),
      new Filter ("Average graduate income", "student.avg_dependent_income.2014dollars", 1,true),
      new Filter ("Median dept", "aid.median_debt.completers.overall", 1, true),
      new Filter ("Percent with federal loans", "aid.federal_loan_rate", 2, true),
      new Filter ("Percent with Pell grant", "aid.pell_grant_rate", 2, true)
    };
    
    School [] schools = new School[] 
    { new School ("MIT", "166683", color(100,170,106), true),
      new School ("Tufts University", "168148",color(179,112,206), true),
      new School ("Bston College", "164924",color(197,87,127), true),
      new School ("Boston University", "164988", color(176,154,60), true),
      new School ("Brandies University", "165015", color(102,187,188),true),
      new School ("Emerson College", "165662", color(148,217,77), true),
      new School ("Harvard Univerity", "166027", color(130,134,179),true),
      new School ("Northeastern University", "167358", color(65,45,110),true),
      new School ("Wellesley College", "168218", color(200,170,106),true),
      
      new School ("Amherst College", "164465", color(179,212,206), true),
      new School ("Colby College", "161086", color(197,187,127), true),
      new School ("Hamilton College", "191515", color(0,154,100), true),
      new School ("Middlebury College", "230959", color(202,187,128), true),
      new School ("Wesleyan University", "130697", color(148,17,77), true),
      new School ("Howard University", "131520", color(130,34,179), true),
      new School ("Morehouse College", "140553", color(200,170,6), true),
      new School ("Spelman College", "141060", color(179,12,236), true)
    };
    
    VController() {
      update();
    }
    
    void changeYear  ( float year ) { selectedYear = year; nonQueryUpdate(); }
    void toggleFilter( int n ) { filters[n].toggle(); update(); }
    void toggleSchool( int n ) { schools[n].toggle(); update(); }
    
    // This changes the position of the filters in the arrary... their order in the array is their
    // order in the main view
    void swapFilters ( int fst, int snd ) {
      Filter temp = filters[fst];
      filters[fst] = filters[snd];
      filters[snd] = temp;
      nonQueryUpdate();
    }
    
    int getFilterIndex( Controller b ) {
      for( int i = 0; i < filters.length; i++ ) {
        if ( filters[i].getButton() == b ) {
          return i;
        }
      }
      println("Couldn't find button linked to filter");
      System.exit(-1);
      return -1;
    }
    
    float dataPoint( School school, Filter filt ) {
      String id = school.id;
      String field = filt.getQName();
      int fieldType = filt.getType();
      JSONArray values = controller.json.getJSONArray("results");
      for ( int i = 0 ; i < values.size() ; i++ ) {
        JSONObject fields = values.getJSONObject(i);
        if ( parseInt(id) == fields.getInt("id") ) {
          if ( fieldType == 1 ) {
            float lowYear  = floor(selectedYear);
            float highYear = ceil(selectedYear);
            float lyval    = fields.getInt(((int)lowYear) +"."+field);
            float hyval    = fields.getInt(((int)highYear)+"."+field); 
            if (lyval == hyval) return lyval;           
            return lyval + (hyval-lyval)*(selectedYear - lowYear)/(highYear - lowYear);
          } else if ( fieldType == 2 ) {
            float lowYear  = floor(selectedYear);
            float highYear = ceil(selectedYear);
            float lyval    = fields.getFloat(((int)lowYear)+"."+field);
            float hyval    = fields.getFloat(((int)highYear)+"."+field);
            if (lyval == hyval) return lyval;            
            return lyval + (hyval-lyval)*(selectedYear - lowYear)/(highYear - lowYear);
          }
        }
      }
      return -1;
    }
    
    Filter [] getActiveFilters() {
      ArrayList<Filter> flts = new ArrayList<Filter>();
      for ( int i = 0 ; i < filters.length ; i++ ) {
        if (filters[i].isChecked()) { flts.add(filters[i]); }
      }
      return flts.toArray(new Filter[0]);
    }
    
    School [] getActiveSchools() {
      ArrayList<School> sc = new ArrayList<School>();
      for ( int i = 0; i < schools.length; i++ ) {
        if (schools[i].isChecked()) { sc.add(schools[i]); }
        }
        return sc.toArray(new School[0]);
    }
    
    String [] getSchoolIds() {
      ArrayList<String> ids = new ArrayList<String>();
      for ( int i = 0; i < schools.length; i++ ) {
        if (schools[i].isChecked()) { ids.add(schools[i].id); }
        }
        return ids.toArray(new String[0]);
    }
    /* only for int years, not floating point mid-years */
    float valueFor( String id, int year, Filter filt ) {
      JSONArray results = controller.json.getJSONArray("results");
      for ( int i = 0 ; i < results.size(); i++ ) {
        JSONObject record = results.getJSONObject(i);
        if ( parseInt(id) == record.getInt("id") ) {
          if (filt.getType() == 1) {
            return record.getInt(year + "." + filt.getQName() );
          } else if (filt.getType() == 2) {
            return record.getFloat(year + "." + filt.getQName() );
          }
        }
      }
      println("ERROR IN VALUEFOR() "+ id+ " in " + year);
      return MAX_FLOAT;
    }
    float [] lowAndHighFor( School [] activeSchools, Filter filt ) {
      ArrayList<String> ids = new ArrayList<String>();
      float lowVal  = MAX_FLOAT;
      float highVal = MIN_FLOAT;
      for ( int i = 0; i < activeSchools.length; i++ ) {
            for ( int j = 0; j < years.length; j++ ) {
                float candidate;
                try {
                   candidate = valueFor( activeSchools[i].id, years[j], filt );
                } catch (Exception e) {
                  if (DEBUG) println("No value for " + activeSchools[i].id + " in " + years[j] +"."+ filt.getQName());
                  continue;
                }
                if ( candidate == MAX_FLOAT ) { continue; }
                else if ( candidate > highVal ) {
                  highVal = candidate;
                }
                else if ( candidate < lowVal ) {
                  lowVal = candidate;
                }
            }
      }
      float [] vals = {lowVal, highVal};
      return vals;
    }  
      
    
    JSONObject query() {
      Criteria [] criteria = new Criteria[] {new Criteria ("id", getSchoolIds() ) };
      Filter [] actives = getActiveFilters();
      String [] fields  = new String[actives.length];
      for ( int i = 0 ; i < actives.length ; i++ ) {
        fields[i] = actives[i].getQueryForYears( years );
      }
      return GetQuery.get(criteria, fields );
    }
    
    void nonQueryUpdate() {
      updateForMain        = true;
      updateForDetailed    = true;
      updateForControlView = true;
    }
    
    void update() {
      json = query();
      nonQueryUpdate();
    }
    
}

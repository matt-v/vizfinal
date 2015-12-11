public class Filter {
  private String  displayname;
  private String  fieldname;
  /* field types */
  // 1    = 1
  // 2  = 2
  private int     fieldtype;
  private boolean checked;
  
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
  School(String name, String id, boolean checked) {
    this.name = name;
    this.id = id;
    this.checked = checked;
  }
  void toggle() { checked = !checked; }
  boolean isChecked() { return checked; }
}

class Controller {

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
    float selectedYear = 2010; // it's a float so we can have a smooth animation as we move the slider
    int [] years = new int[] {2009, 2010, 2011, 2012, 2013};
    School [] schools = new School[] 
    { new School ("MIT", "166683", false),
      new School ("Tufts University", "168148", false),
      new School ("Bston College", "164924", false),
      new School ("Boston University", "164988", false),
      new School ("Brandies University", "165015", false),
      new School ("Emerson College", "165662", false),
      new School ("Harvard Univerity", "166027", false),
      new School ("Northeastern University", "167358", false),
      new School ("Wellesley College", "168218", false),
      
      new School ("Amherst College", "164465", false),
      new School ("Colby College", "161086", false),
      new School ("Hamilton College", "191515", false),
      new School ("Middlebury College", "230959", false),
      new School ("Wesleyan University", "130697", false),
      new School ("Howard University", "131520", false),
      new School ("Morehouse College", "140553", false),
      new School ("Spelman College", "141060", false)
    };

    JSONObject json = null; // Data from query
    
    Controller() {
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
    
    float dataPoint( String id, Filter filt ) {
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
      println("ERROR IN VALUEFOR()");
      return -1;
    }
    float [] lowAndHighFor( Filter filt ) {
      ArrayList<String> ids = new ArrayList<String>();
      float lowVal  = MAX_FLOAT;
      float highVal = MIN_FLOAT;
      for ( int i = 0; i < schools.length; i++ ) {
        if (schools[i].isChecked()) { 
            for ( int j = 0; j < years.length; j++ ) {
                float candidate;
                try {
                   candidate = valueFor( schools[i].id, years[j], filt );
                } catch (Exception e) {
                  if (DEBUG) println("No value for " + schools[i].id + " in " + years[j] +"."+ filt.getQName());
                  continue;
                }
                if ( candidate > highVal ) {
                  highVal = candidate;
                }
                if ( candidate < lowVal ) {
                  lowVal = candidate;
                }
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
      updateForMain     = true;
      updateForDetailed = true;
    }
    
    void update() {
      json = query();
      nonQueryUpdate();
    }
    
}

class Criteria {
  private String name;
  private String [] options;
  
  Criteria ( String name, String [] options ) {
    this.name = name;
    this.options = options;
  }
  String getName() { return name; }
  String [] getOpts() { return options; };
}

public static class GetQuery  {
  
  private static String buildQuery( Criteria [] criteria, String [] fields ) {
    String queryString = "https://api.data.gov/ed/collegescorecard/v1/schools.json?api_key=KSowN7RRaEtN3v3e8gvNUzsGSq714vJwKBzqWfCT";
    if ( criteria.length != 0 ) {
      for ( int i = 0 ; i < criteria.length ; i++ ) {
        queryString += "&" + criteria[i].getName() + "=";
        String [] options = criteria[i].getOpts();
        for ( int j = 0 ; j < options.length ; j++ ) {
          if ( j > 0 ) { queryString += ","; }
          queryString += options[j];
        }
      } 
    } // end criteria if
    if ( fields.length != 0 ) {
      queryString += "&_fields=school.name,id";
      for ( int i = 0 ; i < fields.length ; i++ ) {
        queryString += "," + fields[i];
      }
    }
    return queryString;
  }
  
  public static JSONObject get( Criteria [] criteria, String [] fields ) {   
    String queryString = buildQuery( criteria, fields );
    GetRequest get = new GetRequest( queryString );
    get.send();
    return JSONObject.parse( get.getContent() );  
  }  
}

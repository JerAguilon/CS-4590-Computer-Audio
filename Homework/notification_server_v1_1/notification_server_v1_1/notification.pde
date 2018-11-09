enum NotificationType { Tweet, Email, TextMessage, MissedCall, VoiceMail }

class Notification {
   
  int timestamp;
  NotificationType type; //Tweet, Email, TextMessage, MissedCall, VoiceMail
  String message; //NOT used by MissedCall
  String sender;
  int priority;
  int contentSummary; //NOT used by Tweet or MissedCall
  int retweets; //used by Tweet only
  int favorites; //used by Tweet only
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    
    if (json.isNull("message")) {
      this.message = "";
    }
    else {
      this.message = json.getString("message");
    }
    
    if (json.isNull("sender")) {
      this.sender = "";
    }
    else {
      this.sender = json.getString("sender");      
    }
    
    this.priority = json.getInt("priority");
    //1-4 levels (1 is lowest, 4 is highest)
    
    if (json.isNull("contentSummary")) {
      this.contentSummary = 0;
      //0 == not applicable to this notification type
    }
    else {
      this.contentSummary = json.getInt("contentSummary");
      //1 = negative, 2 = neutral, 3 = positive
    }
     
    if (json.isNull("retweets")) {
      this.retweets = 0;
    }
    else {
      this.retweets = json.getInt("retweets");      
    }
    
    if (json.isNull("favorites")) {
      this.favorites = 0;
    }
    else {
      this.favorites = json.getInt("favorites");      
    }
                             
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public String getMessage() { return message; }
  public String getSender() { return sender; }
  public int getPriorityLevel() { return priority; }
  public int getContentSummary() { return contentSummary; }
  public int getRetweets() { return retweets; }
  public int getFavorites() { return favorites; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(" + getSender() + ")";
      output += " " + getMessage();
      return output;
    }
}
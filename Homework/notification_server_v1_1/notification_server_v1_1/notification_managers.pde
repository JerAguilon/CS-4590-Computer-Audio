import java.util.Map;
import java.util.HashMap;

/**
 * Singleton NotificationManagers: can't internalize these in their respective classes due to some
 * processing implementation shenanigans
 */

final NotificationManager EMAIL_NOTIFICATION_MANAGER = new EmailNotificationManager();
final NotificationManager TWEET_NOTIFICATION_MANAGER = new TweetNotificationManager();
final NotificationManager TEXT_NOTIFICATION_MANAGER = new TextNotificationManager();
final NotificationManager MISSED_CALL_NOTIFICATION_MANAGER = new MissedCallNotificationManager();
final NotificationManager VOICE_MAIL_NOTIFICATION_MANAGER = new VoiceMailNotificationManager();

NotificationManager getNotificationManager(NotificationType t) {
  switch (t) {
    case Tweet:
      return TWEET_NOTIFICATION_MANAGER;
    case Email:
      return EMAIL_NOTIFICATION_MANAGER;
    case TextMessage:
      return TEXT_NOTIFICATION_MANAGER;
    case MissedCall:
      return MISSED_CALL_NOTIFICATION_MANAGER;
    case VoiceMail:
      return VOICE_MAIL_NOTIFICATION_MANAGER;
    default:
      throw new RuntimeException("Unregistered NotificationType: " + t.toString());
  }
}

abstract class NotificationManager {

  protected Environment environment;

  protected NotificationManager() {
    this.environment = Environment.PARTY;
  }

  public void setEnvironment(Environment e) {
    this.environment = environment;
  }

  public void processNotification(Notification n) {
    tts.speak(n.getSender());
    tts.speak(n.getMessage());

    String debugOutput = "";
    switch (n.getType()) {
      case Tweet:
        debugOutput += "New tweet from ";
        break;
      case Email:
        debugOutput += "New email from ";
        break;
      case VoiceMail:
        debugOutput += "New voicemail from ";
        break;
      case MissedCall:
        debugOutput += "Missed call from ";
        break;
      case TextMessage:
        debugOutput += "New message from ";
        break;
    }
    debugOutput += n.getSender() + ", " + n.getMessage();
    
    println(debugOutput);
  }

}

class EmailNotificationManager extends NotificationManager {

}

class TweetNotificationManager extends NotificationManager {

} 

class TextNotificationManager extends NotificationManager {

} 

class MissedCallNotificationManager extends NotificationManager {

} 

class VoiceMailNotificationManager extends NotificationManager {

} 


/* class Notification { */
   
/*   int timestamp; */
/*   NotificationType type; //Tweet, Email, TextMessage, MissedCall, VoiceMail */
/*   String message; //NOT used by MissedCall */
/*   String sender; */
/*   int priority; */
/*   int contentSummary; //NOT used by Tweet or MissedCall */
/*   int retweets; //used by Tweet only */
/*   int favorites; //used by Tweet only */
/* } */

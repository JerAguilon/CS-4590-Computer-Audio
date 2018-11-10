import java.util.Map;
import java.util.HashMap;

import java.lang.reflect.*;

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
    /* tts.speak(n.getSender()); */
    /* tts.speak(n.getMessage()); */

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
  public void processNotification(Notification n) {
    /* g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP)); */
    super.processNotification(n);
  }
}

class TweetNotificationManager extends NotificationManager {

  private static final int RETWEET_NOTIFICATION_THRESHOLD = 1000;

  private void processPartyNotification(Notification n) {
    if (n.getPriorityLevel() > 2) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    } else if (n.getRetweets() > TweetNotificationManager.RETWEET_NOTIFICATION_THRESHOLD) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }

  private void processJoggingNotification(Notification n) {
    if (n.getPriorityLevel() > 2) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }

  private void processLectureNotification(Notification n) {
    // TODO: play a non-intrusive sound when something urgent comes up
    if (n.getPriorityLevel() == 4) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }
  
  private void processPublicTransitNotification(Notification n) {
    //TODO: Do we want to do it every time for this environment?
    g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
  }

  public void processNotification(Notification n) {
    switch(this.environment) {
      case PARTY: 
        processPartyNotification(n);
        break;
      case LECTURING:
        processLectureNotification(n);
        break;
      case JOGGING:
        processJoggingNotification(n);
        break;
      case PUBLIC_TRANSIT:
        processPublicTransitNotification(n);
        break;
      default:
        break;
    }
    super.processNotification(n);
  }
}

class TextNotificationManager extends NotificationManager {
  public void processNotification(Notification n) {
    super.processNotification(n);
  }
} 

class MissedCallNotificationManager extends NotificationManager {
  public void processNotification(Notification n) {
    /* g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP)); */
    super.processNotification(n);
  }
} 

class VoiceMailNotificationManager extends NotificationManager {
  public void processNotification(Notification n) {
    /* g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP)); */
    super.processNotification(n);
  }
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

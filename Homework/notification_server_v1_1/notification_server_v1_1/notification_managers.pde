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

  public abstract void processPartyNotification(Notification n, UserProfile userProfile);
  public abstract void processJoggingNotification(Notification n, UserProfile userProfile);
  public abstract void processLectureNotification(Notification n, UserProfile userProfile);
  public abstract void processPublicTransitNotification(Notification n, UserProfile userProfile);

  public void processNotification(Notification n, UserProfile userProfile) {
    /* tts.speak(n.getSender()); */
    /* tts.speak(n.getMessage()); */
    switch(this.environment) {
      case PARTY: 
        processPartyNotification(n, userProfile);
        break;
      case LECTURING:
        processLectureNotification(n, userProfile);
        break;
      case JOGGING:
        processJoggingNotification(n, userProfile);
        break;
      case PUBLIC_TRANSIT:
        processPublicTransitNotification(n, userProfile);
        break;
      default:
        break;
    }

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
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3 && userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    } 
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 2) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_DING));
    }
  }

  public void processLectureNotification(Notification n, UserProfile userProfile) {
    // TODO: maybe white noise?
    if (n.getPriorityLevel() == 4) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    }
  }
  
  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 2) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_DING));
    }
  }
}

class TweetNotificationManager extends NotificationManager {

  private static final int RETWEET_NOTIFICATION_THRESHOLD = 1000;

  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    } else if (n.getRetweets() > TweetNotificationManager.RETWEET_NOTIFICATION_THRESHOLD) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() == 4 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }

  public void processLectureNotification(Notification n, UserProfile userProfile) {
    // TODO: play a non-intrusive sound when something urgent comes up
    if (n.getPriorityLevel() == 4) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }
  
  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    //TODO: Do we want to do it every time for this environment?
    g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
  }
}

class TextNotificationManager extends NotificationManager {
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (!userProfile.isBestFriend(n.getSender())) {
      return;
    }

    if (n.getPriorityLevel() > 3) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 2 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }
  public void processLectureNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }

  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }
} 

class MissedCallNotificationManager extends NotificationManager {
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 2 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }
  public void processLectureNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }

  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() > 3) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }
} 

class VoiceMailNotificationManager extends NotificationManager {
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
  }
  public void processLectureNotification(Notification n, UserProfile userProfile) {
    g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
  }

  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
  }
} 


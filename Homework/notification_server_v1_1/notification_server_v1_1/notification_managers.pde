import java.util.Map;
import java.util.HashMap;

import java.lang.reflect.*;

/**
 * Singleton NotificationManagers: can't internalize these in their respective classes due to some
 * processing implementation shenanigans
 **/

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

  protected NotificationManager() {
  }
  
  protected void sleep(int milliseconds) {
    try {
      TimeUnit.MILLISECONDS.sleep(milliseconds);
    } catch(InterruptedException ex) {
      Thread.currentThread().interrupt();
    }
  }

  public abstract void processPartyNotification(Notification n, UserProfile userProfile);
  public abstract void processJoggingNotification(Notification n, UserProfile userProfile);
  public abstract void processLectureNotification(Notification n, UserProfile userProfile);
  public abstract void processPublicTransitNotification(Notification n, UserProfile userProfile);

  public void processNotification(Notification n, UserProfile userProfile, Environment e) {
    if (!userProfile.isNotificationEnabled(n.getType())) {
      return;
    }
    /* tts.speak(n.getSender()); */
    /* tts.speak(n.getMessage()); */
    if (n.getPriorityLevel() <= 2 && userProfile.isBestFriend(n.getSender())) {
      float baseFrequency = 440;
      for (int i = 0; i < 3; i++) {
        g.addInput(getSineWaveUGen(baseFrequency));
        this.sleep(125);
        g.clearInputConnections();
        this.sleep(75);
      }
    }

    switch(e) {
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

    String debugFormat = "Type: %s\nSender: %s\nMessage: %s\n\n";
    String output = String.format(
      debugFormat,
      n.getType().toString(),
      n.getSender(),
      n.getMessage()
    );
    println(output);
  }
}


class EmailNotificationManager extends NotificationManager {
  private boolean isSpammy(Notification n) {
    return n.getMessage().toUpperCase().equals(n.getMessage()) ||
           n.getSender().toLowerCase().contains("spam");
  }

  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return;

    if (n.getPriorityLevel() <= 2 && userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    } else if (n.getPriorityLevel() == 2) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_DING));
    } else if (n.getPriorityLevel() == 1) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return;

    if (n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_DING));
    }
  }

  public void processLectureNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return;

    if (n.getPriorityLevel() == 1) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_DING));
    }
  }
  
  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return;

    if (n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_TRIPLE_DING));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.EMAIL_DING));
    }
  }
}

class TweetNotificationManager extends NotificationManager {

  private static final int RETWEET_NOTIFICATION_THRESHOLD = 1000;

  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() == 1) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    } else if (n.getRetweets() > TweetNotificationManager.RETWEET_NOTIFICATION_THRESHOLD) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
    }
  }

  public void processLectureNotification(Notification n, UserProfile userProfile) {
    return;
  }
  
  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    //TODO: Do we want to do it every time for this environment?
    g.addInput(getSamplePlayer(NotificationSound.TWITTER_CHIRP));
  }
}

class TextNotificationManager extends NotificationManager {
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }

  public void processLectureNotification(Notification n, UserProfile userProfile) {
  }

  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 3) {
      g.addInput(getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION));
    }
  }
} 

class MissedCallNotificationManager extends NotificationManager {
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 || userProfile.isBestFriend(n.getSender())) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }
  public void processLectureNotification(Notification n, UserProfile userProfile) {
  }

  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_URGENT));
    } else {
      g.addInput(getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT));
    }
  }
} 

class VoiceMailNotificationManager extends NotificationManager {
  public void processPartyNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender()) || n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
    }
  }

  public void processJoggingNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender()) || n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
    }
  }
  public void processLectureNotification(Notification n, UserProfile userProfile) {
  }

  public void processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender()) || n.getPriorityLevel() <= 2) {
      g.addInput(getSamplePlayer(NotificationSound.VOICEMAIL_CHIME));
    }
  }
} 


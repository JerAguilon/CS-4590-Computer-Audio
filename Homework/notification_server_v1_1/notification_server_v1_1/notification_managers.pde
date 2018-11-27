import java.util.Map;
import java.util.HashMap;

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

public void sleep(int milliseconds) {
  try {
    TimeUnit.MILLISECONDS.sleep(milliseconds);
  } catch(InterruptedException ex) {
    Thread.currentThread().interrupt();
  }
}

public synchronized void addInput(final SamplePlayer ugen) {
  g.addInput(ugen);
  ugen.setEndListener(
    new Bead() {
      public void messageReceived(Bead m) {
        g.removeAllConnections(ugen);
      }
    }
  );
  while (g.containsInput(ugen)) {
    sleep(100);
  }
}

abstract class NotificationManager {

  protected NotificationManager() {
  }
  

  public abstract SamplePlayer processPartyNotification(Notification n, UserProfile userProfile);
  public abstract SamplePlayer processJoggingNotification(Notification n, UserProfile userProfile);
  public abstract SamplePlayer processLectureNotification(Notification n, UserProfile userProfile);
  public abstract SamplePlayer processPublicTransitNotification(Notification n, UserProfile userProfile);

  public synchronized void processNotification(Notification n, UserProfile userProfile, Environment e) {

    if (!userProfile.isNotificationEnabled(n.getType())) {
      println(n.getType().toString() + " is not enabled, skipping\n\n");
      return;
    }
    if (n.getPriorityLevel() == 1 && userProfile.isBestFriend(n.getSender())) {
      float baseFrequency = e == Environment.LECTURING ? 220 : 320;
      UGen sineWave = getSineWaveUGen(baseFrequency);
      for (int i = 0; i < 2; i++) {
        g.addInput(sineWave);
        sleep(125);
        g.removeAllConnections(sineWave);
        sleep(75);
      }
    }

    SamplePlayer s;
    switch(e) {
      case PARTY: 
        s = processPartyNotification(n, userProfile);
        break;
      case LECTURING:
        s = processLectureNotification(n, userProfile);
        break;
      case JOGGING:
        s = processJoggingNotification(n, userProfile);
        break;
      case PUBLIC_TRANSIT:
        s = processPublicTransitNotification(n, userProfile);
        break;
      default:
        s = null;
        break;
    }

    if (s != null) {
      addInput(s);
      userProfile.addNotification(s);
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


  public synchronized SamplePlayer processPartyNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return null;

    if (n.getPriorityLevel() == 1) {
      return getSamplePlayer(NotificationSound.EMAIL_DING_URGENT);
    }

    return null;
  }

  public synchronized SamplePlayer processJoggingNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return null;

    if (n.getPriorityLevel() <= 2 && userProfile.isBestFriend(n.getSender())) {
      return getSamplePlayer(NotificationSound.EMAIL_DING_URGENT);
    } else if (n.getPriorityLevel() == 1) {
      return getSamplePlayer(NotificationSound.EMAIL_DING);
    }
    return null;
  }

  public synchronized SamplePlayer processLectureNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) return null;

    if (n.getPriorityLevel() == 1) {
      return getSamplePlayer(NotificationSound.EMAIL_DING);
    }
    return null;
  }
  
  public synchronized SamplePlayer processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (isSpammy(n)) {
      tts.speak("Spam warning.");
      return null;
    };

    if (n.getPriorityLevel() <= 2) {
      if (n.getContentSummary() == 1) {
        tts.speak("Good news");
      } else if (n.getContentSummary() == 3) {
        tts.speak("Bad news");
      }
      return getSamplePlayer(NotificationSound.EMAIL_DING_URGENT);
    } else {
      return getSamplePlayer(NotificationSound.EMAIL_DING);
    }
  }
}

class TweetNotificationManager extends NotificationManager {

  private static final int RETWEET_NOTIFICATION_THRESHOLD = 1000;

  public synchronized SamplePlayer processPartyNotification(Notification n, UserProfile userProfile) {
    if (
      n.getPriorityLevel() == 1 &&
      n.getRetweets() > TweetNotificationManager.RETWEET_NOTIFICATION_THRESHOLD
    ) {
      return getSamplePlayer(NotificationSound.TWITTER_CHIRP);
    }
    return null;
  }

  public synchronized SamplePlayer processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 || userProfile.isBestFriend(n.getSender())) {
      return getSamplePlayer(NotificationSound.TWITTER_CHIRP);
    } else if (
      n.getPriorityLevel() == 1 &&
      n.getRetweets() > TweetNotificationManager.RETWEET_NOTIFICATION_THRESHOLD
    ) {
      return getSamplePlayer(NotificationSound.TWITTER_CHIRP);
    }
    return null;
  }

  public synchronized SamplePlayer processLectureNotification(Notification n, UserProfile userProfile) {
    return null;
  }
  
  public synchronized SamplePlayer processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender())) {
      return getSamplePlayer(NotificationSound.TWITTER_CHIRP);
    } else if (n.getPriorityLevel() <= 2) {
      return getSamplePlayer(NotificationSound.TWITTER_CHIRP);
    }
    return null;
  }
}

class TextNotificationManager extends NotificationManager {
  public synchronized SamplePlayer processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2) {
      return getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION);
    }
    return null;
  }

  public synchronized SamplePlayer processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 || userProfile.isBestFriend(n.getSender())) {
      return getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION);
    }
    return null;
  }

  public synchronized SamplePlayer processLectureNotification(Notification n, UserProfile userProfile) {
    return null;
  }

  public synchronized SamplePlayer processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2) {
      if (n.getContentSummary() == 1) {
        tts.speak("Good news");
      } else if (n.getContentSummary() == 3) {
        tts.speak("Bad news");
      }
    }
    return getSamplePlayer(NotificationSound.TEXT_DEFAULT_NOTIFICATION);
  }
} 

class MissedCallNotificationManager extends NotificationManager {
  public synchronized SamplePlayer processPartyNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 && userProfile.isBestFriend(n.getSender())) {
      return getSamplePlayer(NotificationSound.MISSED_CALL_URGENT);
    } else if (n.getPriorityLevel() == 1)  {
      return getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT);
    }
    return null;
  }

  public synchronized SamplePlayer processJoggingNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2 && userProfile.isBestFriend(n.getSender())) {
      return getSamplePlayer(NotificationSound.MISSED_CALL_URGENT);
    } else if (n.getPriorityLevel() == 1) {
      return getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT);
    }
    return null;
  }

  public synchronized SamplePlayer processLectureNotification(Notification n, UserProfile userProfile) {
    return null;
  }

  public synchronized SamplePlayer processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (n.getPriorityLevel() <= 2) {
      return getSamplePlayer(NotificationSound.MISSED_CALL_URGENT);
    } else {
      return getSamplePlayer(NotificationSound.MISSED_CALL_DEFAULT);
    }
  }
} 

class VoiceMailNotificationManager extends NotificationManager {
  public synchronized SamplePlayer processPartyNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender()) && n.getPriorityLevel() <= 2) {
      return getSamplePlayer(NotificationSound.VOICEMAIL_CHIME);
    }
    return null;
  }

  public synchronized SamplePlayer processJoggingNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender()) || n.getPriorityLevel() <= 2) {
      return getSamplePlayer(NotificationSound.VOICEMAIL_CHIME);
    }
    return null;
  }

  public synchronized SamplePlayer processLectureNotification(Notification n, UserProfile userProfile) {
    return null;
  }

  public synchronized SamplePlayer processPublicTransitNotification(Notification n, UserProfile userProfile) {
    if (userProfile.isBestFriend(n.getSender()) || n.getPriorityLevel() <= 3) {
      if (n.getPriorityLevel() <= 2) {
        if (n.getContentSummary() == 1) {
          tts.speak("Good news");
        } else if (n.getContentSummary() == 3) {
          tts.speak("Bad news");
        }
      }
      return getSamplePlayer(NotificationSound.VOICEMAIL_CHIME);
    }
    return null;
  }
} 


import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class UserProfile {
  private final String[] DEFAULT_FRIENDS = {
    "Sister",
    "best friend",
    "Mom",
  };

  private Set<String> bestFriends;
  private Set<NotificationType> enabledNotifications;
  private Set<String> activeContacts;
  private List<SamplePlayer> samplePlayers;


  public UserProfile(String jsonFile) {
    rebuild(jsonFile);
  }

  public boolean isBestFriend(String sender) {
    return bestFriends.contains(sender);
  }

  public boolean isNotificationEnabled(NotificationType t) {
    return enabledNotifications.contains(t);
  }
  
  public void updateNotificationPolicy(NotificationType t, boolean enable) {
    if (enable) {
      this.enabledNotifications.add(t);
    } else {
      this.enabledNotifications.remove(t);
    }
  }

  public void rebuild(String jsonFile) {
    enabledNotifications = new HashSet(Arrays.asList(NotificationType.values()));
    bestFriends = new HashSet(Arrays.asList(this.DEFAULT_FRIENDS));
    activeContacts = this.getActiveContacts(loadJSONArray(jsonFile));
    samplePlayers = new ArrayList();
  }

  public void addNotification(SamplePlayer sound) {
    samplePlayers.add(sound);
  }

  public synchronized void getReport() {
    if (samplePlayers.size() == 0) {
      println("<REPORT> Nothing to report");
      tts.speak("No messages");
      return;
    }

    println(String.format("<REPORT> Starting a report of size %d", samplePlayers.size()));
    tts.speak("Here's your report");

    float pan = -1;
    float delta_pan = 2.0 / samplePlayers.size();

    for (int index = 0; index < samplePlayers.size(); index++) {
      
      final String filename = samplePlayers.get(index).getSample().getFileName();
      final SamplePlayer s= getSamplePlayer(
          filename, true, SamplePlayer.LoopType.NO_LOOP_FORWARDS
      );
      final Panner p = new Panner(ac, pan);
      p.addInput(s);
      s.setEndListener(
        new Bead() {
          public void messageReceived(Bead m) {
            g.removeAllConnections(p);
          }
        }
      );
      g.addInput(p);
      while (g.containsInput(p)) {
        sleep(25);
      }
      pan += delta_pan;
      sleep(100);
    }
    tts.speak("That's all your messages");
    println("<REPORT> Done");
  }

  private Set<String> getActiveContacts(JSONArray arr) {
    Set<String> contacts = new HashSet();
    for (int i = 0; i < arr.size(); i++) {
      contacts.add(arr.getJSONObject(i).getString("sender"));
    }
    return contacts;
  }
}

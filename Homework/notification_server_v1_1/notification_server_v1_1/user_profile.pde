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

  private Set<String> getActiveContacts(JSONArray arr) {
    Set<String> contacts = new HashSet();
    for (int i = 0; i < arr.size(); i++) {
      contacts.add(arr.getJSONObject(i).getString("sender"));
    }
    return contacts;
  }

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
  }
}

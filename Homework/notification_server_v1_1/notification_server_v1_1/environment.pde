import beads.*;

//helper functions
AudioContext ac; //needed here because getSamplePlayer() uses it below

Sample getSample(String fileName) {
 return SampleManager.sample(dataPath(fileName)); 
}

SamplePlayer getSamplePlayer(String fileName, Boolean killOnEnd) {
  SamplePlayer player = null;
  try {
    player = new SamplePlayer(ac, getSample(fileName));
    player.setKillOnEnd(killOnEnd);
    player.setName(fileName);
  }
  catch(Exception e) {
    println("Exception while attempting to load sample: " + fileName);
    e.printStackTrace();
    exit();
  }
  
  return player;
}

SamplePlayer getSamplePlayer(String fileName) {
  return getSamplePlayer(fileName, false);
}

SamplePlayer getSamplePlayer(Environment e) {
  return getSamplePlayer(e.getSoundFile());
}

SamplePlayer getSamplePlayer(NotificationSound n) {
  return getSamplePlayer(n.getSoundFile(), true);
}

public enum Environment {
  PUBLIC_TRANSIT(""), JOGGING("jog.wav"), PARTY("party.mp3"), LECTURING("");
  
  private final String wavFile;
  
  private Environment(String wavFile) {
    this.wavFile = wavFile;
  }
  
  public String getSoundFile() {
    return this.wavFile;
  }
}


public enum NotificationSound {
  EMAIL_DING(""),
  EMAIL_TRIPLE_DING(""),
  
  TWITTER_CHIRP("chirp.wav"),
  
  PHONE_DEFAULT_RING(""),
  PHONE_URGENT_RING(""),

  VOICEMAIL_CLIMBING_BEEPS("");
  
  private final String wavFile;
  
  private NotificationSound(String wavFile) {
    this.wavFile = wavFile;
  }
  
  public String getSoundFile() {
    return this.wavFile;
  }
  
}

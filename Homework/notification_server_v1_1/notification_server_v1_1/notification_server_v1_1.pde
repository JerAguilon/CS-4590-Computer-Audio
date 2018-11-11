//<import statements here>

import java.util.concurrent.TimeUnit;

import guru.ttslib.*;

import controlP5.*;
import beads.*;

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "ExampleData_1.json";
String eventDataJSON2 = "ExampleData_2.json";

NotificationServer server;
ArrayList<Notification> notifications;

Example example;

static final String MRBROLA_LOCATION = "/usr/share/mbrola";
TTS tts;

ControlP5 p5;
RadioButton environmentButtons;
color fore = color(255, 255, 255);
color back = color(0, 0, 0);

Gain g;

void setup() {
  
  size(600, 600);
  
  p5 = new ControlP5(this);

  environmentButtons = p5.addRadioButton("environmentButtons")
    .setPosition(50, 40)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(80)
    .setSpacingRow(10)
    .addItem("Public Transit", 0)
    .addItem("Jogging", 1)
    .addItem("Party", 2)
    .addItem("Lecturing", 3);
  
  
  //loading the event stream, which also starts the timer serving events
  
  /**
   * MBrola has a more pleasant voice than the defualt, but I had to download the voice profile.
   */
  System.setProperty("mbrola.base", MRBROLA_LOCATION);
  tts = new TTS("mbrola_us1");
  tts.setPitch(200);

  example = new Example();
  
  ac = new AudioContext();
  g = new Gain(ac, 2, .3);
  ac.out.addInput(g);
  g.addInput(getSamplePlayer(example.getEnvironment()));
  ac.start();

  // Sleep to let the ac start playing
  try {
    TimeUnit.SECONDS.sleep(2);
  } catch(InterruptedException e) {
    Thread.currentThread().interrupt();
  }

  //START NotificationServer setup
  server = new NotificationServer();
  server.loadEventStream(eventDataJSON1);
  //instantiating a custom class (seen below) and registering it as a listener to the server
  server.addListener(example);
  //END NotificationServer setup 
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()
  background(back);
  stroke(fore);
  
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  }
}

void environmentButtons(int i) {
  if (i != -1) {
    println("Setting to " + Integer.toString(i));
    example.setEnvironment(Environment.values()[i]);
  } else {
    example.setEnvironment(null);
  }
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class Example implements NotificationListener {
  private Environment environment;

  public Example() {
    //setup here
    this.environment = Environment.PARTY;
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + "millis.");
  
    NotificationManager manager = getNotificationManager(notification.getType());
    manager.processNotification(notification);
    
  }
  
  public Environment getEnvironment() {
    return this.environment;
  }

  public void setEnvironment(Environment e) {
    this.environment = e;
  }
}

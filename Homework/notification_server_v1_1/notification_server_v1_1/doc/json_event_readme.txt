Assignment Description of Events:

Twitter: time stamp, tweet author, tweet text, priority (1-4 where 1 is lowest priority and 4 is highest), number of retweets, number of favorites
Email: time stamp, email sender, email text, priority (1-4 where 1 is lowest priority and 4 is highest), email content summary (1-3 where 1 is positive, 2 neutral, and 3 negative)
Text message: time stamp, text sender, text, priority (1-4 where 1 is lowest priority and 4 is highest), text content summary (1-3 where 1 is positive, 2 neutral, and 3 negative)
Phone call: time stamp, caller (name or phone number), priority (1-4 where 1 is lowest priority and 4 is highest)
Voice Mail: time stamp,  caller (name or phone number), voicemail message as text, priority (1-4 where 1 is lowest priority and 4 is highest), voicemail content summary (1-3 where 1 is positive, 2 neutral, and 3 negative)


JSON Format for Events:

type: string -> "Tweet", "Email", "TextMessage", "MissedCall", "VoiceMail"
timestamp: in milliseconds from sketch start, e.g. 200 = 0.2 seconds
sender: string of sender/tweet author/caller name/id
priority: int from 1-4 (low to high)

//optional parameters
message: string, content of message/tweet, should be omitted for MissedCall event
contentSummary: int from 1-3, should be omitted for Tweet and MissedCall events
retweets: number of retweets, should be omitted for non-Tweet events
favorites: number of favorites, should be omitted for non-Tweet events

see exampleData.json in the /data folder of example sketch to test, those events follow below:

[
  {
    "type": "TextMessage",
    "timestamp": 100,
    "sender": "Alan Parsons",
    "message": "Whassup?",
    "priority": 1,
    "contentSummary": 2
  },
  {
    "type": "Tweet",
    "timestamp": 3000,
    "sender": "Dan of Steel",
    "message": "WHY WOULD YOU NOT PUNT, OMG",
    "priority": 1,
    "retweets": 3,
    "favorites": 1
  },
  {
    "type": "MissedCall",
    "timestamp": 6000,
    "sender": "Alan Parsons",
    "priority": 1
  },
  {
    "type": "VoiceMail",
    "timestamp": 12000,
    "sender": "Alan Parsons",
    "message": "Dude! You gotta call me.",
    "priority": 2,
    "contentSummary": 2
  },
  {
    "type": "Tweet",
    "timestamp": 15000,
    "sender": "Dan of Steel",
    "message": "FIRE PAUL JOHNSON, LMAO, WHO ARE WE GONNA GET INSTEAD????",
    "priority": 1,
    "retweets": 0,
    "favorites": 0
  },
  {
    "type": "Email",
    "timestamp": 18000,
    "sender": "Engineer's Bookstore",
    "message": "Going out of business sale",
    "priority": 1,
    "contentSummary": 2
  }
]
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:social_justice_hackathon/constant.dart';

class MongoDatabase {
  static Db? _db;

  static Future<void> connect() async {
    _db = await Db.create(mongo_url);
    await _db!.open();
    print('Connected to MongoDB');
  }

  static Future<void> close() async {
    await _db!.close();
    print('Disconnected from MongoDB');
  }

  static DbCollection getCollection(String collectionName) {
    return _db!.collection(collectionName);
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    await connect(); // Connect to your MongoDB database

    final usersCollection = _db?.collection('users'); // Adjust the collection name as necessary

    var user = await usersCollection?.findOne({
      'email': email,
      'password': password, // Ensure password is stored securely (hashed, not plain text)
    });

    await _db?.close(); // Close the connection

    return user != null ? Map<String, dynamic>.from(user) : null; // Return user data as a Map
  }

  Future<void> insertEvent(Map<String, dynamic> eventData) async {
    await connect(); // Connect to your MongoDB database

    final eventsCollection = _db?.collection('events'); // Adjust the collection name as necessary

    await eventsCollection?.insertOne(eventData); // Insert the event data

    await _db?.close(); // Close the connection
  }

  
  //function to fetch all events from events
  Future<List<Map<String, dynamic>>> fetchAllEvents() async {
    await connect(); // Connect to your MongoDB database

    final eventsCollection = _db?.collection('events'); // Adjust the collection name as necessary

    var events = await eventsCollection?.find().toList(); // Fetch all events

    await _db?.close(); // Close the connection

    return events != null ? List<Map<String, dynamic>>.from(events) : []; // Return events data as a List
  }

  

Future<Map<String, dynamic>?> fetchEvent(String eventId) async {
  await connect(); // Connect to your MongoDB database

  try {
    final eventsCollection = _db?.collection('events');

   
    // Convert the string eventId to ObjectId
    var eventObjectId = ObjectId.fromHexString(eventId);

    var event = await eventsCollection?.findOne({
      '_id': eventObjectId, // Use the ObjectId here
    });

    return event != null ? Map<String, dynamic>.from(event) : null; // Return event data
  } catch (e) {
    print('Error fetching event: $e');
    return null; // Handle error case
  } finally {
    await _db?.close(); // Ensure the connection is closed
  }
}




// MongoDB ticket insertion function
Future<void> insertTicket(Map<String, dynamic> ticketData) async {
  await connect(); // Connect to your MongoDB database

  final ticketsCollection = _db?.collection('tickets'); // Adjust the collection name as necessary

  await ticketsCollection?.insert(ticketData); // Insert the ticket data

  await _db?.close(); // Close the connection
}

  Future<List<Map<String, dynamic>>> getEvents(String selectedTab) async {
    // Connect to the database
    await connect();

    // Get the collection
    final eventsCollection = _db?.collection('events');

    // Get the current date formatted as 'yyyy-MM-dd'
    DateTime now = DateTime.now();
    String formattedNow = DateFormat('yyyy-MM-dd').format(now);

    var query;

    if (selectedTab == 'Live') {
      // Events currently happening
      query = await eventsCollection?.find({
        'user_id': '<user_id>',
        'start': formattedNow,
        'end': {'\$gte': formattedNow}
      }).toList();
    } else if (selectedTab == 'Upcoming') {
      // Events in the future
      query = await eventsCollection?.find({
        'user_id': '<user_id>',
        'start': {'\$gt': formattedNow}
      }).toList();
    } else if (selectedTab == 'Past') {
      // Past events
      query = await eventsCollection?.find({
        'user_id': '<user_id>',
        'end': {'\$lte': formattedNow}
      }).toList();
    } else {
      // All events if no specific tab is selected
      query = await eventsCollection?.find({
        'user_id': '<user_id>'
      }).toList();
    }
    return query;
    }

}
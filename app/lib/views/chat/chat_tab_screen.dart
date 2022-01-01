import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/managers/preference_manager.dart';
import 'package:whatsapp_clone/views/home/contacts_screen.dart';
import 'chat_screen.dart';
import '../../models/contact.dart';
import '../../models/message.dart';
import '../../main.dart';

class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({Key? key}) : super(key: key);

  @override
  _ChatTabScreenState createState() => _ChatTabScreenState();
}

/// --------------------------------------------------------
/// AT THE BEGINNING CLIENT SENDS TO SERVER HIS CREDENTIALS,
/// THEN SERVER SENDS TO HIM ALL USERS ONLINE => I CAN SEE THEM CLICKING CHAT BUTTON
/// FLUTTER BUILDS THE CHAT LIST WITH THESE ITEMS
/// --------------------------------------------------------

/// Represents the chat list in the WhatsApp homepage.
class _ChatTabScreenState extends State<ChatTabScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  // Connect to server
  final IOWebSocketChannel mainChannel = IOWebSocketChannel.connect(server);

  // Contacts
  final List<Contact> contacts = [];

  // Stop looping if there is also the same message on the stream
  String lastMessage = '';

  @override
  void initState() {
    logIn();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Send online status to the server
        mainChannel.sink.add(jsonEncode({
          'operation': online,
          'body': {'phone': SharedPreferencesManager.getPhoneNumber()}
        }));
        break;

      // Send offline status to the server (app yet opens in background)
      case AppLifecycleState.paused:
        mainChannel.sink.add(jsonEncode({
          'operation': offline,
          'body': {'phone': SharedPreferencesManager.getPhoneNumber()}
        }));
        break;
      // On hard close app (remove from bg)
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: StreamBuilder(
            stream: mainChannel.stream,
            builder: (context, snapshot) {
              /*
              // Connection just done, client authentication
              if (firstClientMessage) {
                logIn();
                // Shows a blank page while waiting for first server response
                return buildChatList();
              }
              */
              // Check if server sends me something, ignoring the same data
              // The first part of message is the operation identifier,
              // last part the body
              if (snapshot.hasData && lastMessage != snapshot.data) {
                lastMessage = snapshot.data.toString();
                // Converts byte message in string
                var json = jsonDecode(snapshot.data.toString());
                var responseOperation = json['operation'];
                var body = json['body'];

                // Switch operations
                switch (responseOperation) {
                  // In this case, update chat list with new online user
                  // newUser: {"phone":"3347552773","username":"fede","photo":"photo"}
                  /*case online:
                    // Add the new user without shows him because there aren't messages
                    return addContact(body['online']);

                  // Server sends all registered client: add in list without showing
                   send a feedback to server for receiving eventually offline messages
                    mainChannel.sink.add(jsonEncode({
                      'operation': online,
                      'body': {
                        'phone': SharedPreferencesManager.getPhoneNumber()
                      }
                    }));
                    return addContacts(body['users']);
                    */

                  // In this case, an user send me a message, so update chat list
                  // chatWith: {phone: "zzz", message"xxxx"}
                  case message:
                    _updateContacts(body);
                    return _buildContactList();

                  // One or more message, while I am offline
                  case offlineMessages:
                    return updateListViewWithMessages(body['messages']);
                  // In this case, an user leaved the app,
                  // so change his status to offline
                  /*
                  case offline:
                    var phone = body['phone'];
                    for (var contact in contacts) {
                      if (contact.phone == phone) {
                        contact.isOnline = false;
                        break;
                      }
                    }
                    break;
                    */
                }
                // idle, nothing happens
              }
              // Simply build list view if there is some chat
              return _buildContactList();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Contact? contact = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const ContactsScreen()));
            // Check if i have to change list order
            // Check if this user is the last one whit whom I chat
            if (contact != null) {
              if (!contacts.contains(contact)) {
                contacts.add(contact);
              }
              contacts.sort((b, a) => a.messages.last.timestamp
                  .compareTo(b.messages.last.timestamp));
              /*
              if (contact.messages.last.timestamp
                  .isAfter(contacts.first.messages.last.timestamp)) {
                contacts.remove(contact);
                contacts.insert(0, contact);
              }
              */
              setState(() {});
            }
          },
          child: const Icon(Icons.chat),
        ));
  }

  /// Build the Widget representing a contact with his info
  buildListTile(Contact contact) {
    return ListTile(
      onTap: () async {
        // Start Chat screen
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                    contact: contact,
                    addMessage: false,
                  )),
        );
        // Remove notify icon
        contact.toRead = 0;
        // Sort from last received to first received
        contacts.sort((b, a) =>
            a.messages.last.timestamp.compareTo(b.messages.last.timestamp));
        /*
        // Check if this user is the last one whit whom I chat
        if (contact.messages.last.timestamp
            .isAfter(contacts.first.messages.last.timestamp)) {
          contacts.remove(contact);
          contacts.insert(0, contact);
        }
        */

        setState(() {});
      },
      leading:
          CircleAvatar(radius: 25, backgroundImage: contact.profileImage.image),
      title: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(contact.username,
                style: const TextStyle(
                    color: textColor, fontWeight: FontWeight.bold)),
            Column(
              children: [
                Text(
                  // Timestamp of last message of the chat between us
                  DateFormat('HH:mm').format(
                      contact.messages[contact.messages.length - 1].timestamp),
                  style: TextStyle(
                      color: contact.toRead > 0 ? secondaryColor : Colors.grey,
                      fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Stack(alignment: Alignment.centerRight, children: [
              Row(
                children: [
                  if (!contact.messages[contact.messages.length - 1].fromServer)
                    const Icon(Icons.done_all, color: Colors.blue, size: 16),
                  Flexible(
                    child: Text(
                      // Last message of the chat between us
                      contact.messages[contact.messages.length - 1].text,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Show notification if there is a message to read
              if (contact.toRead > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.circle, color: secondaryColor, size: 20),
                    Text(
                      '${contact.toRead}',
                      style: const TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    )
                  ]),
                )
            ]),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.1,
          )
        ],
      ),
    );
  }

  /// Authentication with server, I send my credentials
  void logIn() {
    //firstClientMessage = !firstClientMessage;
    mainChannel.sink.add(jsonEncode({
      'operation': login,
      'body': {
        'phone': SharedPreferencesManager.getPhoneNumber(),
        'username': SharedPreferencesManager.getUsername(),
        'photo': SharedPreferencesManager.getProfilePic(),
      }
    }));
  }

  /*
  /// Build a contact parsing from json
  buildContact(dynamic jsonUser) {
    return Contact(
      jsonUser['phone'],
      jsonUser['username'],
      Image.memory(base64Decode(jsonUser['photo'])),
      jsonUser['isOnline'] == 'false' ? false : true,
    );
  }
  */

  /// Build a ListView
  ListView _buildContactList() {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          //return contacts[index].messages.isNotEmpty
          //? buildListTile(contacts[index])
          return buildListTile(contacts[index]);
          //: const Divider(thickness: 0.0, height: 0.0);
        });
  }

  /*
  /// Get a contact sent from the server
  addContact(String json) {
    var jsonUser = jsonDecode(json);
    Contact c = buildContact(jsonUser);
    contacts.add(c);
    //contactsListView.add(buildListTile(c));
    return buildListView();
  }

  /// Get contacts sent from the server
  addContacts(String jsonString) {
    var json = jsonDecode(jsonString);
    for (var msg in json) {
      addContact(msg);
    }
    return buildListView();
  }
  */

  /// Another client sends me a message, update list view pushing him as head
  _updateContacts(dynamic json) {
    var message = jsonDecode(json['message']);
    var sender = jsonDecode(json['user']);
    int i = contacts.indexWhere((element) => element.phone == sender['phone']);
    Contact contact =
        (i == -1) ? Contact.fromJson(sender) : contacts.removeAt(i);
    // New message to read! ()
    contact.toRead++;
    contact.messages.add(Message(message['message'], fromServer: true));
    contacts.insert(0, contact);
  }

  /// Another client sends me a message while I am offline, update list view pushing him as head
  updateListViewWithMessages(String jsonString) {
    var json = jsonDecode(jsonString);
    for (var msg in json) {
      _updateContacts(msg);
    }
    return _buildContactList();
  }
}

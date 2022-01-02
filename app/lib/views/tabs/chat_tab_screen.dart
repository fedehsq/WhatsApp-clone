import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/api.dart';
import 'package:whatsapp_clone/managers/preference_manager.dart';
import 'package:whatsapp_clone/views/contacts/contacts_screen.dart';
import '../chat/chat_screen.dart';
import '../../models/contact.dart';
import '../../models/message.dart';
import '../../main.dart';

// Class reprsenting chat screen of WhatsApp.
class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({Key? key}) : super(key: key);

  @override
  _ChatTabScreenState createState() => _ChatTabScreenState();
}

/// Represents the chat list in the WhatsApp homepage.
class _ChatTabScreenState extends State<ChatTabScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  /// Connection with WhatsApp's server.
  final IOWebSocketChannel mainChannel = IOWebSocketChannel.connect(server);

  /// WhatsApp's registered users with a chat with this client.
  final List<Contact> contacts = [];

  /// Avoid duplicated messages after a setState(() {}) invocation.
  String lastMessage = '';

  @override
  void initState() {
    // Authentication with server, sends client phone number
    mainChannel.sink.add(jsonEncode({
      'operation': login,
      'body': {
        'phone': SharedPreferencesManager.getPhoneNumber(),
      }
    }));
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // Send online status to the server
      case AppLifecycleState.resumed:
        mainChannel.sink.add(jsonEncode({
          'operation': online,
          'body': {'phone': SharedPreferencesManager.getPhoneNumber()}
        }));
        break;

      // Send offline status to the server (app yet opened in background)
      case AppLifecycleState.paused:
        mainChannel.sink.add(jsonEncode({
          'operation': offline,
          'body': {'phone': SharedPreferencesManager.getPhoneNumber()}
        }));
        break;
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
              // Check if server sends something, ignoring replicate messages
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
                  // Client sends a message, sort chat list
                  case message:
                    _updateContacts(body);
                    break;
                  
                  /// Client(s) sends [json] message(s) while [this] was offline,
                  /// updates [contacts] pushing the last sender as head.
                  case offlineMessages:
                    var messages = jsonDecode(json);
                    for (var msg in messages) {
                      _updateContacts(msg);
                    }
                    break;
                }
              }
              // Build contacts list view
              return _buildContactList();
            }),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.chat),
          onPressed: () async {
            // Client with whom a chat maybe starts from another screen
            Contact? contact = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const ContactsScreen()));
            // Replace the contact in case the chat starts from ContactsScreen
            if (contact != null) {
              contacts.remove(contact);
              contacts.add(contact);
              contacts.sort((b, a) => a.messages.last.timestamp
                  .compareTo(b.messages.last.timestamp));
              setState(() {});
            }
          },
        ));
  }

  /// Client sends a [json] message, updates [contacts] pushing the sender as head.
  _updateContacts(dynamic json) {
    var message = jsonDecode(json['message']);
    var sender = jsonDecode(json['user']);
    int i = contacts.indexWhere((element) => element.phone == sender['phone']);
    Contact contact =
        (i == -1) ? Contact.fromJson(sender) : contacts.removeAt(i);
    // New message to read
    contact.toRead++;
    contact.messages.add(Message(message['message'], fromServer: true));
    contacts.insert(0, contact);
  }

  /// Builds and displays the [contacts] ListView.
  ListView _buildContactList() {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildContactListTile(contacts[index]);
        });
  }

  /// Build the Widget representing a [contact] with his info.
  _buildContactListTile(Contact contact) {
    return ListTile(
      onTap: () async {
        // Start Chat screen
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(
                    contact: contact,
                    // Messages are received only on this stream
                    addMessage: false,
                  )),
        );
        // Remove notify icon
        contact.toRead = 0;
        // Sort from last received to first received
        contacts.sort((b, a) =>
            a.messages.last.timestamp.compareTo(b.messages.last.timestamp));
        setState(() {});
      },
      // Contact's profile image
      leading:
          CircleAvatar(radius: 25, backgroundImage: contact.profileImage.image),
      title: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Contact's username
            Text(contact.username,
                style: const TextStyle(
                    color: textColor, fontWeight: FontWeight.bold)),
            Column(
              children: [
                Text(
                  // Timestamp of last message
                  DateFormat('HH:mm').format(contact.messages.last.timestamp),
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
                  // Blu color if the last message is received from contact
                  if (!contact.messages.last.fromServer)
                    const Icon(Icons.done_all, color: Colors.blue, size: 16),
                  Flexible(
                    child: Text(
                      // Last message of the chat
                      contact.messages.last.text,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Displays a notification if there is a message to read
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
}


import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:whatsapp_clone/SelectContact.dart';
import 'Chat.dart';
import 'Contact.dart';
import 'Message.dart';
import 'main.dart';

class ChatList extends StatefulWidget {

  @override
  _ChatListState createState() => _ChatListState();
}

/// --------------------------------------------------------
/// AT THE BEGINNING CLIENT SENDS TO SERVER HIS CREDENTIALS,
/// THEN SERVER SENDS TO HIM ALL USERS ONLINE => I CAN SEE THEM CLICKING CHAT BUTTON
/// FLUTTER BUILDS THE CHAT LIST WITH THESE ITEMS
/// --------------------------------------------------------

class _ChatListState extends State<ChatList> {

  // Connect to server
  final mainChannel = IOWebSocketChannel.connect('ws://192.168.1.12:8080');

  // Contacts show in UI if there is at least one message (Chat list)
  final List<Contact> contacts = [];
  // All ListTile (UI chat)
  final List<ListTile> contactsListView = [];

  // Last contact with whom i've chatted, thanks to this variable,
  // when i receive a message, the sender is put as head in the chat list
  Contact lastContactChat;

  // At the first access i send to the server my credentials: phone, username, photo
  bool firstClientMessage = true;

  // Stop looping if there is also the same message on the stream
  String lastMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: mainChannel.stream,
            builder: (context, snapshot) {
              // Connection just done, client authentication
              if (firstClientMessage) {
                logIn();
                // Shows a blank page while waiting for first server response
                return Text('');
              }
              // Check if server sends me something, ignoring the same data
              // The first part of message is the operation identifier,
              // last part the body
              if (snapshot.hasData && lastMessage != snapshot.data) {
                lastMessage = snapshot.data;
                var message = '${snapshot.data}'.split(": ")[0];
                var json = '${snapshot.data}'.split(": ")[1];
                // Switch operations
                switch (message) {
                // In this case, update chat list with new online user
                // newUser: {"phone":"3347552773","username":"fede","photo":"photo"}
                  case "NEW_USER":
                  // Add the new user without shows him because there aren't messages
                    return addContact(json);
                // Server send to just logged client the list of other users
                  case "ALL_USERS":
                    return addAllContacts(json);
                // In this case, an user send me a message, so update chat list
                // chatWith: {phone: "zzz", message"xxxx"}
                  case "MESSAGE_FROM":
                    return updateListViewWithMessage(json);
                // impossible case
                  default:
                    return Text('');
                }
                // idle, nothing happens
              } else {
                // Simply build list view if there is some chat
                return buildChatList();
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Contact contact = await Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) =>
                    SelectContact(online: contacts, lastContactChat: lastContactChat)
                )
            );
            // Check if i have to change list order
            // Check if this user is the last one whit whom I chat
            if (contact != null && lastContactChat == null) {
              setState(() {
                lastContactChat = contact;
              });
            }
            if (contact != null && lastContactChat != null
                && contact.messages[contact.messages.length - 1].timestamp
                .isAfter(
                lastContactChat.messages[lastContactChat.messages.length - 1]
                    .timestamp)) {
              setState(() {
                lastContactChat = contact;
              });
            }
          },
          child: Icon(Icons.chat),
        )
    );
  }

  /// Build the Widget representing a contact with his info
  buildListTile(Contact contact) {
    return ListTile(
      onTap: () async {
        // Remove notify icon
        contact.toRead = 0;
        // Start Chat screen
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Chat(contact: contact)),
        );
        // Check if this user is the last one whit whom I chat
        if (lastContactChat == null) {
          setState(() {
            lastContactChat = contact;
          });
        } else if (contact.messages[contact.messages.length - 1].timestamp
            .isAfter(
            lastContactChat.messages[lastContactChat.messages.length - 1]
                .timestamp)) {
          setState(() {
            lastContactChat = contact;
          });
        }
      },
      leading: CircleAvatar(
          radius: 25,
          backgroundImage: contact.profileImage.image),
      title:
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(contact.username, style: TextStyle(
                color: TEXT_COLOR, fontWeight: FontWeight.bold)
            ),
            Column(
              children: [
                Text(
                  // Timestamp of last message of the chat between us
                  DateFormat('HH:mm').format(
                      contact.messages[contact.messages.length - 1].timestamp),
                  style: TextStyle(
                      color: contact.toRead > 0 ? SECONDARY_COLOR : Colors.grey,
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
            child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Row(
                    children: [
                      if (!contact.messages[contact.messages.length - 1]
                          .fromServer)
                        Icon(Icons.done_all,
                            color: Colors.blue, size: 16
                        ),
                      Flexible(
                        child: Text(
                          // Last message of the chat between us
                          contact.messages[contact.messages.length - 1].text,
                          style: TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Show notification if there is a message to read
                  if (contact.toRead > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                                Icons.circle, color: SECONDARY_COLOR, size: 20),
                            Text('${contact.toRead}', style: TextStyle(
                                color: PRIMARY_COLOR,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),)
                          ]
                      ),
                    )
                ]),
          ),
          Divider(color: Colors.grey, thickness: 0.1,)
        ],
      ),
    );
  }


  /// At every received message, add last message in the preview and put
  /// sender as head item, the last items don't change
  ListView sortContacts(String sender) {
    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].phone == sender) {
        // Put him in head
        Contact c = contacts.removeAt(i);
        contactsListView.removeAt(i);
        print(c.messages.length);
        contactsListView.insert(0, buildListTile(c));
        contacts.insert(0, c);
        break;
      }
    }
    return buildListView(contactsListView);
  }

  /// Build the chat list view
  buildChatList() {
    if (lastContactChat != null) {
      print(lastContactChat.username);
    }
    if (contacts.isNotEmpty) {
      return sortContacts(lastContactChat == null
          ? contacts[0].phone
          : lastContactChat.phone);
    } else {
      return Text('');
    }
  }

  /// Authentication with server, I send my credentials
  void logIn() {
    firstClientMessage = !firstClientMessage;
    // Read from disk
    SharedPreferences.getInstance().then((value) {
      var json = {
        'phone': value.getString(PHONE_NUMBER),
        'username': value.getString(USERNAME),
        'photo': value.getString(PHOTO)
      };
      mainChannel.sink.add('LOGIN: ' + jsonEncode(json));
    });
  }

  /// Build a contact parsing from json
  buildContact(dynamic jsonUser) {
    return Contact(
        jsonUser['phone'],
        jsonUser['username'],
        Image.memory(base64Decode(jsonUser['photo'])),
        [Message('', true)], // message list
        0 // No message to read when user comes online
    );
  }

  /// Build a ListView
  ListView buildListView(List l) {
    return ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: l.length,
        itemBuilder: (BuildContext context, int index) {
          return contacts[index].messages.length > 1 ? l[index] : Divider(
              thickness: 0.0, height: 0.0);
        });
  }

  /// When a new user comes online, Server send to him all connected users
  addAllContacts(String json) {
    var jsonUsersArray = jsonDecode(json);
    for (var jsonUser in jsonUsersArray) {
      Contact c = buildContact(jsonUser);
      contacts.add(c);
      contactsListView.add(buildListTile(c));
    }
    return buildListView(contactsListView);
  }

  /// When a new user comes online, Server send to all other clients this user
  addContact(String json) {
    var jsonUser = jsonDecode(json);
    Contact c = buildContact(jsonUser);
    contacts.add(c);
    contactsListView.add(buildListTile(c));
    return buildListView(contactsListView);
  }

  /// Another client sends me a message, update list view pushing him as head
  updateListViewWithMessage(String json) {
    var decode = jsonDecode(json);
    var phone = decode['phone'];
    var message = decode['message'];
    for (var contact in contacts) {
      if (contact.phone == phone) {
        lastContactChat = contact;
        // New message to read! ()
        contact.toRead++;
        contact.messages.add(Message(message, true));
        // put his message as head of chat list
        return sortContacts(contact.phone);
      }
    }
  }
}



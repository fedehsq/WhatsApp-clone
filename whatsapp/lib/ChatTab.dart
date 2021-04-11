
import 'dart:convert';

import 'package:flutter/material.dart';
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

/// POSSO USARE SOLO CHAT CONTACTS, E MOSTRARLI QUA SSE LA LISTA MESSAGE NON è VUOTA

class _ChatListState extends State<ChatList> {

  // Connect to server
  final mainChannel = IOWebSocketChannel.connect('ws://192.168.1.10:8080');

  // Contacts show in UI if there is at least one message (Chat list)
  final List<Contact> contacts = [];


  // Last contact with whom i've chatted, thanks to this variable,
  // when i receive a message, the sender is put as head in the chat list
  var lastContactChat;

  // At the first access i send to the server my credentials: phone, username, photo
  var firstClientMessage = true;
  // Server sends to me online contacts
  ///var firstServerMessage = true;

  // Stop looping if there is also the same message on the stream
  var lastMessage = '';

  /// Build the Widget representing a contact with his info
  buildListTile(Contact contact) {
    return ListTile(
      onTap: ()  {
        // ----- Even if i wait, the build method is called -----
        // FLUTTER IS MAGIC!
        // Start Chat screen
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Chat(contact: contact)),
        );
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
            Text(contact.username, style: TextStyle(color: TEXT_COLOR),),
            // show hour only there is a message
            if (contact.messages[contact.messages.length - 1].text.isNotEmpty)
              Text(
                  // Timestamp of last message of the chat between us
                  contact.messages[contact.messages.length - 1].timestamp,
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              )
          ],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                if (!contact.messages[contact.messages.length - 1].fromServer)
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
          ),
          Divider(color: Colors.grey, thickness: 0.1,)
        ],
      ),
    );
  }


  /// At every received message, add last message in the preview and put
  /// sender as head item, the last items don't change
  List<ListTile> buildSortedChatList(String sender) {
    List<ListTile> l = [];
    for (int i = 0; i < contacts.length; i++) {
      // Check if chat is empty, in this case, not show!
      if (contacts[i].messages.length > 1) {
        if (contacts[i].phone == sender) {
          // Put him in head
          l.insert(0, buildListTile(contacts[i]));
        } else {
          // Rebuilt previous item in the same way (pass last chat message!)
          l.add(buildListTile(contacts[i]));
        }
      }
    }
    return l;
  }

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
                // In this case, update chat list with new online users
                // newUser: [{"phone":"3347552773","username":"fede","photo":"photo"}]
                  case "newUser":
                  // Add the new user without shows him because there aren't messages
                    return updateChatContacts(json);

                // In this case, an user send me a message, so update chat list
                // chatWith: {phone: "zzz", message"xxxx"}
                  case "chatWith":
                    print("chat with");
                    return updateListViewWithMessage(json);
                // impossible case
                  default:
                    return Text('');
                }
                // idle, nothing happens
              } else {
                // Simply build list view if there is some some chat
                print("nothing received");
                return buildChatList();
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) =>
                    SelectContact(online: contacts)
                )
            );
            // Check if i have to change list order
            lastContactChat = result?? lastContactChat;
          },
          child: Icon(Icons.chat),
        )
    );
  }

  /// Build the chat list view
  buildChatList() {
    print("build chat list " + lastContactChat.toString());
    if (contacts.isNotEmpty) {
      List l = buildSortedChatList(lastContactChat == null
          ? contacts[0].phone
          : lastContactChat.phone);
      return ListView.builder(
          padding: EdgeInsets.only(top: 8),
          itemCount: l.length,
          itemBuilder: (BuildContext context, int index) {
            return l[index];
          });
    } else {
      return Text('');
    }
  }

  /// Authentication with server, I send my credentials
  void logIn() {
    firstClientMessage = !firstClientMessage;
    // Read from disk
    SharedPreferences.getInstance().then((value) {
      String message = 'login ';
      message += value.getString(PHONE_NUMBER) + " ";
      message += value.getString(USERNAME) + " ";
      message += value.getString(PHOTO) + " ";
      /// message += "photo";
      mainChannel.sink.add(message);
    });
  }

  /// When a new user comes online, add him to contacts list but not show in UI
  updateChatContacts(String json) {
    var contactList = [];
    var jsonUsersArray = jsonDecode(json);
    for (var jsonUser in jsonUsersArray) {
      Contact contact = Contact(
          jsonUser['phone'],
          jsonUser['username'],
          Image.memory(base64Decode(jsonUser['photo'])), /// photo --------------------------------------------
          [Message('', true)] // message list
      );
      // add to contacts only new contacts!
      if (!contacts.contains(contact)) {
        contacts.add(contact);
      }
    }
    // build list view
    for (var contact in contacts) {
      // Shows in the UI only if chat isn't empty!
      if (contact.messages.length > 1) {
        contactList.add(buildListTile(contact));
      }
    }
    return ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: contactList.length,
        itemBuilder: (BuildContext context, int index) {
          return contactList[index];
        });

  }

  /// Another client sends me a message, update list view pushing him as head
  updateListViewWithMessage(String json) {
    // I must recognize the sender and add his message to his list
    // I know who he is because the first part of message is the sender
    // (phone number)
    var decode = jsonDecode(json);
    print(decode);
    var phone = decode['phone'];
    var message = decode['message'];
    for (var contact in contacts) {
      if (contact.phone == phone) {
        lastContactChat = contact;
        contact.messages.add(Message(message, true));
        // put his message as head of chat list
        List l = buildSortedChatList(contact.phone);
        return ListView.builder(
            padding: EdgeInsets.only(top: 8),
            itemCount: l.length,
            itemBuilder: (BuildContext context, int index) {
              return l[index];
            });
      }
    }
  }
}



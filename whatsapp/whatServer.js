const WebSocket = require("ws");
// start the server and specify the port number
const port = 8080;
const webServerSocket = new WebSocket.Server({ port: port });
console.log(`[WebSocket] Starting WebSocket server on localhost:${port}`);

// Represents the user "online" in the services (if i create add socket and create toJson with only the 3 params i can remove SocketUser)
class User {
  constructor(phone, username, photo, mainSocket, chatSocket) {
    this.phone = phone;
    this.username = username;
    this.photo = photo;
    this.mainSocket = mainSocket;
    this.chatSocket = chatSocket;
  }

  // To send over socket
  toJson() {
    return '{"phone":' + '"'+ this.phone + '", "username":' + '"'+ this.username + '", "photo":' + '"'+ this.photo + '"}';
  }

  static staticToJson(user) {
    return '{"phone":' + '"'+ user.phone + '", "username":' + '"'+ user.username + '", "photo":' + '"'+ user.photo + '"}';

  }

}

// Sender phone number, text message, timestamp.
// The destination is not needed here
class Message {
  constructor(phone, message, timestamp) {
    this.phone = phone;
    this.message = message;
    // Timestamp needed to avoid duplicate same message in the client
    this.timestamp = timestamp;
  }
}

// IL PRIMO MESSAGGIO CHE MI SARà INVIATO è IL PHONE SEL CLIENT, COSì CREO LA COPPIA 
// CLIENT SOCKET
var users = [];

// -----------------  JS è single thread ---------------
// It doesn't create another thread, but different stacks, it simulates multithread 
//=> i.e the var chatUser is different for every connectiom

// Every client has 2 connection with this server,
// one stable and the other one is opened when client opens a chat 
webServerSocket.on("connection", (socket) => {
  console.log("connected");  
  // User in session, this var is useful when I connect with 2nd connection 
  var chatUser;
  // Client send a message to the server
  socket.on("message", (message) => {
    // "LOGIN:{"phone":"3347552773","username":"fede","photo":"encoded64photo"}"
    if (message.startsWith("LOGIN")) {
      console.log("LOGIN");
      var json = JSON.parse(message.split("LOGIN: ")[1]);
      // Last field is the other socket of a client, the chat socket, when he comes online, it is null
      var user = new User(json['phone'], json['username'], json['photo'], socket, null);
      users.push(user);      
      // Send to all OTHER clients the new connected users
      users.forEach((client) => {
        if (client.phone != user.phone)
        client.mainSocket.send("NEW_USER: " + user.toJson());
      });
      // Send to new client all users!
      user.mainSocket.send("ALL_USERS: [" + users.map(User.staticToJson) +"]");
    }

    // In app an user opens Chat screen
    // "OPEN_CHAT_SOCKET:{"phone":"3347552773"}"
    if (message.startsWith("OPEN_CHAT_SOCKET")) {
      console.log("OPEN_CHAT_SOCKET");
      // Here i have another connection with client, beacuse in app i connect again to this server
      // Add this new connection as parameter of User
      var json = JSON.parse(message.split("OPEN_CHAT_SOCKET: ")[1]);
      var phone = json['phone'];
      // Search client in list
      for (i = 0; i < users.length; i++) {
        if (users[i].phone == phone) {
            // Add new chat socket to him! He just entered in Chat screen in app
            users[i].chatSocket = socket;
            // I have to assign chatUser! 
            chatUser = users[i];
            break;
        }
      }
    }

    // "SEND_TO:{"phone":"3347552773","message":"Hello, world!"}"
    if (message.startsWith("SEND_TO")) {
      console.log("SEND_TO");
      var json = JSON.parse(message.split("SEND_TO: ")[1]);
      var dest = json['dest'];
      var msg = json['message'];
      // search dest and send the message in the two socket of the client
      for (var i = 0; i < users.length; i++) {
        if (users[i].phone == dest) {
          var message = new Message(chatUser.phone, msg, new Date());
          // Send message to the 2 socket of the destination! (ChatTab & Chat screen in app)
          users[i].mainSocket.send("MESSAGE_FROM: " + JSON.stringify(message));
          // Check that he is in a Chat screen
          if (users[i].chatSocket != null) {
            users[i].chatSocket.send("MESSAGE_FROM: " + JSON.stringify(message));
          }
          console.log("mess send");
        }
      }
    }
  })
})


/*
   // CLIENT WHANTS TO ADD A CHAT TO THE SCREEN => 
    
*/

// Broadcast aka send messages to all connected clients

//ws.on("message", (message) => { 
  //  wss.clients.forEach((client) => {
    //     if (client.readyState === WebSocket.OPEN)  {
      //        client.send(message);
        // } });
          //console.log(`[WebSocket] Message ${message} was received`); }); 
        //});
        
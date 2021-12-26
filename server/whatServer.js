const WebSocket = require('ws');
const fs = require('fs');

// start the server and specify the port number
const port = 8080;
const webServerSocket = new WebSocket.Server({ port: port });
console.log(`[WebSocket] Starting WebSocket server on localhost:${port}`);

// Represents the registered onlineUsers in the service
class ServiceUser {
  constructor(phone, username, photo, mainSocket) {
    this.phone = phone;
    this.username = username;
    this.photo = photo;
    this.mainSocket = mainSocket;
    this.chatSocket = null;
    this.isOnline = false;
    // Enqueue messages when user is offline
    this.offlineMessages = [];
  }
}

 // To send over socket
 function toJson(user) {
  return '{"phone":' + '"'+ user.phone + '", "username":' + '"'+ user.username 
  + '", "photo":' + '"'+ user.photo +    '", "isOnline":' + '"'+ user.isOnline + '"}';
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


// This contains onlineUsers logged (<phone, [phone, username, photo, mainSocket, chatSocket]> )
var onlineUsers = new Map(); 

var registeredUsers = new Map(); 
// Read map from file
fs.readFile('users.json', 'utf8' , (err, data) => {
  if (data != '') {
    let j = JSON.parse(data);
    j.forEach(function(user) {
      // read all registered users
      registeredUsers.set(user['phone'], user);
    }, j);
  }
})


// -----------------  JS è single thread ---------------
// It doesn't create another thread, but different stacks, it simulates multithread 
//=> i.e the var sessionUser is different for every connection

// Every client has 2 connection with this server,
// one stable and the other one is opened when client opens a chat 
webServerSocket.on("connection", (socket) => {
  console.log("CONNECTION");  
  // ServiceUser in session, this var is useful when I connect with 2nd connection 
  var sessionUser;
  // Client send the register request message to the server
  socket.on("message", (message) => {
    // Request of registration, client sends only phone number
    if (message.startsWith("REQUEST")) {
      console.log("REQUEST");
      // If user is 
      let json = JSON.parse(message.split("REQUEST: ")[1]);
      // Try to get the user
      let phone = json['phone'];
      // Get client from map
      let user = registeredUsers.get(phone);
      if (user == null) {
        socket.send("OK");
        socket.close();
      } else {
        socket.send("KO");
      }
    }

    // Client registration
    if (message.startsWith("REGISTER")) {
        console.log("REGISTER");
        // If user is 
        let json = JSON.parse(message.split("REGISTER: ")[1]);
        // Save user to map
        let user = new ServiceUser(json['phone'], json['username'], json['photo'], null);
        // Add just registered user to map
        registeredUsers.set(json['phone'], user);
        // Write data in 'Output.txt' .
        fs.writeFile('users.json', JSON.stringify(Array.from(registeredUsers.values())), function(err) {
          if (err) {
            return console.log(err);
          }
        }); 
        socket.send("OK");
        socket.close();
    }

    // First message sended to server from client is his credentials
    // "LOGIN:{"phone":"3347552773","username":"fede","photo":"encoded64photo"}"
    if (message.startsWith("LOGIN")) {
      console.log("LOGIN");
      // If user is 
      let json = JSON.parse(message.split("LOGIN: ")[1]);
      // Last field is the other socket of a client, the chat socket, when he comes online, it is null
      //let user = new ServiceUser(json['phone'], json['username'], json['photo'], socket);
      let user = registeredUsers.get(json['phone']);
      user.mainSocket = socket;
      user.isOnline = true;
      // Send to all OTHER clients the new connected onlineUsers, and send to new user all the others
      let users = [];
      registeredUsers.forEach(function(value) {
        // Add to list all registered client
        users.push(toJson(value));
      }, registeredUsers);
      let toSend = "USERS: " + JSON.stringify(users);
      // send clients
      user.mainSocket.send(toSend);
      // Add just connected user to map
      onlineUsers.set(json['phone'], user);
    }

    // In app an user opens Chat screen
    // "OPEN_CHAT_SOCKET:{"phone":"3347552773"}"
    if (message.startsWith("OPEN_CHAT_SOCKET")) {
      console.log("OPEN_CHAT_SOCKET");
      // Here i have another connection with client, beacuse in app I connect again to this server
      // Add this new connection as parameter of ServiceUser
      let json = JSON.parse(message.split("OPEN_CHAT_SOCKET: ")[1]);
      // My id
      let phone = json[0]['phone'];
      let peer = onlineUsers.get(json[1]['dest']);
      // Add new chat socket to him! He just entered in Chat screen in app
      let user = onlineUsers.get(phone);
      user.chatSocket = socket;
      // I have to assign sessionUser! 
      sessionUser = user;
      // Get client from map
      if (peer == null) {
        user.chatSocket.send("OFFLINE: " + '{"phone":' + '"'+ registeredUsers.get(json[1]['dest']) + '"}');
      }
      
      /// SERVER MUST SENDS TO ALL CHAT SOCKET THE PEER STATUS, SO IN CLIENT I CAN ALWAYS REBUILD THE APPBAR WITH STAUS!
      //-------------- WHEN HE SENDS ONLINE CONTACT DI LA SETTO LA VARIABILE ONLINE A TRUE, QUANDO ESCONO DALL APP, IL SERVER RIMANDA A TUTTI I CONNESSI IL NUOVO STATO=> ALLE CHAT SOCKET! PERCHE MI INTERESSA LI, QUINDI IL VALORE DA ONLINE A OFFLINE LO CAMBIO NELLA CHAT SOCKET!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MA NON è VERO! ANCHE NELLE MAIN SOCKET! I.E NON SONO SULLA CHAT , UN UTENTE SI DISCONNETTE, AGGIORNO IL SUO VALORE NELLA MAIN SOCKET COSI QUANDO ENTRO IN CHAT HO IL VALORE AFFIORNto! QUINDI LO MANDO AD ENTRAMBE!
      // LOGOUT USERNAME => E NELL'APP PARSO ANCHE QUESTO CASE COME MESSAGGIO RICEVUTO, E AGGIORNO STATUS!
      // SERVER INVIA STATUS 'OFFLINE' E IL NOME DELL USCENTE! NELL APP CONTROLLO CHE COTACT.PHONE == USCENTE PER NASCONDERE LO STATUS ONLINE
      /*
      let peer = onlineUsers.get(json['dest']);
      let status = peer == undefined ? 'OFFLINE' : 'ONLINE';
      sessionUser.send("STATUS: " + JSON.stringify(status));
      */
    }

    // "SEND_TO:{"phone":"3347552773","message":"Hello, world!"}"
    if (message.startsWith("SEND_TO")) {
      console.log("SEND_TO");
      let json = JSON.parse(message.split("SEND_TO: ")[1]);
      let dest = json['dest'];
      let msg = json['message'];
      // Create message to send
      let packet = new Message(sessionUser.phone, msg, new Date());
      // Search in registered dest and send the message in the two socket of him
      let peer = registeredUsers.get(dest);
      // If peer is offline, enqueue the messages
      if (!peer.isOnline) {
        console.log("qua");
        peer.offlineMessages.push(JSON.stringify(packet));
      } else {
        // Send message to the 2 socket of the destination! (ChatTab & Chat screen in app)
        peer.mainSocket.send("MESSAGE_FROM: " + JSON.stringify(packet));
        // Check that if he is in a Chat screen
        if (peer.chatSocket != null) {
          peer.chatSocket.send("MESSAGE_FROM: " + JSON.stringify(packet));
        }
      }
    }

    // "ONLINE:{"phone":"xxxx"}
    // On reopen abb from bg
    if (message.startsWith("ONLINE")) {
      console.log("ONLINE");
      
      let json = JSON.parse(message.split("ONLINE: ")[1]);
      // My id
      let phone = json['phone'];
      let user =  onlineUsers.get(phone);
      user.isOnline = true;
      
      // Send to this user the enqueued messages
      user.mainSocket.send("MESSAGES_FROM: " + JSON.stringify(user.offlineMessages));
      if (user.chatSocket != null) {
        user.chatSocket.send("MESSAGES_FROM: " + JSON.stringify(user.offlineMessages));
      }
      user.offlineMessages = [];

      // Send to all socket that user is online again
      onlineUsers.forEach(function(value) {
        if (value != user) {
          // Send to new client all onlineUsers
          value.mainSocket.send("ONLINE: " + '{"phone":' + '"'+ phone + '"}');
          if (value.chatSocket != null) {
            value.chatSocket.send("ONLINE: " + '{"phone":' + '"'+ phone + '"}');
          }
        }
      }, onlineUsers);
    }

    // "OFFLINE:{"phone":"xxxx"}
    if (message.startsWith("OFFLINE")) {
        console.log("OFFLINE");
        let json = JSON.parse(message.split("OFFLINE: ")[1]);
        // My id
        let phone = json['phone'];
        onlineUsers.get(phone).isOnline = false;
        // Remove from map
       // onlineUsers.delete(phone);
        // Send to all socket that user is nomore online
        onlineUsers.forEach(function(value) {
          // Send to new client all onlineUsers
            value.mainSocket.send("OFFLINE: " + '{"phone":' + '"'+ phone + '"}');
            if (value.chatSocket != null) {
              value.chatSocket.send("OFFLINE: " + '{"phone":' + '"'+ phone + '"}');
            }
          }, onlineUsers);
          /*
        onlineUsers.forEach(function(key, value) {
          // Main socket
          value.mainSocket.send("LOGOUT: " + JSON.stringify(phone));
          // Check if user is on Chat tab
          if (value.chatSocket != null) {
            value.chatSocket.send("LOGOUT: " + JSON.stringify(phone))
          }
        }, onlineUsers);
        */
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
        
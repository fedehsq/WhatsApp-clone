const WebSocket = require("ws");
// start the server and specify the port number
const port = 8080;
const webServerSocket = new WebSocket.Server({ port: port });
console.log(`[WebSocket] Starting WebSocket server on localhost:${port}`);

// Represents the user "online" in the services
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


// ------- MAYBE I SHOULD USE SOCKET AS ID, SO WHEN A CLIENT LOGOUT I CAN DISCONNECT HIM QUICLY RATHER THAN ITERATE OVER MAP
// OPPURE NELLA ONDISPOSE MANDO UN ULTIMO MESSAGGIO AL SERVER "LOGOUT" COSI POSSO USARE L USERNAME COME CHIAVE

// This contains users logged (<phone, [phone, username, photo, mainSocket, chatSocket]> )
var users = new Map(); 

// -----------------  JS è single thread ---------------
// It doesn't create another thread, but different stacks, it simulates multithread 
//=> i.e the var chatUser is different for every connection

// Every client has 2 connection with this server,
// one stable and the other one is opened when client opens a chat 
webServerSocket.on("connection", (socket) => {
  console.log("connected");  
  // User in session, this var is useful when I connect with 2nd connection 
  var chatUser;
  // Client send a message to the server
  socket.on("message", (message) => {
    // First message sended to server from client is his credentials
    // "LOGIN:{"phone":"3347552773","username":"fede","photo":"encoded64photo"}"
    if (message.startsWith("LOGIN")) {
      console.log("LOGIN");
      let json = JSON.parse(message.split("LOGIN: ")[1]);
      // Last field is the other socket of a client, the chat socket, when he comes online, it is null
      let user = new User(json['phone'], json['username'], json['photo'], socket, null);
      // Send to all OTHER clients the new connected users, and send to new user all the others
      users.forEach(function(value, key) {
      // Send to new client all users
        user.mainSocket.send("NEW_USER: " + value.toJson())
        value.mainSocket.send("NEW_USER: " + user.toJson());
      }, users);
      // send (also (for debug) himself)!
      user.mainSocket.send("NEW_USER: " + user.toJson())
      // Add just connected user to map
      users.set(json['phone'], user);
    }

    // In app an user opens Chat screen
    // "OPEN_CHAT_SOCKET:{"phone":"3347552773"}"
    if (message.startsWith("OPEN_CHAT_SOCKET")) {
      console.log("OPEN_CHAT_SOCKET");
      // Here i have another connection with client, beacuse in app I connect again to this server
      // Add this new connection as parameter of User
      let json = JSON.parse(message.split("OPEN_CHAT_SOCKET: ")[1]);
      // My id
      let phone = json['phone'];
      // Get client from map
      let user = users.get(phone);
      // Add new chat socket to him! He just entered in Chat screen in app
      user.chatSocket = socket;
      // I have to assign chatUser! 
      chatUser = user;
      /// SERVER MUST SENDS TO ALL CHAT SOCKET THE PEER STATUS, SO IN CLIENT I CAN ALWAYS REBUILD THE APPBAR WITH STAUS!
      //-------------- WHEN HE SENDS ONLINE CONTACT DI LA SETTO LA VARIABILE ONLINE A TRUE, QUANDO ESCONO DALL APP, IL SERVER RIMANDA A TUTTI I CONNESSI IL NUOVO STATO=> ALLE CHAT SOCKET! PERCHE MI INTERESSA LI, QUINDI IL VALORE DA ONLINE A OFFLINE LO CAMBIO NELLA CHAT SOCKET!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MA NON è VERO! ANCHE NELLE MAIN SOCKET! I.E NON SONO SULLA CHAT , UN UTENTE SI DISCONNETTE, AGGIORNO IL SUO VALORE NELLA MAIN SOCKET COSI QUANDO ENTRO IN CHAT HO IL VALORE AFFIORNto! QUINDI LO MANDO AD ENTRAMBE!
      // LOGOUT USERNAME => E NELL'APP PARSO ANCHE QUESTO CASE COME MESSAGGIO RICEVUTO, E AGGIORNO STATUS!
      // SERVER INVIA STATUS 'OFFLINE' E IL NOME DELL USCENTE! NELL APP CONTROLLO CHE COTACT.PHONE == USCENTE PER NASCONDERE LO STATUS ONLINE
      /*
      let peer = users.get(json['dest']);
      let status = peer == undefined ? 'OFFLINE' : 'ONLINE';
      chatUser.send("STATUS: " + JSON.stringify(status));
      */
    }

    // "SEND_TO:{"phone":"3347552773","message":"Hello, world!"}"
    if (message.startsWith("SEND_TO")) {
      console.log("SEND_TO");
      let json = JSON.parse(message.split("SEND_TO: ")[1]);
      let dest = json['dest'];
      let msg = json['message'];
      // Create message to send
      let packet = new Message(chatUser.phone, msg, new Date());
      // Search dest and send the message in the two socket of him
      let peer = users.get(dest);
      // Send message to the 2 socket of the destination! (ChatTab & Chat screen in app)
      peer.mainSocket.send("MESSAGE_FROM: " + JSON.stringify(packet));
      // Check that if he is in a Chat screen
      if (peer.chatSocket != null) {
        peer.chatSocket.send("MESSAGE_FROM: " + JSON.stringify(packet));
      }
      console.log("mess send");
    }

    // "LOGOUT:{"phone":"xxxx"}
    if (message.startsWith("LOGOUT")) {
        console.log("LOGOUT");
        let json = JSON.parse(message.split("LOGOUT: ")[1]);
        // My id
        let phone = json['phone'];
        // Remove from map
        users.delete(phone);
        // Send to all socket that user is nomore online
        users.forEach(function(value, key) {
          // Send to new client all users
            value.mainSocket.send("LOGOUT: " + '{"phone":' + '"'+ phone + '"}');
            if (value.chatSocket != null) {
              value.chatSocket.send("LOGOUT: " + '{"phone":' + '"'+ phone + '"}')
            }
          }, users);
          /*
        users.forEach(function(key, value) {
          // Main socket
          value.mainSocket.send("LOGOUT: " + JSON.stringify(phone));
          // Check if user is on Chat tab
          if (value.chatSocket != null) {
            value.chatSocket.send("LOGOUT: " + JSON.stringify(phone))
          }
        }, users);
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
        
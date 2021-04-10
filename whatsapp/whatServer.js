const WebSocket = require("ws");
// start the server and specify the port number
const port = 8080;
const webServerSocket = new WebSocket.Server({ port: port });
console.log(`[WebSocket] Starting WebSocket server on localhost:${port}`);

 // to manage various states of the server

// CLIENT REGISTRATION: USERNAME, PHOTO AS STRING, PHONENUMBER, LIST MESSAGE ==>>> POTREI ADDIRITTURA NON USARE DB NELL'APP! 
// => NO, LIST MESSAGE PER OGNI CLIENT PESANTE
// (BASTA CHE SALVO NELLE SHARED PREFERENCES IL PHONENUMBER! E LO PASSO AL SERVER OGNI VOLTA CHE MI CONNETTO, COSI LUIU ASSOCIA 
// LA SOCKET AL MIO PHONENUMBER, USERNAME, ECC)

// NO CHAT NEL FILE JSON DI REG => quando nell'app mi registro all'avvio!
class User {
  constructor(phone, username, photo) {
    this.phone = phone;
    this.username = username;
    this.photo = photo;
  }
}

class SocketUser extends User {
  constructor(user, socket) {
    super(user);
    this.socket = socket
  }
}

// class message => user and sender!
class Message {
  constructor(phone, message, timestamp) {
    this.phone = phone;
    this.message = message;
    this.timestamp = timestamp;
  }
}

// IL PRIMO MESSAGGIO CHE MI SARà INVIATO è IL PHONE SEL CLIENT, COSì CREO LA COPPIA 
// CLIENT SOCKET
var mainUsers = [];
var chatUsers = [];
var mainSocketUsers = [];
var chatSocketUsers = [];

// on client connection // 
// -----------------  VIENE CREATO UN THREAD PER OGNI CONNECTION! ---------------
// ----------------- OGNI CLIENT HA DUE CONNESSIONI, NELLA CHAT TAB E NELLA CHAT!------
// ---------------- PROVO A INSTAURARE DUE CONNECTION NELLA TAB E PASSARLA DILLA
webServerSocket.on("connection", (socket) => {
  console.log("connected");  
  // user in session
  var connectedUser;
  // when socket send a message to the server
  socket.on("message", (message) => {
    // LOGIN / REGISTER 'PHONE' 'USERNAME' 'PHOTO'
    if (message.startsWith("login")) {
      credentials = message.split(" ");
      var user = new User(credentials[1], credentials[2], credentials[3]);
      connectedUser = user;
      var socketUser = new SocketUser(user, socket);
      // check that he is not yet registered / logged
      //if !mainUsers.includes 
      mainUsers.push(user);      
      mainSocketUsers.push(socketUser);      
      // send to ALL client ALL mainUsers
      mainSocketUsers.forEach((client) => { 
        client.socket.send("newUser: " + JSON.stringify(mainUsers));
      });
      console.log("broadcast send");
    }

    if (message.startsWith("initializeSocketChat")) {
      credentials = message.split(" ");
      var user = new User(credentials[1], credentials[2], credentials[3]);
      connectedUser = user; // FORSE MI SERVE SOLO STA COSA QUA
      var socketUser = new SocketUser(user, socket);
      // check that he is not yet registered / logged
      //if !mainUsers.includes 
      chatUsers.push(user);      
      chatSocketUsers.push(socketUser);      
      console.log("chat socket initializes");
    }

    // "sendTo: phoneFede message"
    if (message.startsWith("sendTo:")) {
      var json = JSON.parse(message.split("sendTo: ")[1]);
      var dest = json['dest'];
      var msg = json['message'];
      // search dest and send the message in the two socket of the client
      for (var i = 0; i < mainSocketUsers.length; i++) {
        if (mainUsers[i].phone == dest) {
          var message = new Message(connectedUser.phone, msg, new Date());
          mainSocketUsers[i].socket.send("chatWith: " + JSON.stringify(message));
          console.log("mess send to main channel");
        }
      }   
      for (var i = 0; i < chatSocketUsers.length; i++) {
        if (chatUsers[i].phone == dest) {
          var message = new Message(connectedUser.phone, msg, new Date());
          chatSocketUsers[i].socket.send("chatWith: " + JSON.stringify(message));
          console.log("mess send to chat channel");
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
        
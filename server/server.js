import { Sequelize, DataTypes } from 'sequelize';
import WebSocket, { WebSocketServer } from 'ws';
import { UserDao } from './dao/userDao.js';
import { DatabaseManager } from './dao/db.js';
import { OnlineUser } from './helper/user.js';
import { Message } from './helper/message.js';
import { MessageDao } from './dao/messageDao.js';

// Possible operations
const REQUIRE_REGISTRATION = 'REQUEST'
const REGISTRATION = 'REGISTER'
// Login when 
const LOGIN = 'LOGIN'
// Opens the chat screen in app
const CHAT_SOCKET = 'OPEN_CHAT_SOCKET'
// Request to send a message
const SEND_TO = 'SEND_TO'
// Client status
const ONLINE = 'ONLINE'
const OFFLINE = 'OFFLINE'

// Initialize the database
await DatabaseManager.initialize()

// Get all users from db
var registeredUsers = await UserDao.getMapAllUser()

// start the server and specify the port number
const webServerSocket = new WebSocketServer({ port: 8080 });
console.log(`[WebSocket] Starting WebSocket server on localhost:${8080}`);

// This contains onlineUsers logged (<phone, [phone, username, photo, mainSocket, chatSocket]> )
var onlineUsers = new Map(); 

// -----------------  JS è single thread ---------------
// It doesn't create another thread, but different stacks, it simulates multithread 
//=> i.e the var sessionUser is different for every connection

// Every client has 2 connection with this server,
// one stable and the other one is opened when client opens a chat 
webServerSocket.on("connection", (socket) => {
  console.log("CONNECTION");  
  // User in session, this var is useful when I connect with 2nd connection 
  var sessionUser;
  socket.on("message", (data) => {
    var message = data.toLocaleString()
    // Client send the register request message to the server
    if (message.startsWith(REQUIRE_REGISTRATION)) {

      // Request of registration, client sends only phone number
      registerRequest(message, socket);
    
    } else if (message.startsWith(REGISTRATION)) {
    
      // Client can register himself with the previous phone number
      register(message, socket);
    
    } else if (message.startsWith(LOGIN)) {
    
      // Login after registration
      login(message, socket);
    
    } else if (message.startsWith(CHAT_SOCKET)) {
    
      // In app an user opens Chat screen, now session user has 2 socket
      sessionUser = createChatConnection(message, socket, sessionUser);

    } else if (message.startsWith(SEND_TO)) {

      // Client wants to send a message
      sendMessage(message, sessionUser);
      
    } else if (message.startsWith(ONLINE)) {
      
      // Client opens the app
      setOnline(message);

    } else if (message.startsWith(OFFLINE)) {

      // Client closes the app
      setOffline(message);

    }
  })
})

function setOffline(message) {
  // "OFFLINE:{"phone":"xxxx"}
  console.log("OFFLINE");
  let json = JSON.parse(message.split("OFFLINE: ")[1]);
  // My id
  let phone = json['phone'];
  onlineUsers.get(phone).isOnline = false;
  // Remove from map
  // onlineUsers.delete(phone);
  // Send to all socket that user is nomore online
  onlineUsers.forEach(function (value) {
    // Send to new client all onlineUsers
    value.mainSocket.send("OFFLINE: " + '{"phone":' + '"' + phone + '"}');
    if (value.chatSocket != null) {
      value.chatSocket.send("OFFLINE: " + '{"phone":' + '"' + phone + '"}');
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

function setOnline(message) {
  console.log("ONLINE");
  // "ONLINE:{"phone":"xxxx"}
  // On reopen abb from bg
  let json = JSON.parse(message.split("ONLINE: ")[1]);
  // My id
  let phone = json['phone'];
  let user = onlineUsers.get(phone);
  user.isOnline = true;

  // Send to this user the enqueued messages
  user.mainSocket.send("MESSAGES_FROM: " + JSON.stringify(user.offlineMessages));
  if (user.chatSocket != null) {
    user.chatSocket.send("MESSAGES_FROM: " + JSON.stringify(user.offlineMessages));
  }
  user.offlineMessages = [];

  // Send to all socket that user is online again
  onlineUsers.forEach(function (value) {
    if (value != user) {
      // Send to new client all onlineUsers
      value.mainSocket.send("ONLINE: " + '{"phone":' + '"' + phone + '"}');
      if (value.chatSocket != null) {
        value.chatSocket.send("ONLINE: " + '{"phone":' + '"' + phone + '"}');
      }
    }
  }, onlineUsers);
}

// "SEND_TO:{"phone":"3347552773","message":"Hello, world!"}"
function sendMessage(message, sessionUser) {
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
    peer.offlineMessages.push(JSON.stringify(packet));
    MessageDao.createOfflineMessage(peer.id, packet.message, packet.timestamp)
  } else {
    // Send message to the 2 socket of the destination! (ChatTab & Chat screen in app)
    peer.mainSocket.send("MESSAGE_FROM: " + JSON.stringify(packet));
    // Check that if he is in a Chat screen
    if (peer.chatSocket != null) {
      peer.chatSocket.send("MESSAGE_FROM: " + JSON.stringify(packet));
    }
  }
}

// In app an user opens Chat screen
// "OPEN_CHAT_SOCKET:{"phone":"3347552773"}"
function createChatConnection(message, socket, sessionUser) {
  console.log("OPEN_CHAT_SOCKET");
  // Here i have another connection with client, beacuse in app I connect again to this server
  // Add this new connection as parameter of User
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
    user.chatSocket.send("OFFLINE: " + '{"phone":' + '"' + registeredUsers.get(json[1]['dest']) + '"}');
  }
  return sessionUser;
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

// First message sended to server from client is his credentials
// "LOGIN:{"phone":"3347552773","username":"fede","photo":"encoded64photo"}"
function login(message, socket) {
  console.log("LOGIN");
  // If user is 
  let json = JSON.parse(message.split("LOGIN: ")[1]);
  // Last field is the other socket of a client, the chat socket, when he comes online, it is null
  //let user = new User(json['phone'], json['username'], json['photo'], socket);
  let user = registeredUsers.get(json['phone']);
  user.mainSocket = socket;
  user.isOnline = true;
  // Send to all OTHER clients the new connected onlineUsers, and send to new user all the others
  let users = [];
  registeredUsers.forEach(function (user) {
    // Add to list all registered client
    users.push(user.toJson());
  }, registeredUsers);
  let toSend = "USERS: " + JSON.stringify(users);
  // send clients
  user.mainSocket.send(toSend);
  // Add just connected user to map
  onlineUsers.set(json['phone'], user);
}

// Client registration
function register(message, socket) {
  console.log("REGISTER");
  // If user is 
  let json = JSON.parse(message.split("REGISTER: ")[1]);
  // Save user to map
  let user = new OnlineUser(json['phone'], json['username'], json['photo'], null);
  // Add just registered user to map
  registeredUsers.set(json['phone'], user);
  // Save to db
  UserDao.createUser(json['phone'], json['username'], json['photo']);
  socket.send("OK");
  socket.close();
}

function registerRequest(message, socket) {
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
        
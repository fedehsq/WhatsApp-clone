import { Sequelize, DataTypes } from 'sequelize';
import WebSocket, { WebSocketServer } from 'ws';
import { UserDao } from './dao/userDao.js';
import { DatabaseManager } from './dao/db.js';
import { OnlineUser } from './helper/user.js';
import { Message } from './helper/message.js';
import { MessageDao } from './dao/messageDao.js';

// Possible operations / response code
const REGISTRATION_REQUEST = 0, RESULT_OK = 0
const REGISTRATION = 1, RESULT_KO = 1
// Login when 
const LOGIN = 2
// Opens the chat screen in app
const CHAT_SOCKET = 3
// Request to send a message
const SEND = 4
// Client status
const ONLINE = 5
const OFFLINE = 6

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
  var inChatUser;
  socket.on("message", (data) => {
    var json = JSON.parse(data.toLocaleString())
    var request = json['operation']
    var body = json['body']
    
    switch (request) {
      // Request of registration, client sends only phone number
      case REGISTRATION_REQUEST:
        registerRequest(body, socket);
        break;

      // Client can register himself with the previous phone number
      case REGISTRATION:
        register(body, socket);
        break;

      // Login after registration
      case LOGIN:
        login(body, socket);
        break;

      // In app an user opens Chat screen, now session user has 2 socket
      case CHAT_SOCKET:
        inChatUser = createChatConnection(body, socket, inChatUser);
        break;

      // Client wants to send a message
      case request == SEND:
        sendMessage(body, inChatUser);
        break;

      // Client can register himself with the previous phone number
      case REGISTRATION:
        register(body, socket);
        break;

      // Client opens the app
      case ONLINE:
        setOnline(body);
        break;

      // Client closes the app
      case OFFLINE:
        setOffline(body);
        break;
    }
  })
})

function setOffline(body) {
  // "OFFLINE:{"phone":"xxxx"}
  console.log("OFFLINE");
  // My id
  let phone = body['phone'];
  onlineUsers.get(phone).isOnline = false;

  // Remove from map
  // onlineUsers.delete(phone);
  // Send to all socket that user is nomore online
  var messageForPeer = JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'body': {
        'OFFLINE' : JSON.stringify({'phone' : phone})
      }
    })
  for (const u of onlineUsers) {
    if (u != user) {
      // Send to new client all onlineUsers
      u.mainSocket.send(messageForPeer);
      if (u.chatSocket != null) {
        u.chatSocket.send(messageForPeer);
      }
    }  
  }

  /*onlineUsers.forEach(function (value) {
    // Send to new client all onlineUsers
    value.mainSocket.send("OFFLINE: " + '{"phone":' + '"' + phone + '"}');
    if (value.chatSocket != null) {
      value.chatSocket.send("OFFLINE: " + '{"phone":' + '"' + phone + '"}');
    }
  }, onlineUsers);
    
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

function setOnline(body) {
  console.log("ONLINE");

  let phone = body['phone'];
  let user = onlineUsers.get(phone);
  user.isOnline = true;

  var messageForSender = JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'body': {
        'MESSAGES_FROM' : JSON.stringify(user.offlineMessages)
      }
    })
  
  var messageForPeer = JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'body': {
        'ONLINE' : JSON.stringify({'phone' : phone})
      }
    })

  // Send to this user the enqueued messages
  user.mainSocket.send(messageForSender);
  if (user.chatSocket != null) {
    user.chatSocket.send(messageForSender)
  }
  user.offlineMessages = [];
  MessageDao.deleteAllMessages(user.uid)

  // Send to all socket that user is online
  for (const u of onlineUsers) {
    if (u != user) {
      u.mainSocket.send(messageForPeer);
      if (u.chatSocket != null) {
        u.chatSocket.send(messageForPeer);
      }
    }  
  }
}

// "SEND_TO:{"phone":"3347552773","message":"Hello, world!"}"
function sendMessage(body, sessionUser) {
  console.log("SEND");
  // Create message to send
  let message = new Message(sessionUser.phone, body['message'], new Date());
  // Search in registered dest and send the message in the two socket of him
  let peer = registeredUsers.get(body['dest']);
  // If peer is offline, enqueue the messages
  if (!peer.isOnline) {
    peer.offlineMessages.push(JSON.stringify(message));
    MessageDao.createMessage(peer.id, message.body, message.timestamp)
  } else {
    // Send message to the 2 socket of the destination! (ChatTab & Chat screen in app)
    let messageForPeer = JSON.stringify(
      {
        'status_code' : RESULT_OK,
        'body': {
          'MESSAGE_FROM' : JSON.stringify(message)
        }
      })
    peer.mainSocket.send(messageForPeer);
    // Check that if he is in a Chat screen
    if (peer.chatSocket != null) {
      peer.chatSocket.send(messageForPeer);
    }
  }
}

// In app an user opens Chat screen
// "OPEN_CHAT_SOCKET:{"phone":"3347552773"}"
function createChatConnection(body, socket, inChatUser) {
  console.log("OPEN_CHAT_SOCKET");
  // Here i have another connection with client, beacuse in app I connect again to this server
  // Add this new connection as parameter of User
  // My id
  let phone = body['phone'];
  let peer = onlineUsers.get(body['dest']);
  // Add new chat socket to him! He just entered in Chat screen in app
  inChatUser = onlineUsers.get(phone);
  inChatUser.chatSocket = socket;
  // Get client from map
  if (peer == null) {    
    inChatUser.chatSocket.send(JSON.stringify(
      {
        'status_code' : RESULT_OK,
        'body': {
          'OFFLINE' : JSON.stringify({'phone' : registeredUsers.get(body['dest'])})
        }
      }));
  }
  return inChatUser;
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
function login(body, socket) {
  console.log("LOGIN");
  // Last field is the other socket of a client, the chat socket, when he comes online, it is null
  let user = registeredUsers.get(body['phone']);
  user.mainSocket = socket;
  user.isOnline = true;
  // Send to all OTHER clients the new connected onlineUsers, and send to new user all the others
  let users = [];
  for (const user of registeredUsers) {
    users.push(OnlineUser.toJson(user));
  }
  /*
  registeredUsers.forEach(function (user) {
    // Add to list all registered client
    users.push(user.toJson());
  }, registeredUsers);
  */

  // send clients  
  user.mainSocket.send(JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'body': {
        'USERS' : JSON.stringify(users)}
    }
  ));
  // Add just connected user to map
  onlineUsers.set(body['phone'], user);
}

// Client registration
function register(body, socket) {
  console.log("REGISTER");
  // Save user to map
  let user = new OnlineUser(body['phone'], body['username'], body['photo']);
  // Add just registered user to map
  registeredUsers.set(body['phone'], user);
  // Save to db
  UserDao.createUser(body['phone'], body['username'], body['photo']);
  socket.send(JSON.stringify({ 'status_code': RESULT_OK }));
  socket.close();
}

function registerRequest(body, socket) {
  console.log("REQUEST");
  // Check if the phone number is already registered
  let user = registeredUsers.get(body['phone']);
  if (user == null) {
    socket.send(JSON.stringify({ 'status_code': RESULT_OK }));
    socket.close();
  } else {
    socket.send(JSON.stringify({ 'status_code': RESULT_KO }));
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
        
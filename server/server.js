import { Sequelize, DataTypes } from 'sequelize';
import WebSocket, { WebSocketServer } from 'ws';
import { UserDao } from './dao/userDao.js';
import { DatabaseManager } from './dao/db.js';
import { OnlineUser } from './helper/user.js';
import { Message } from './helper/message.js';
import { MessageDao } from './dao/messageDao.js';
import { User } from './models/user.js';

/**
 * Operations provided to the clients
 */ 

// Client wants to register himself, 
// server must check if the phone number is already registered
const REGISTRATION_REQUEST = 0
// Client can register himself
const REGISTRATION = 1
// Login on opening the app when client is registered
const LOGIN = 2
// Client wants to open another socket for chatting; it opens the ChatScreen
const CHAT_SOCKET = 3
// Client requests to send a message to other client
const SEND = 4
// Client becomes online
const ONLINE = 5
// Client becomes offline
const OFFLINE = 6 
// Client requests registered user
const USER = 10
// Client requests registered users
const USERS = 7 
// Client receives a message
const MESSAGE = 8
// Client received messages while it isn't online
const OFFLINE_MESSAGES = 9

/* Response code */
const RESULT_OK = 0
const RESULT_KO = 1




/**
 * Server starts
 */

// Initialize the database
await DatabaseManager.initialize()

// Get all users from db
var registeredUsers = await UserDao.getMapAllUser()

// Keeping online users
var onlineUsers = new Map(); 

// Starts the server and specify the port number
const webServerSocket = new WebSocketServer({ port: 8080 });
console.log(`[WebSocket] Starting WebSocket server on localhost:${8080}`);

// Every client has 2 connection with this server,
// one stable and the other one is opened when client opens a chat 
webServerSocket.on("connection", (socket) => {
  console.log("CONNECTION");  

  // User in ChatScreen, with 2nd connection 
  var inChatUser;
  
  socket.on("message", (data) => {

    // Converts byte message in string
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
        inChatUser = createChatConnection(body, socket);
        break;

      // Client wants to send a message
      case SEND:
        sendMessage(body, inChatUser);
        break;

      // Client opens the app
      case ONLINE:
        setOnline(body);
        break;

      // Client closes the app
      case OFFLINE:
        setOffline(body);
        break;

      // Client requests the registered users
      case USER:
        sendUser(body, socket);
        break;

      // Client requests the registered users
      case USERS:
        sendUsers(socket);
        break;
    }
  })
})

/**
 * Send user's info to a client
 * @param {WebSocket} socket - Socket where to send the found user
 * @param {Map} body - Body of json containing the user phone number 
 */
function sendUser(body, socket) {
  console.log('USER');
  let user = registeredUsers.get(body['phone'])
  socket.send(JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'operation' : USER,
      'body': {
        'user' : JSON.stringify(OnlineUser.toJson(user))
      }
    }
  ));
}

/**
 * Get all registered users and send them to the requester
 * @param {WebSocket} socket - Socket where to send the registered users
 */
function sendUsers(socket) {
  console.log('USERS');
  let users = [];
  for (const user of registeredUsers.values()) {
    users.push(OnlineUser.toJson(user));
  }
  socket.send(JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'operation' : USERS,
      'body': {
        'users' : JSON.stringify(users)}
    }
  ));
}

/**
 * Server checks if the phone number can be registered
 * @param {Map} body - Body of json containing the user phone number 
 * @param {WebSocket} socket - Socket where to send the response
 */
 function registerRequest(body, socket) {
  console.log("REGISTER REQUEST");
  // Check if the phone number is already registered
  let user = registeredUsers.get(body['phone']);
  if (user == null) {
    socket.send(JSON.stringify({ 'status_code': RESULT_OK }));
    socket.close();
  } else {
    socket.send(JSON.stringify({ 'status_code': RESULT_KO }));
  }
}

/**
 * Client registration
 * @param {Map} body - Body of json containing the user phone number 
 * @param {WebSocket} socket - Socket where to send the response
 */
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

/**
 * Send to all online users the new offline status
 * @param {Map} body - Body of json message received by the server, containing the offline user
 */
function setOffline(body) {
  console.log("OFFLINE");
  let phone = body['phone'];
  onlineUsers.get(phone).isOnline = false;
  // Send to all socket that user is nomore online
  sendOfflineStatus(phone);
}

/**
 * Send to all online users, the new offline status
 * @param {String} phone - Offline user phone number
 */
function sendOfflineStatus(phone) {
  var messageForPeer = JSON.stringify(
    {
      'status_code': RESULT_OK,
      'operation': OFFLINE,
      'body': {
        'offline': JSON.stringify({ 'phone': phone })
      }
    });
  for (const u of onlineUsers.values()) {
    // Send only to chat socket (ChatScreen)
    if (u.phone != phone && u.chatSocket != null) {
        u.chatSocket.send(messageForPeer);
    }
  }
}

/**
 * Send to the just online user all messages received when he was offline
 * Send to all online users the new online status
 * @param {Map} body - Body of json message received by the server, 
 * containing the online user
 */
function setOnline(body) {
  console.log("ONLINE");
  // Get the online user
  let phone = body['phone'];
  let user = onlineUsers.get(phone);
  user.isOnline = true;
  // Forward all messages while he was offline
  sendOfflineMessages(user);
  // Notify to all other online users on the ChatScreen the new user status
  sendOnlineStatus(phone);
}

/**
 * Send to all other online users, the new online status
 * @param {String} phone - Online user phone number
 */
function sendOnlineStatus(phone) {
  var messageForPeer = JSON.stringify(
    {
      'status_code': RESULT_OK,
      'operation': ONLINE,
      'body': {
        'online': JSON.stringify({ 'phone': phone })
      }
    });
  // Send to all other clients that user is online
  for (const u of onlineUsers.values()) {
    if (u.phone != phone && u.chatSocket != null) {
        u.chatSocket.send(messageForPeer);
    }
  }
}

/**
 * Send to the just online user all messages received when he was offline
 * @param {OnlineUser} user - The online user which to send offline messages
 */
function sendOfflineMessages(user) {
  // All received messages when user was offline
  var messageForSender = JSON.stringify(
    {
      'status_code': RESULT_OK,
      'operation': OFFLINE_MESSAGES,
      'body': {
        'messages': JSON.stringify(user.offlineMessages)
      }
    });
  // Send to this user the offline received messages
  user.mainSocket.send(messageForSender);
  if (user.chatSocket != null) {
    user.chatSocket.send(messageForSender);
  }
  user.offlineMessages = [];
  MessageDao.deleteAllMessages(user.uid);
}

/**
 * Sends a message
 * @param {Map} body - Body of json message received by the server, 
 * containing the payload and the destination of the message
 * @param {OnlineUser} sessionUser - The sender of the message
 */
function sendMessage(body, sessionUser) {
  console.log("SEND");
  // Create message to send: sender, body, date
  let message = new Message(sessionUser.phone, body['message'], new Date());
  // Search in registeredUsers the destination
  let peer = registeredUsers.get(body['dest']);
  // If peer is offline, enqueue the messages
  if (!peer.isOnline) {
    peer.offlineMessages.push(JSON.stringify(message));
    MessageDao.createMessage(peer.uid, message.message, message.timestamp)
  } else {
    // Send message to the 2 socket of the destination (ChatTab & ChatScreen in app)
    let messageForPeer = JSON.stringify(
      {
        'status_code' : RESULT_OK,
        'operation' : MESSAGE,
        'body': {
          'message' : JSON.stringify(message),
          'user' : OnlineUser.toJson(sessionUser)
        }
      })
    peer.mainSocket.send(messageForPeer);
    // Check if the peer is in a ChatScreen
    if (peer.chatSocket != null) {
      peer.chatSocket.send(messageForPeer);
    }
  }
}

/**
 * Create a new socket (chat socker) for a user
 * @param {Map} body - Body of json containing the user phone number 
 * that enters the ChatScreen in the client app and the peer in ChatScreen
 * @param {WebSocket} socket - New socket (chat socket) to assign
 * @returns {OnlineUser} inChatUser - User whom @socket is assigned
 */
function createChatConnection(body, socket) {
  console.log("OPEN_CHAT_SOCKET");
  let phone = body['phone'];
  let peer = onlineUsers.get(body['dest']);
  var inChatUser = onlineUsers.get(phone);
  inChatUser.chatSocket = socket;
  // Notify the peer status
  if (peer == null) {    
    inChatUser.chatSocket.send(JSON.stringify(
      {
        'status_code' : RESULT_OK,
        'operation' : OFFLINE,
        'body': {
          'offline' : registeredUsers.get(body['dest']).phone
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

/**
 * Create a new socket (main socket) for a user
 * Sends to him all registered users
 * @param {Map} body - Body of json containing the user phone number 
 * @param {WebSocket} socket - New socket (main socket) to assign
 */
function login(body, socket) {
  console.log("LOGIN");
  let user = registeredUsers.get(body['phone']);
  user.mainSocket = socket;
  user.isOnline = true;

  /*
  // Send to all OTHER clients the new connected onlineUsers, and send to new user all the others
  let users = [];
  for (const user of registeredUsers.values()) {
    users.push(OnlineUser.toJson(user));
  }

  // Sends all registered users to user 
  user.mainSocket.send(JSON.stringify(
    {
      'status_code' : RESULT_OK,
      'operation' : USERS,
      'body': {
        'users' : JSON.stringify(users)}
    }
  ));
  */
  // Add just connected user to online users map
  onlineUsers.set(body['phone'], user);
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
        
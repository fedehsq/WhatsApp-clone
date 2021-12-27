const server = 'ws://192.168.1.14:8080';

// Possible operations
const registrationRequest = 0;
const registration = 1;
// Login after registration
const login = 2;
// Opens the chat screen in app
const chatSocket = 3;
// Request to send a; message
const send = 4;
// Client status
const online = 5;
const offline = 6;

const resultOk = 0;
const resultKo = 1;

// Sender phone number, text message, timestamp.
// The destination is not needed here
export class Message {
    constructor(phone, message, timestamp) {
        this.phone = phone;
        this.message = message;
        // Timestamp needed to avoid duplicate same message in the client
        this.timestamp = timestamp;
    }
}
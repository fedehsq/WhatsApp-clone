// Represents the registered onlineUsers in the service
export class OnlineUser {
    constructor(uid, phone, username, photo, offlineMessages = [], mainSocket = null, chatSocket = null) {
        this.uid = uid
        this.phone = phone;
        this.username = username;
        this.photo = photo;
        this.mainSocket = mainSocket;
        this.chatSocket = chatSocket;
        this.isOnline = false;
        this.offlineMessages = offlineMessages;
    }

     // To send over socket
    static toJson(user) {
        return JSON.stringify(user, ["uid", "phone", "username", "photo", "isOnline"]);
        /*
        return '{"phone":' + '"'+ user.phone + '", "username":' + '"'+ user.username 
        + '", "photo":' + '"'+ user.photo +    '", "isOnline":' + '"'+ user.isOnline + '"}';
        */
    }
}
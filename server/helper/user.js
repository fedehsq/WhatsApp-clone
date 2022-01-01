// Represents the registered onlineUsers in the service
export class OnlineUser {
    constructor(phone, username, photo, uid = -1, offlineMessages = [], mainSocket = null, chatSocket = null) {
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
        return JSON.stringify(user, ["phone", "username", "photo", "isOnline"]);
        /*
        return '{"phone":' + '"'+ user.phone + '", "username":' + '"'+ user.username 
        + '", "photo":' + '"'+ user.photo +    '", "isOnline":' + '"'+ user.isOnline + '"}';
        */
    }
}
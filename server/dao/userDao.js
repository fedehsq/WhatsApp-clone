import { User } from '../models/user.js';
import { OnlineUser } from '../helper/user.js';
import { MessageDao } from '../dao/messageDao.js';

export class UserDao {

  static async createUser(phone, username, photo) {
    var user = await User.create({ phone: phone, username: username , photo: photo});
    return new OnlineUser(user.phone, user.username, user.photo, user.uid);
  }

  static async getAllUser() {
    return await User.findAll();
  }

  static async getMapAllUser() {
    var map = new Map()
    let users = await User.findAll();
    for (const user of users) {
      // Get all offline messages of the user
      var offlineMessages = await MessageDao.getAllMessages(user.uid)
      // read all registered users
      map.set(user['phone'],
        new OnlineUser(user.phone, user.username, user.photo, user.uid, offlineMessages));
    }
    return map
  }
}
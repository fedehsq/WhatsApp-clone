import { OfflineMessage } from '../models/message.js';

export class MessageDao {

  static async createMessage(uid, text, timestamp) {

    return await OfflineMessage.create({ uid: uid, text: text, timestamp: timestamp});
  }

  static async getAllMessages(uid) {
    return await OfflineMessage.findAll({
        where: {
          uid: uid,
        }
      });
    }

  static async deleteAllMessages(uid) {
    return await OfflineMessage.destroy({
        where: {
          uid: uid,
        }
      });
    }
}
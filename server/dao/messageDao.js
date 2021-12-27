import { OfflineMessage } from '../models/message.js';

export class MessageDao {

  static async createMessage(uid, text, timestamp) {
    return JSON.stringify(await OfflineMessage.create({ uid: uid, text: text, timestamp: timestamp}));
  }

  static async deleteAllMessages(uid) {
    return JSON.stringify(await OfflineMessage.findAll({
        where: {
          uid: uid,
        }
      }));
    }

  static async deleteAllMessages(uid) {
    return await OfflineMessage.destroy({
        where: {
          uid: uid,
        }
      });
    }
}
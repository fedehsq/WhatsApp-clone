import { OfflineMessage } from '../models/message.js';

export class MessageDao {

  static async createOfflineMessage(uid, text, timestamp) {
    return JSON.stringify(await OfflineMessage.create({ uid: uid, text: text, timestamp: timestamp}));
  }

  static async getAllUserOfflineMessages(uid) {
    return JSON.stringify(await OfflineMessage.findAll({
        where: {
          uid: uid,
        }
      }));
    }
}
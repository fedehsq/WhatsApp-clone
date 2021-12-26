import { User } from '../models/user.js';
import { OfflineMessage } from '../models/message.js';

export class DatabaseManager {
  static async initialize() {
    await User.sync({ });
    await OfflineMessage.sync({  });
    console.log("All tables created.");
  }
}

/* export async function create() {
  await User.sync({ force: true });
  await OfflineMessage.sync({ force: true });
  console.log("All tables created.");
  Create a new user
  await User.create({ phone: "33456", username: "fe" , photo: "photo"});
  await User.create({ phone: "12123", username: "feder" , photo: "b64"});
  await OfflineMessage.create({ uid: 1, text: "t1"});
  await OfflineMessage.create({ uid: 1, text: "t2"});
  await OfflineMessage.create({ uid: 2, text: "t3"});
  const messages = await OfflineMessage.findAll({
    include: User,
    where: {
      uid: 1,
    }
  });
  //const messages = await OfflineMessage.findAll({ include: User });
  console.log("All messages:", JSON.stringify(messages, null, 2));
}
*/
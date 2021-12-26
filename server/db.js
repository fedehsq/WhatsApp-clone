const { Sequelize, DataTypes } = require('sequelize');

// Option 1: Passing a connection URI
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: '../sqlite:/mmiab.db'
});

const User = sequelize.define('User', {
  phone: {
    type: DataTypes.STRING,
    allowNull: false
  },
  username: {
    type: DataTypes.STRING,
    allowNull: false
  },
  photo: {
    type: DataTypes.STRING,
    allowNull: false
  },
}, {
  freezeTableName: true
});


const OfflineMessage = sequelize.define('OfflineMessage', {
  text: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {
  freezeTableName: true
});

User.hasMany(OfflineMessage, { foreignKey: 'id' }); // Set one to many relationship
OfflineMessage.belongsTo(User, { foreignKey: 'id' });


async function conn() {
 //
  await User.sync({});
  await sequelize.sync({ force: true });
  console.log("All models were synchronized successfully.");
  // Create a new user
  const jane = await User.create({ phone: "12s3", username: "Doe" , photo: "b64"});
  await User.create({ phone: "12s3", username: "Doaaae" , photo: "b64"});
  await OfflineMessage.create({ id: 2, text: "b64"});
  const messages = await OfflineMessage.findAll({ include: User });
  console.log("All messages:", JSON.stringify(messages, null, 2));

}

conn()
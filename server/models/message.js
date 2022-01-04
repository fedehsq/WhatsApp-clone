import { User } from './user.js'
import { Sequelize, DataTypes } from 'sequelize';

// Option 1: Passing a connection URI
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './sqlite:/mmiab.db'
});

export const OfflineMessage = sequelize.define('OfflineMessage', {
  id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    primaryKey: true,
    autoIncrement: true,
  },
  text: {
      type: DataTypes.STRING,
      allowNull: false
    },
  timestamp: {
    type: DataTypes.DATE,
    allowNull: false
  }
  }, {
    freezeTableName: true
});
  
User.hasMany(OfflineMessage, { foreignKey: 'uid' }); // Set one to many relationship
OfflineMessage.belongsTo(User, { foreignKey: 'uid' });
import { Sequelize, DataTypes } from 'sequelize';
// Option 1: Passing a connection URI
export const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './sqlite:/mmiab.db'
});

export const User = sequelize.define('User', {
  uid: {
    type: DataTypes.INTEGER,
    allowNull: false,
    primaryKey: true,
    autoIncrement: true,
  },
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
import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../models/index';

class User extends Model {
  public id!: number;
  public name!: string;
  public email!: string;
  public password!: string;
  public planLimit!: number;
  public expiryDate!: Date;
  public dataUsed!: number;
  public timeLimit!: number; 
  public dataLimit!: number;
}

User.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    planLimit: {
      type: DataTypes.FLOAT,
      defaultValue: 0,
    },
    expiryDate: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    timeLimit: {
      type: DataTypes.FLOAT,
      defaultValue: 0, 
    },
    dataUsed: {
      type: DataTypes.FLOAT,
      defaultValue: 0, 
    },
    dataLimit: {
      type: DataTypes.FLOAT,
      allowNull: false, 
    },
  },
  {
    sequelize,
    tableName: 'Users',
    timestamps: true,
  }
);

export default User;
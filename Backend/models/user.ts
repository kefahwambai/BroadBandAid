import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../models/index';  

class User extends Model {
  public id!: number;
  public name!: string;
  public email!: string;
  public password!: string;
  public confirmPassword!: string; 
  public planLimit!: number;
  public dataUsed!: number;
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
      unique: false,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false, 
    },
    confirmPassword: {
      type: DataTypes.STRING,
      allowNull: false,  
    },
    planLimit: {
      type: DataTypes.FLOAT,
      allowNull: true,
    },
    dataUsed: {
      type: DataTypes.FLOAT,
      defaultValue: 0,
    },
  },
  {
    sequelize, 
    tableName: 'Users',
    timestamps: true, 
  }
);

export default User;

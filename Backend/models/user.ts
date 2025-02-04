import { Model, DataTypes, Sequelize } from 'sequelize';
import ISPPlan from './ispPlan';

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
  public planId!: number;
  public plan!: ISPPlan | null;

  static initModel(sequelize: Sequelize) {
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
        planId: {
          type: DataTypes.INTEGER,
          allowNull: true,
          references: {
            model: 'ISPPlans',
            key: 'id',
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
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
          allowNull: true,
        },
      },
      {
        sequelize,
        tableName: 'Users',
        timestamps: true,
      }
    );
  }
}

export default User;

import { Model, DataTypes, Sequelize } from 'sequelize';

class ISPPlan extends Model {
  public id!: number;
  public name!: string;
  public price!: number;
  public dataLimit!: number;
  public speed!: number;
  public provider!: string;
  public timeLimit!: number;

  static initModel(sequelize: Sequelize) {
    ISPPlan.init(
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
        price: {
          type: DataTypes.FLOAT,
          allowNull: false,
        },
        dataLimit: {
          type: DataTypes.FLOAT,
          allowNull: false,
        },
        provider: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        timeLimit: {
          type: DataTypes.INTEGER,
          allowNull: false,
          validate: {
            min: 1,
            max: 720,
          },
        },
      },
      {
        sequelize,
        tableName: 'ISPPlans',
        timestamps: true,
      }
    );
  }
}

export default ISPPlan;

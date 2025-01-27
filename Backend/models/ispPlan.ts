import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../models/index';  

class ISPPlan extends Model {
  public name!: string;
  public price!: number;
  public dataLimit!: number;
  public speed!: number;
  public provider!: string;
}

ISPPlan.init(
  {
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
    speed: {
      type: DataTypes.FLOAT,
      allowNull: false,
    },
  },
  {
    sequelize, 
    tableName: 'ISPPlans',
    timestamps: true,  
  }
);

export default ISPPlan;

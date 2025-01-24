'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class ISPPlan extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  ISPPlan.init({
    name: DataTypes.STRING,
    price: DataTypes.FLOAT,
    dataLimit: DataTypes.FLOAT,
    speed: DataTypes.FLOAT,
    provider: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'ISPPlan',
  });
  return ISPPlan;
};
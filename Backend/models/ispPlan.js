module.exports = (sequelize, DataTypes) => {
    const ISPPlan = sequelize.define("ISPPlan", {
      name: DataTypes.STRING,
      price: DataTypes.FLOAT,
      dataLimit: DataTypes.FLOAT, 
      speed: DataTypes.FLOAT, 
      provider: DataTypes.STRING
    });
    return ISPPlan;
  };
  
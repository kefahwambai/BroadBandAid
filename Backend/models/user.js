module.exports = (sequelize, DataTypes) => {
    const User = sequelize.define("User", {
      name: DataTypes.STRING,
      email: { type: DataTypes.STRING, unique: true },
      password: DataTypes.STRING,
      planLimit: DataTypes.FLOAT, 
      dataUsed: { type: DataTypes.FLOAT, defaultValue: 0 }
    });
    return User;
  };
  
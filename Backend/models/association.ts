import { Sequelize } from 'sequelize';
import User from './user';
import ISPPlan from './ispPlan';

export const defineAssociations = (sequelize: Sequelize) => {
  User.belongsTo(ISPPlan, { foreignKey: 'planId', as: 'plan' });
  ISPPlan.hasMany(User, { foreignKey: 'planId', as: 'users' });
};
'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    return queryInterface.addColumn('Users', 'dataUsed', {
      type: Sequelize.FLOAT,
      defaultValue: 0,
    });
  },

  down: async (queryInterface, Sequelize) => {
    return queryInterface.removeColumn('Users', 'dataUsed');
  }
};

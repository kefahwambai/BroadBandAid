'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('ISPPlans', [
      {
        name: 'maHustler',
        price: 5,
        dataLimit: 10,
        timeLimit: 1,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Za Bazu',
        price: 20,
        dataLimit: 30,
        timeLimit: 24,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Unlimited Plan',
        price: 50,
        dataLimit: 50,
        timeLimit: 168, 
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Super Fast Plan',
        price: 150,
        dataLimit: 80,
        timeLimit: 720, 
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'MonthlyGB',
        price: 200,
        dataLimit: 100,
        timeLimit: 720, 
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ], {});
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('ISPPlans', null, {});
  }
};

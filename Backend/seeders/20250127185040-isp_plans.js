'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('ISPPlans', [
      {
        name: 'Basic Plan',
        price: 5,
        dataLimit: 1,
        speed: 1,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Premium Plan',
        price: 10,
        dataLimit: 3,
        speed: 5,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Unlimited Plan',
        price: 100,
        dataLimit: 10,
        speed: 10,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Super Fast Plan',
        price: 50,
        dataLimit: 30,
        speed: 20,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Gigabit Plan',
        price: 150,
        dataLimit: 50,
        speed: 20,
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

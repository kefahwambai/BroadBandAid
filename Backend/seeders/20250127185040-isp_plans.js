'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('ISPPlans', [
      {
        name: 'Basic Plan',
        price: 5,
        dataLimit: 10,
        speed: 2,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Premium Plan',
        price: 20,
        dataLimit: 30,
        speed: 15,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Unlimited Plan',
        price: 50,
        dataLimit: 50,
        speed: 15,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Super Fast Plan',
        price: 150,
        dataLimit: 80,
        speed: 20,
        provider: 'Baricom',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Gigabit Plan',
        price: 200,
        dataLimit: 100,
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

'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const hashedPassword1 = bcrypt.hashSync('password123', 10);
    const hashedPassword2 = bcrypt.hashSync('password456', 10);
    const hashedPassword3 = bcrypt.hashSync('password789', 10);
    const hashedPassword4 = bcrypt.hashSync('password101', 10);
    const hashedPassword5 = bcrypt.hashSync('password112', 10);
    const hashedPassword6 = bcrypt.hashSync('password131', 10);
    const hashedPassword7 = bcrypt.hashSync('password415', 10);
    const hashedPassword8 = bcrypt.hashSync('password161', 10);
    const hashedPassword9 = bcrypt.hashSync('password718', 10);
    const hashedPassword10 = bcrypt.hashSync('password192', 10);

    await queryInterface.bulkInsert('Users', [
      {
        name: 'John Maken',
        email: 'jmakins@bar.com',
        password: hashedPassword1,
        confirmPassword: hashedPassword1,
        planLimit: 10,
        dataUsed: 8,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Jane Smith',
        email: 'jsmith@doe.com',
        password: hashedPassword2,
        confirmPassword: hashedPassword2,
        planLimit: 30,
        dataUsed: 5,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Alice Johnson',
        email: 'alice.johnson@example.com',
        password: hashedPassword3,
        confirmPassword: hashedPassword3,
        planLimit: 100,
        dataUsed: 40,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Bob Brown',
        email: 'bob.brown@example.com',
        password: hashedPassword4,
        confirmPassword: hashedPassword4,
        planLimit: 100,
        dataUsed: 70,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Charlie Davis',
        email: 'charlie.davis@example.com',
        password: hashedPassword5,
        confirmPassword: hashedPassword5,
        planLimit: 30,
        dataUsed: 12,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'David Evans',
        email: 'david.evans@example.com',
        password: hashedPassword6,
        confirmPassword: hashedPassword6,
        planLimit: 50,
        dataUsed: 15,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Eve Green',
        email: 'eve.green@example.com',
        password: hashedPassword7,
        confirmPassword: hashedPassword7,
        planLimit: 50,
        dataUsed: 20,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Frank Harris',
        email: 'frank.harris@example.com',
        password: hashedPassword8,
        confirmPassword: hashedPassword8,
        planLimit: 100,
        dataUsed: 20,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Grace King',
        email: 'grace.king@example.com',
        password: hashedPassword9,
        confirmPassword: hashedPassword9,
        planLimit: 80,
        dataUsed: 65,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: 'Hannah Lee',
        email: 'hannah.lee@example.com',
        password: hashedPassword10,
        confirmPassword: hashedPassword10,
        planLimit: 100,
        dataUsed: 35,
        createdAt: new Date(),
        updatedAt: new Date(),
      }
    ], {});
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('Users', null, {});
  }
};

import { Action } from 'actionhero';
import User from '../../models/user';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export class UserLogin extends Action {
  constructor() {
    super();
    this.name = 'userLogin';
    this.description = 'User login action';
    this.inputs = {
      email: { required: true },
      password: { required: true },
    };
  }

  async run({ params }: { params: any }) {
    const { email, password } = params;
  
    try {
      const user = await User.findOne({ where: { email: email.toLowerCase() } });
      if (!user) {
        return { success: false, message: 'Invalid email or password.' };
      }
  
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return { success: false, message: 'Invalid email or password.' };
      }
  
      const token = jwt.sign(
        { id: user.id, name: user.name },
        process.env.JWT_SECRET as string,
        { expiresIn: '1h' }
      );
  
      return {
        success: true,
        message: 'Login successful.',
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          planLimit: user.planLimit,
          dataUsed: user.dataUsed,
          expiryDate: user.expiryDate,
          timeLimit: user.timeLimit,
        },
      };
    } catch (error: any) {
      return { success: false, message: 'An error occurred. Please try again.' };
    }
  }
  
}

export class UserAdd extends Action {
  constructor() {
    super();
    this.name = 'userAdd';
    this.description = 'Create a new user';

    this.inputs = {
      name: { required: true },
      email: { required: true },
      password: { required: true },
      confirmPassword: { required: true },
      dataUsed: { required: false },
      planLimit: { required: false },
      timeLimit: { required: false },
      expiryDate: { required: false },
      dataLimit: { required: false }, 
    };
  }

  async run({ params }: { params: any }) {
    const { name, email, password, confirmPassword, planLimit, dataUsed, dataLimit } = params;

    if (password !== confirmPassword) {
      return { success: false, message: 'Passwords do not match.' };
    }

    try {
      const hashedPassword = await bcrypt.hash(password, 10);
      const newUser = await User.create({
        name,
        email: email.toLowerCase(),
        password: hashedPassword,
        planLimit,
        dataUsed,
        expiryDate: params.expiryDate,
        timeLimit: params.timeLimit,
        dataLimit,
      });

      return {
        message: `User ${newUser.name} created successfully.`,
        user: newUser,
      };
    } catch (error: any) {
      return { message: `Failed to create user: ${error.message}`, status: 'fail' };
    }
  }
}

export class UserFetch extends Action {
  constructor() {
    super();
    this.name = 'userFetch';
    this.description = 'Fetch an individual user by ID';
    this.inputs = {
      id: { required: true },
    };
  }

  async run({ params, response }: { params: any; response: any }) {
    try {
      const user = await User.findOne({ where: { id: Number(params.id) } });

      if (!user) {
        response.success = false;
        response.message = 'User not found.';
        return;
      }

      response.success = true;
      response.user = {
        id: user.id,
        name: user.name,
        email: user.email,
        planLimit: user.planLimit,
        dataUsed: user.dataUsed,
        dataLeft: user.dataLimit - user.dataUsed,
        expiryDate: user.expiryDate,
        timeLimit: user.timeLimit,
      };
    } catch (error: any) {
      console.error(`Database query failed: ${error.message}`);
      response.success = false;
      response.message = `Failed to fetch user: ${error.message}`;
    }
  }
}

export class UserList extends Action {
  constructor() {
    super();
    this.name = 'userList';
    this.description = 'List all the users';

    this.inputs = {};
  }

  async run({ response }: { response: any }) {
    try {
      const users = await User.findAll();

      response.users = users.map((user) => user);
      response.success = true;
    } catch (error: any) {
      response.success = false;
      response.message = `Failed to retrieve users: ${error.message}`;
    }
  }
}

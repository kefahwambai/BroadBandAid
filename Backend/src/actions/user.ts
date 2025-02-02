import { Action } from 'actionhero';
import User from '../../models/user';
import  bcrypt  from 'bcrypt';
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

export class UserLogin extends Action {
  constructor() {
    super();
    this.name = "userLogin";
    this.description = "User login action";
    this.inputs = {
      email: { required: true },
      password: { required: true },
    };
  }

  async run({ params }: { params: any }) {
    const { email, password } = params;

    try {
      const user = await User.findOne({ where: { email } });
      if (!user) {
        throw new Error("Invalid email or password.");
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        throw new Error("Invalid email or password.");
      }

      const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET as string, {
        expiresIn: "1h",
      });

      return { success: true, message: "Login successful.", token, user };
    } catch (error: any) {
      return { success: false, message: error.message };
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
      dataUsed: {required: false},
      planLimit: { required: false },
    };
  }

  async run({ params }: { params: any }) {
    const { name, email,  password, confirmPassword, planLimit, dataUsed } = params;

    if (password !== confirmPassword) {
      return { success: false, message: 'Passwords do not match.' };
    }

    try {
      const hashedPassword = await bcrypt.hash(password, 10); 
      const newUser = await User.create({
        name,
        email,
        password: hashedPassword,
        confirmPassword: hashedPassword,
        planLimit,
        dataUsed
      });

      return { message: `User ${newUser.name} created successfully.`, user: newUser };
    } catch (error: any) {
      return { message: `Failed to create user: ${error.message}`, status: 'fail' };
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
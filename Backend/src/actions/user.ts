import { Action } from 'actionhero';
import User from '../../models/user';
import  bcrypt  from 'bcrypt';


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

      response.users = users.map((user) => user.name);
      response.success = true;
    } catch (error: any) {
      response.success = false;
      response.message = `Failed to retrieve users: ${error.message}`;
    }
  }
}
exports.user = {
    name: 'user',
    description: 'Returns a list of users',
  
    inputs: {
      name: { required: false }
    },
  
    run: async function(api, data, next) {
      try {
        const users = [
          { id: 1, name: "John Doe" },
          { id: 2, name: "Jane Doe" }
        ];
  
        data.response.users = users;
        next();
      } catch (error) {
        data.response.error = error.message;
        next(error);
      }
    }
  };
  
  
  
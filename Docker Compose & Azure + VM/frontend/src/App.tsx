import { useEffect, useState } from 'react';
import axios from 'axios';
import UserForm from './components/UserForm';

interface User {
  id: number;
  name: string;
  email: string;
}

function App() {
  const [users, setUsers] = useState<User[]>([]);

  const fetchUsers = async () => {
    const response = await axios.get(import.meta.env.VITE_API_URL + '/api/users');
    setUsers(response.data);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  return (
    <div className="min-h-screen bg-green-100 p-6">
      <h1 className="text-3xl font-bold text-blue-600 mb-6">📋 User List</h1>

      <UserForm onUserAdded={fetchUsers} />

      <div className="bg-white p-4 rounded shadow-md w-full max-w-md">
        {users.length === 0 ? (
          <p className="text-gray-500">No users found.</p>
        ) : (
          <ul className="space-y-2">
            {users.map(u => (
              <li key={u.id} className="border-b pb-2">
                <span className="font-semibold text-gray-800">{u.name}</span>
                <span className="block text-sm text-gray-500">{u.email}</span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

export default App;

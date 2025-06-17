import { useState } from 'react';
import axios from 'axios';

interface Props {
  onUserAdded: () => void; // פונקציה שקוראת ל-refresh מהקומפוננטה הראשית
}

function UserForm({ onUserAdded }: Props) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!name.trim() || !email.trim()) {
      setError('Name and email are required.');
      return;
    }

    try {
      setLoading(true);
      await axios.post(import.meta.env.VITE_API_URL + '/api/users', {
        name,
        email,
      });
      setName('');
      setEmail('');
      onUserAdded(); // טוען מחדש את הרשימה מהקומפוננטה הראשית
    } catch (err) {
      setError('Failed to add user');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white p-4 rounded shadow-md w-full max-w-md mb-6">
      <h2 className="text-xl font-semibold mb-4 text-blue-700">Add New User</h2>
      {error && <p className="text-red-500 text-sm mb-2">{error}</p>}

      <input
        type="text"
        placeholder="Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        className="border p-2 rounded w-full mb-2"
      />
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="border p-2 rounded w-full mb-4"
      />
      <button
        type="submit"
        className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition disabled:opacity-50"
        disabled={loading}
      >
        {loading ? 'Adding...' : 'Add User'}
      </button>
    </form>
  );
}

export default UserForm;

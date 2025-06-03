// Import the modules to test
const { ApiService, UIManager } = require('../app.js');

describe('ApiService', () => {
  let apiService;
  
  beforeEach(() => {
    apiService = new ApiService('http://localhost:3000');
    fetch.mockClear();
  });

  describe('request method', () => {
    it('should make successful API request', async () => {
      const mockData = { message: 'success' };
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      const result = await apiService.request('/test');
      
      expect(fetch).toHaveBeenCalledWith(
        'http://localhost:3000/test',
        expect.objectContaining({
          headers: {
            'Content-Type': 'application/json'
          }
        })
      );
      expect(result).toEqual(mockData);
    });

    it('should handle API errors', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
        json: async () => ({ error: 'User not found' })
      });

      await expect(apiService.request('/test')).rejects.toThrow('User not found');
    });

    it('should handle network errors', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));

      await expect(apiService.request('/test')).rejects.toThrow('Network error');
    });
  });

  describe('getUsers', () => {
    it('should fetch users list', async () => {
      const mockUsers = [
        { id: 1, name: 'John', email: 'john@example.com' },
        { id: 2, name: 'Jane', email: 'jane@example.com' }
      ];
      
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockUsers
      });

      const result = await apiService.getUsers();
      
      expect(fetch).toHaveBeenCalledWith(
        'http://localhost:3000/api/users',
        expect.any(Object)
      );
      expect(result).toEqual(mockUsers);
    });
  });

  describe('createUser', () => {
    it('should create a new user', async () => {
      const newUser = { name: 'Test User', email: 'test@example.com' };
      const createdUser = { id: 1, ...newUser };
      
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => createdUser
      });

      const result = await apiService.createUser(newUser);
      
      expect(fetch).toHaveBeenCalledWith(
        'http://localhost:3000/api/users',
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify(newUser)
        })
      );
      expect(result).toEqual(createdUser);
    });
  });

  describe('deleteUser', () => {
    it('should delete a user', async () => {
      const deletedUser = { id: 1, name: 'John', email: 'john@example.com' };
      
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => deletedUser
      });

      const result = await apiService.deleteUser(1);
      
      expect(fetch).toHaveBeenCalledWith(
        'http://localhost:3000/api/users/1',
        expect.objectContaining({
          method: 'DELETE'
        })
      );
      expect(result).toEqual(deletedUser);
    });
  });
});

describe('UIManager', () => {
  let uiManager;
  
  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <form id="userForm">
        <input type="text" id="userName" />
        <input type="email" id="userEmail" />
      </form>
      <div id="usersList"></div>
      <button id="refreshBtn"></button>
      <div id="loadingMessage" class="hidden"></div>
      <div id="errorMessage" class="hidden"></div>
      <div id="apiStatus"></div>
    `;
    
    fetch.mockClear();
  });

  describe('escapeHtml', () => {
    it('should escape HTML characters', () => {
      const uiManager = new UIManager(true); // Skip initialization
      const result = uiManager.escapeHtml('<script>alert("xss")</script>');
      expect(result).toBe('&lt;script&gt;alert("xss")&lt;/script&gt;');
    });
  });

  describe('showError', () => {
    it('should display error message', () => {
      const uiManager = new UIManager(true); // Skip initialization
      const errorDiv = document.getElementById('errorMessage');
      
      uiManager.showError('Test error');
      
      expect(errorDiv.textContent).toBe('Test error');
      expect(errorDiv.classList.contains('hidden')).toBe(false);
    });
  });

  describe('renderUsers', () => {
    it('should render users list', () => {
      const uiManager = new UIManager(true); // Skip initialization
      const users = [
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
      ];
      
      uiManager.renderUsers(users);
      
      const usersDiv = document.getElementById('usersList');
      expect(usersDiv.innerHTML).toContain('John Doe');
      expect(usersDiv.innerHTML).toContain('jane@example.com');
      expect(usersDiv.querySelectorAll('.user-card')).toHaveLength(2);
    });

    it('should show no users message when list is empty', () => {
      const uiManager = new UIManager(true); // Skip initialization
      
      uiManager.renderUsers([]);
      
      const usersDiv = document.getElementById('usersList');
      expect(usersDiv.innerHTML).toContain('No users found');
    });
  });

  describe('updateApiStatus', () => {
    it('should update API status display', () => {
      const uiManager = new UIManager(true); // Skip initialization
      const statusDiv = document.getElementById('apiStatus');
      
      uiManager.updateApiStatus('online', 'API is healthy');
      
      expect(statusDiv.className).toBe('status online');
      expect(statusDiv.textContent).toBe('API is healthy');
    });
  });
});

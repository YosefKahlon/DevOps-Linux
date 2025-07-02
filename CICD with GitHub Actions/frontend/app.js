// API Configuration
const API_BASE_URL = 'http://localhost:3000';

// DOM Elements
const userForm = document.getElementById('userForm');
const userNameInput = document.getElementById('userName');
const userEmailInput = document.getElementById('userEmail');
const usersListDiv = document.getElementById('usersList');
const refreshBtn = document.getElementById('refreshBtn');
const loadingMessage = document.getElementById('loadingMessage');
const errorMessage = document.getElementById('errorMessage');
const apiStatus = document.getElementById('apiStatus');

// API Service Class
class ApiService {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
    }

    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const config = {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        };

        try {
            const response = await fetch(url, config);
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`);
            }
            
            return await response.json();
        } catch (error) {
            throw new Error(error.message || 'Network error occurred');
        }
    }

    async getUsers() {
        return this.request('/api/users');
    }

    async getUser(id) {
        return this.request(`/api/users/${id}`);
    }

    async createUser(userData) {
        return this.request('/api/users', {
            method: 'POST',
            body: JSON.stringify(userData)
        });
    }

    async deleteUser(id) {
        return this.request(`/api/users/${id}`, {
            method: 'DELETE'
        });
    }

    async checkHealth() {
        return this.request('/health');
    }
}

// UI Manager Class
class UIManager {
    constructor(skipInit = false) {
        this.apiService = new ApiService(API_BASE_URL);
        if (!skipInit) {
            this.init();
        }
    }

    init() {
        this.bindEvents();
        this.loadUsers();
        this.checkApiStatus();
        
        // Check API status every 30 seconds
        setInterval(() => this.checkApiStatus(), 30000);
    }

    bindEvents() {
        const userFormEl = document.getElementById('userForm');
        const refreshBtnEl = document.getElementById('refreshBtn');
        
        if (userFormEl) {
            userFormEl.addEventListener('submit', (e) => this.handleUserSubmit(e));
        }
        if (refreshBtnEl) {
            refreshBtnEl.addEventListener('click', () => this.loadUsers());
        }
    }

    showLoading() {
        const loadingEl = document.getElementById('loadingMessage');
        if (loadingEl) {
            loadingEl.classList.remove('hidden');
        }
        this.hideError();
    }

    hideLoading() {
        const loadingEl = document.getElementById('loadingMessage');
        if (loadingEl) {
            loadingEl.classList.add('hidden');
        }
    }

    showError(message) {
        const errorEl = document.getElementById('errorMessage');
        if (errorEl) {
            errorEl.textContent = message;
            errorEl.classList.remove('hidden');
        }
        this.hideLoading();
    }

    hideError() {
        const errorEl = document.getElementById('errorMessage');
        if (errorEl) {
            errorEl.classList.add('hidden');
        }
    }

    showSuccess(message) {
        // Create temporary success message
        const successDiv = document.createElement('div');
        successDiv.className = 'success';
        successDiv.textContent = message;
        
        const usersSection = document.querySelector('.users-section');
        usersSection.insertBefore(successDiv, usersSection.firstChild);
        
        // Remove after 3 seconds
        setTimeout(() => {
            if (successDiv.parentNode) {
                successDiv.parentNode.removeChild(successDiv);
            }
        }, 3000);
    }

    async handleUserSubmit(e) {
        e.preventDefault();
        
        const userNameEl = document.getElementById('userName');
        const userEmailEl = document.getElementById('userEmail');
        const userFormEl = document.getElementById('userForm');
        
        if (!userNameEl || !userEmailEl) {
            this.showError('Form elements not found');
            return;
        }
        
        const name = userNameEl.value.trim();
        const email = userEmailEl.value.trim();
        
        if (!name || !email) {
            this.showError('Please fill in all fields');
            return;
        }

        try {
            this.showLoading();
            await this.apiService.createUser({ name, email });
            
            // Clear form
            if (userFormEl) {
                userFormEl.reset();
            }
            
            // Reload users list
            await this.loadUsers();
            this.showSuccess('User created successfully!');
            
        } catch (error) {
            this.showError(`Failed to create user: ${error.message}`);
        }
    }

    async loadUsers() {
        try {
            this.showLoading();
            const users = await this.apiService.getUsers();
            this.renderUsers(users);
            this.hideError();
        } catch (error) {
            this.showError(`Failed to load users: ${error.message}`);
            const usersListEl = document.getElementById('usersList');
            if (usersListEl) {
                usersListEl.innerHTML = '';
            }
        } finally {
            this.hideLoading();
        }
    }

    renderUsers(users) {
        const usersListEl = document.getElementById('usersList');
        if (!usersListEl) return;
        
        if (!users || users.length === 0) {
            usersListEl.innerHTML = '<p class="no-users">No users found</p>';
            return;
        }

        const usersHTML = users.map(user => `
            <div class="user-card" data-user-id="${user.id}">
                <div class="user-info">
                    <h3>${this.escapeHtml(user.name)}</h3>
                    <p>${this.escapeHtml(user.email)}</p>
                </div>
                <div class="user-actions">
                    <button class="delete-btn" onclick="uiManager.deleteUser(${user.id})">
                        Delete
                    </button>
                </div>
            </div>
        `).join('');

        usersListEl.innerHTML = usersHTML;
    }

    async deleteUser(userId) {
        if (!confirm('Are you sure you want to delete this user?')) {
            return;
        }

        try {
            await this.apiService.deleteUser(userId);
            await this.loadUsers();
            this.showSuccess('User deleted successfully!');
        } catch (error) {
            this.showError(`Failed to delete user: ${error.message}`);
        }
    }

    async checkApiStatus() {
        try {
            await this.apiService.checkHealth();
            this.updateApiStatus('online', 'API is online and healthy');
        } catch (error) {
            this.updateApiStatus('offline', `API is offline: ${error.message}`);
        }
    }

    updateApiStatus(status, message) {
        const apiStatusEl = document.getElementById('apiStatus');
        if (apiStatusEl) {
            apiStatusEl.className = `status ${status}`;
            apiStatusEl.textContent = message;
        }
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Utility Functions for Testing
window.testUtils = {
    ApiService,
    UIManager,
    
    // Mock fetch for testing
    mockFetch: (mockResponse) => {
        const originalFetch = window.fetch;
        window.fetch = jest.fn(() => Promise.resolve({
            ok: true,
            json: () => Promise.resolve(mockResponse)
        }));
        return originalFetch;
    },
    
    // Restore original fetch
    restoreFetch: (originalFetch) => {
        window.fetch = originalFetch;
    }
};

// Initialize the app
let uiManager;
document.addEventListener('DOMContentLoaded', () => {
    uiManager = new UIManager();
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { ApiService, UIManager };
}

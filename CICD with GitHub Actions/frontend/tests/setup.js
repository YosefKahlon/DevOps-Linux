// Mock fetch globally
global.fetch = jest.fn();

// Mock DOM elements that might be needed
Object.defineProperty(window, 'location', {
  value: {
    href: 'http://localhost:8080'
  },
  writable: true
});

// Clean up after each test
afterEach(() => {
  jest.clearAllMocks();
  document.body.innerHTML = '';
});

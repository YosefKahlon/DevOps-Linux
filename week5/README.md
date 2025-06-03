# Demo Full-Stack Application

A complete demo application with Node.js backend API and vanilla JavaScript frontend, including comprehensive testing.

## Project Structure

```
week5/
├── backend/                 # Node.js Express API
│   ├── server.js           # Main server file
│   ├── package.json        # Backend dependencies
│   ├── jest.config.js      # Jest configuration
│   └── tests/
│       └── api.test.js     # API endpoint tests
├── frontend/               # Vanilla JavaScript frontend
│   ├── index.html          # Main HTML file
│   ├── app.js             # JavaScript application
│   ├── styles.css         # CSS styles
│   ├── package.json       # Frontend dependencies
│   ├── jest.config.js     # Jest configuration
│   └── tests/
│       ├── setup.js       # Test setup
│       └── app.test.js    # Frontend tests
└── README.md              # This file
```

## Features

### Backend API
- RESTful API with Express.js
- CRUD operations for user management
- Health check endpoint
- Error handling middleware
- CORS support
- Comprehensive unit tests with Jest and Supertest

**API Endpoints:**
- `GET /` - Welcome message
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `DELETE /api/users/:id` - Delete user
- `GET /health` - Health check

### Frontend
- Modern, responsive UI with vanilla JavaScript
- User management interface
- Real-time API status monitoring
- Form validation and error handling
- Clean, modern CSS design
- Unit tests for JavaScript functions

## Setup and Installation

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```
   Or for production:
   ```bash
   npm start
   ```

4. The API will be available at `http://localhost:3000`

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies (for testing):
   ```bash
   npm install
   ```

3. Serve the frontend:
   ```bash
   npm start
   ```
   Or manually serve with Python:
   ```bash
   python3 -m http.server 8080
   ```

4. The frontend will be available at `http://localhost:8080`

## Running Tests

### Backend Tests
```bash
cd backend
npm test
```

For watch mode:
```bash
npm run test:watch
```

### Frontend Tests
```bash
cd frontend
npm test
```

For watch mode:
```bash
npm run test:watch
```

## API Usage Examples

### Get all users
```bash
curl http://localhost:3000/api/users
```

### Create a new user
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

### Delete a user
```bash
curl -X DELETE http://localhost:3000/api/users/1
```

### Check API health
```bash
curl http://localhost:3000/health
```

## Technologies Used

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **CORS** - Cross-origin resource sharing
- **Jest** - Testing framework
- **Supertest** - HTTP testing
- **Nodemon** - Development auto-reload

### Frontend
- **Vanilla JavaScript** - No frameworks
- **HTML5** - Semantic markup
- **CSS3** - Modern styling with Grid and Flexbox
- **Jest** - Testing framework
- **jsdom** - DOM testing environment

## Development

### Backend Development
- The server uses `nodemon` for auto-reloading during development
- API follows RESTful conventions
- Comprehensive error handling and validation
- In-memory data storage (resets on server restart)

### Frontend Development
- Pure JavaScript ES6+ features
- Responsive design that works on mobile and desktop
- Error handling and user feedback
- Clean separation of concerns with classes

### Testing
- Both frontend and backend have comprehensive test suites
- Backend tests cover all API endpoints and error scenarios
- Frontend tests cover utility functions and UI logic
- Tests use mocking for external dependencies

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

MIT License - see LICENSE file for details

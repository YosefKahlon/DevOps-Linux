module.exports = {
  testEnvironment: 'jsdom',
  testMatch: ['**/tests/**/*.test.js'],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  collectCoverageFrom: [
    'app.js',
    '!tests/**',
    '!node_modules/**'
  ],
  coverageReporters: ['text', 'html'],
  verbose: true
};

module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverageFrom: [
    '*.js',
    '!tests/**',
    '!node_modules/**'
  ],
  coverageReporters: ['text', 'html'],
  verbose: true
};

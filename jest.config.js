const { jestConfig } = require('@salesforce/lwc-jest/config');
module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^(c)/(.+)$': '<rootDir>/src/lwc/$2/$2'
    },
    testPathIgnorePatterns: [
        '<rootDir>/node_modules/',
        '<rootDir>/test/specs/'
    ]
};
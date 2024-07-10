module.exports = {
  "env": {
    "es6": true,
    "node": true
  },
  "extends": "eslint:recommended",
  "rules": {
    "quotes": ["error", "double"],
    "semi": ["error", "always"],
    "max-len": ["error", { "code": 100 }]
  }
};
import qml from "eslint-plugin-qml-linter-xd";

export default [
  {
    files: ["**/*.js", "**/*.js.in"],
    ignores: ["version.js"],
    languageOptions: {
      ecmaVersion: "latest", // Modern JavaScript
      sourceType: "module",
    },
    rules: {
      //"no-unused-vars": "warn",
      // This is in a separate MR

      //"eqeqeq": ["error", "always"], // Require === and !== instead of == and !=
      // This cannot be enabled safely

      "semi": ["error", "always"],
      // Enforce semicolons

      //"keyword-spacing": "error",
      //"space-before-blocks": "error",
      //"no-nested-ternary": "error",
      // Next
    },
    processor: qml.processors["pragma-js"],
  },
  {
    files: ["**/*.qml"],
    processor: qml.processors.qml,
  },
];

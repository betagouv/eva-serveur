module.exports = {
  stories: ["../spec/components/**/*.stories.json"],
  addons: ["@storybook/addon-controls"],

  framework: {
    name: "@storybook/server-webpack5",
    options: {}
  }
};

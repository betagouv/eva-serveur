/** @type { import('@storybook/server-webpack5').StorybookConfig } */
const config = {
  stories: ["../spec/components/stories/**/*.mdx", "../spec/components/stories/*.stories.json"],
  addons: ["@storybook/addon-links", "@storybook/addon-essentials"],
  framework: {
    name: "@storybook/server-webpack5",
    options: {},
  },
  docs: {
    autodocs: "tag",
  },
};
export default config;

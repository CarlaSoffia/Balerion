const { defineConfig } = require('@vue/cli-service')
const Dotenv = require('dotenv-webpack');

module.exports = defineConfig({
  devServer: {
    allowedHosts: 'all',
  },
  transpileDependencies: [
    'vuetify'
  ],
  configureWebpack: {
    plugins: [
      new Dotenv()
    ]
  }
})

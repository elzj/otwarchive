const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.set('Provide',  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.Tether': "tether",
    Popper: ['popper.js', 'default'],
    ActionCable: 'actioncable',
    // Vue: 'vue',
    // VueResource: 'vue-resource',
  })
)

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
  // vue: "vue/dist/vue.js",
  // vue_resource: "vue-resource/dist/vue-resource",
}

module.exports = environment
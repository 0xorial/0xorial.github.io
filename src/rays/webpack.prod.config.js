const path = require('path');
const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const HtmlWebpackExternalsPlugin = require('html-webpack-externals-plugin');

module.exports = {
   context: __dirname, // to automatically find tsconfig.json
   mode: 'production',
   entry: {
      webpersephone: './src/Index.tsx',
   },
   output: {
      filename: '[name].js',
      path: path.resolve(__dirname, './dist')
   },
   module: {
      rules: [
         {
            test: /\.css$/,
            use: [
               'style-loader',
               'css-loader'
            ]
         },
         {
            test: /\.(jpe?g|gif|png|ttf|eot|svg|woff(2)?)(\?[a-z0-9=&.]+)?$/,
            use: 'base64-inline-loader?limit=1000&name=[name].[ext]'
         },
         {
            test: [/Testing.ts$/, /UserConfig.js$/],
            loader: 'webpack-conditional-loader',
            exclude: /node_modules/
         },
         {
            test: /\.[jt]sx?$/,
            loader: 'ts-loader',
            exclude: /node_modules/,
            options: {
               transpileOnly: true,
               experimentalWatchApi: true,
            }
         }
      ]
   },
   optimization: {
      splitChunks: {
         cacheGroups: {
            vendor: {
               test: /node_modules/,
               chunks: 'initial',
               name: 'vendor',
               enforce: true
            },
         }
      }
   },
   resolve: {
      extensions: ['.tsx', '.ts', '.js'],
      alias: {
         'pixi.js': path.resolve(__dirname, './node_modules/pixi.js/bin/pixi.js')
      }
   },
   plugins: [
      new CopyWebpackPlugin([
         { from: "./**/*", to: "./", context: "./static", ignore: "./index.html" },
//         { from: "./node_modules/webix/webix.js", to: "./" },
      ]),
      new HtmlWebpackPlugin({
         template: "./static/index.html",
         templateParameters: {
            // server should replace this later inside index.html
            //SERVICE_URL: "$WEB_CERBERUS_SERVICE_URL$"
            SERVICE_URL: "'./webcerberus/'"
         }
      }),
      new HtmlWebpackExternalsPlugin({
         externals: [
            {
               module: 'webix',
               entry: ['webix.js']
            }
         ],
         outputPath: '.'
      }),
      new webpack.ProvidePlugin({
         $: 'jquery',
         jQuery: 'jquery'
      })
   ]
};
const path = require('path');
const webpack = require('webpack');
const ForkTsCheckerWebpackPlugin = require('C:\\users\\user\\fork-ts-checker-webpack-plugin\\lib');
const CircularDependencyPlugin = require('circular-dependency-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const HtmlWebpackExternalsPlugin = require('html-webpack-externals-plugin');
// const { CheckerPlugin } = require('awesome-typescript-loader')

process.env['NODE_ENV'] = 'development';

function makeTsLoader(test) {
   return {
      test,
      exclude: /node_modules/,
      use: {
         loader: 'babel-loader',
         options: {
            cacheDirectory: true,
            babelrc: false,
            presets: [
               [
                  '@babel/preset-env',
                  {targets: {browsers: 'last 2 versions'}} // or whatever your project requires
               ],
               '@babel/preset-typescript',
               '@babel/preset-react'
            ],
            plugins: [
               // plugin-proposal-decorators is only needed if you're using experimental decorators in TypeScript
               ['@babel/plugin-proposal-decorators', {legacy: true}],
               ['@babel/plugin-proposal-class-properties', {loose: true}]
            ]
         }
      }
   };
}

const tsLoader = makeTsLoader(/\.([jt])s$/);
const tsxLoader = makeTsLoader(/\.([jt])sx$/);
tsxLoader.use.options.plugins.push('react-hot-loader/babel');

module.exports = {
   context: __dirname, // to automatically find tsconfig.json
   mode: 'development',
   entry: {
      webpersephone: ['@babel/polyfill', './src/Index.tsx']
   },
   output: {
      filename: '[name].js',
      path: path.resolve(__dirname, './dist')
   },
   devtool: 'eval-source-map',
   optimization: {
      splitChunks: {
         cacheGroups: {
            vendor: {
               test: /node_modules/,
               chunks: 'initial',
               name: 'vendor',
               enforce: true
            }
         }
      }
   },
   module: {
      rules: [
         {
            test: /\.css$/,
            use: ['style-loader', 'css-loader']
         },
         {
            test: /\.(png|svg|jpg|gif)$/,
            use: ['file-loader']
         },
         {
            test: /\.(woff|woff2|eot|ttf|otf)$/,
            use: ['file-loader']
         },
         {
            test: [/testing.ts$/, /userConfig.js$/],
            loader: 'webpack-conditional-loader',
            exclude: /node_modules/
         },
         tsLoader,
         tsxLoader
      ]
   },
   resolve: {
      extensions: ['.tsx', '.ts', '.js'],
      alias: {
         'pixi.js': path.resolve(__dirname, './node_modules/pixi.js/bin/pixi.js')
      }
   },
   plugins: [
      new CopyWebpackPlugin([{from: './**/*', to: './', context: './static', ignore: './index.html'}]),
      new HtmlWebpackPlugin({
         template: './src/index.html',
         templateParameters: {
            SERVICE_URL: "'http://localhost:1337/'"
            //SERVICE_URL: "'https://web.persephonesoft.com/webcerberus/'"
            //SERVICE_URL: "'http://web.persephonesoft.com:1339/'"
         }
      }),
      new webpack.HotModuleReplacementPlugin(),
      new ForkTsCheckerWebpackPlugin({
         async: false,
         workers: ForkTsCheckerWebpackPlugin.ONE_CPU,
         tslint: true,
         useTypescriptIncrementalApi: true
      }),
      new CircularDependencyPlugin({
         // exclude detection of files based on a RegExp
         exclude: /a\.js|node_modules/,
         // add errors to webpack instead of warnings
         failOnError: false,
         // set the current working directory for displaying module paths
         cwd: process.cwd()
      }),
      new webpack.ProvidePlugin({
         $: 'jquery',
         jQuery: 'jquery'
      })
   ],
   devServer: {
      hot: true,
      contentBase: './static'
   }
};

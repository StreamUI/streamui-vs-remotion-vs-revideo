// webpack.config.js
module.exports = {
  // Other configurations...
  resolve: {
    fallback: {
      crypto: false,
      stream: false,
      os: false,
      fs: false,
      net: false,
      tls: false,
      perf_hooks: false,
    },
  },
};

// const isProd = process.env.NODE_ENV === "production";
// Have to set false otherwise pnpm start doesn't work
const isProd = false;


module.exports = {
  reactStrictMode: true,
  assetPrefix: isProd ? "/aptos-wallet-adapter" : "",
  basePath: isProd ? "/aptos-wallet-adapter" : "",
  images: { unoptimized: true },
  experimental: {
    transpilePackages: ["wallet-adapter-react", "wallet-adapter-plugin"],
  },
  webpack: (config) => {
    config.resolve.fallback = { "@solana/web3.js": false };
    return config;
  },
  typescript: {
    ignoreBuildErrors: true,
  }
};

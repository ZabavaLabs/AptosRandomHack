import type { AppProps } from "next/app";
import { AppContext } from "../components/AppContext";
import { ThirdwebSDKProvider } from "@thirdweb-dev/react";
// order matters
import "../styles/global.css";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css"

// import { Roboto } from 'next/font/google'

// const roboto = Roboto({
//   weight: '400',
//   subsets: ['latin'],
// })

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <AppContext>
      <ThirdwebSDKProvider>

        <Component {...pageProps} />
      </ThirdwebSDKProvider>
    </AppContext>
  );
}

export default MyApp;

import type { AppProps } from "next/app";
import { AppContext } from "../components/AppContext";
import { ThirdwebSDKProvider } from "@thirdweb-dev/react";
// order matters
import "../styles/global.css";
import "../../../packages/wallet-adapter-ant-design/dist/index.css"


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

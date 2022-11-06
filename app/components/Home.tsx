import { Web3ReactHooks, Web3ReactProvider } from "@web3-react/core";
import { MetaMask } from "@web3-react/metamask";
import { Network } from "@web3-react/network";
import { ReactNode } from "react";
import { hooks as metaMaskHooks, metaMask } from '../connectors/metaMask'
import { hooks as networkHooks, network } from '../connectors/networks'
interface HomeProps {
  children: ReactNode
}

const connectors: [MetaMask | Network, Web3ReactHooks][] = [[metaMask, metaMaskHooks], [network, networkHooks],]

export function Home(props: HomeProps) {
  return <Web3ReactProvider connectors={connectors}>
    <div className="w-screen h-screen   antialiased  relative flex  flex-col items-center font-mono   bg-gray-50  dark:bg-gray-900 text-slate-800 dark:text-slate-400 transition-colors duration-500 ease-in-out">
      {props.children}
    </div>
  </Web3ReactProvider>
}
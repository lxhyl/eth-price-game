import { Web3ReactHooks, Web3ReactProvider } from "@web3-react/core";
import { MetaMask } from "@web3-react/metamask";
import { ReactNode } from "react";
import { hooks as metaMaskHooks, metaMask } from '../connectors/metaMask'
interface HomeProps {
  children: ReactNode
}

const connectors: [MetaMask, Web3ReactHooks][] = [[metaMask, metaMaskHooks]]

export function Home(props: HomeProps) {
  return <Web3ReactProvider connectors={connectors}>
    {props.children}
  </Web3ReactProvider>
}
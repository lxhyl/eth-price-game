import { initializeConnector } from '@web3-react/core'
import { Network } from "@web3-react/network"
import { ChainIds } from "../constants/chains"
const URLS = {
  [ChainIds.Goerli]: ["https://goerli.infura.io/v3", "https://eth-goerli.g.alchemy.com/v2/wh0r3i6JeVmVljf6920SkF8x5e4kITQC"]
}

export const [network, hooks] = initializeConnector<Network>((actions) => new Network({ actions, urlMap: URLS }))
network.activate(ChainIds.Goerli)
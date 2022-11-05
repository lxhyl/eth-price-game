export enum ChainIds {
  Goerli = 5
}

export interface Chain {
  name: string
  nativeCurrency: string
  chainId: number
  rpcUrl: string[]
  scanUrl: string
}

type Chains = { [key in ChainIds]: Chain }

export const chains: Chains = {
  [ChainIds.Goerli]: {
    name: "Goerli",
    nativeCurrency: "ETH",
    chainId: ChainIds.Goerli,
    rpcUrl: ["https://goerli.infura.io/v3"],
    scanUrl: "https://goerli.etherscan.io"
  }
}



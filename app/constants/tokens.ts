import { ChainIds } from "./chains";

export interface Token {
  name: string,
  symbol: string,
  decimals: string,
  chainId: ChainIds
}

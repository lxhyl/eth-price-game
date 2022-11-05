import { useWeb3React } from "@web3-react/core"
import { Contract } from "ethers"
import { useMemo } from "react"
import GameCoreABI from "../constants/gameCoreABI.json"
import { useSigner } from "./useSigner"
export function useContracts(contractAddress: string, write = false) {
  const { provider } = useWeb3React()
  const signer = useSigner()
  return useMemo(() => {
    if (!provider) return
    if (write && !signer) return
    return new Contract(contractAddress, GameCoreABI, write ? signer : provider)
  }, [contractAddress, provider, signer, write])

}
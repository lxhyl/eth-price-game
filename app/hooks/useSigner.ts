import { useWeb3React } from '@web3-react/core'
import { useMemo } from 'react'

export function useSigner() {
  const { provider, chainId } = useWeb3React()
  const signer = useMemo(() => {
    if (!provider || !chainId) return
    const signer = (provider as any).getSigner()
    if (signer) {
      return signer
    }
  }, [provider, chainId])

  return signer
}
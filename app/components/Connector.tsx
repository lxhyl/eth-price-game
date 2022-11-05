import { useWeb3React } from '@web3-react/core'
import { useCallback, useEffect, useState } from 'react'
import { metaMask } from '../connectors/metaMask'
export function Connector() {
  const { account } = useWeb3React()
  const [isConnect, setIsConnect] = useState<boolean>(false)
  const connect = useCallback(() => {
    if (!metaMask.provider) {
      return
    }
    metaMask
      .activate()
      .then(() => {
        setIsConnect(true)
      })
      .catch(() => setIsConnect(false))
  }, [])
  useEffect(() => {
    void metaMask.connectEagerly()
  }, [])
  return <button onClick={connect}>
    {isConnect ? account : 'connect'}
  </button>
}
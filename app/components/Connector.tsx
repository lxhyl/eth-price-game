import { useWeb3React } from '@web3-react/core'
import { useCallback, useEffect, useState } from 'react'
import { hooks as metaMaskHooks, metaMask } from '../connectors/metaMask'
const { useIsActive } = metaMaskHooks
export function Connector() {
  const { account } = useWeb3React()
  const isActive = useIsActive()
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
    if (isActive && !account) {
      connect()
      return
    }
    if (!isActive && account) {
      setIsConnect(false)
      return
    }
    if (isActive && account) {
      setIsConnect(true)
    }
  }, [isActive, account, connect])
  useEffect(() => {
    void metaMask.connectEagerly()
  }, [])
  return <button onClick={connect} className="text-xs py-10">
    {isConnect ? account : 'connect'}
  </button>
}
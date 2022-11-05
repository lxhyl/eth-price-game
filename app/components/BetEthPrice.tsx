import { BigNumber } from "ethers";
import { useCallback, useEffect } from "react";
import { useContracts } from "../hooks/useContracts";

export function BetEthPrice() {
  const gameContract = useContracts("0x238254c190934d8c1eE595E515132C264cD20F53", true);

  const startGame = useCallback(() => {
    if (!gameContract) return
    gameContract.start()
  }, [gameContract])
  const bet = useCallback((n: number) => {
    if (!gameContract) return
    gameContract.bet(n)
  }, [gameContract])
  const getGameData = useCallback(async () => {
    if (!gameContract) return
    console.log("gameContract", gameContract)
    const currentEpoch: BigNumber = await gameContract.currentEpoch();

    for (let epoch = 1; epoch <= currentEpoch.toNumber(); epoch++) {
      console.log("currentEpoch", epoch, currentEpoch)
      const res = await gameContract.getGameByEpoch(BigNumber.from(epoch))
      console.log("res", res)
    }

  }, [gameContract])
  useEffect(() => {
    getGameData()
  }, [getGameData])
  return <div>
    <button onClick={startGame}>Start Game</button>
    <button onClick={() => bet(1)}>Bet up</button>
    <button onClick={() => bet(-1)}>Bet down</button>
  </div>
}
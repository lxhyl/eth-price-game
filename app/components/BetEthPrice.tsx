import { BigNumber } from "ethers";
import { useCallback, useEffect, useState } from "react";
import { useContracts } from "../hooks/useContracts";

export function BetEthPrice() {
  const gameContract = useContracts("0xacD12BC3c86976F758a7cD163ba4B3b36B602047", true);
  const [errMsg, setErrMsg] = useState<string>()
  const startGame = useCallback(() => {
    if (!gameContract) return
    gameContract.start().catch((err: any) => setErrMsg(err.reason))
  }, [gameContract])
  const bet = useCallback((n: number) => {
    if (!gameContract) return
    gameContract.bet(n).catch((err: any) => setErrMsg(err.reason))
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
  const endGame = useCallback(async () => {
    if (!gameContract) return
    gameContract.endCurrentGame().catch((err: any) => setErrMsg(err.reason));
  }, [gameContract])
  useEffect(() => {
    getGameData()
  }, [getGameData])
  return <div>
    <div className="flex gap-4">
      <button className="border border-gray-500 p-1" onClick={startGame}>Start Game</button>
      <button className="border border-gray-500 p-1" onClick={() => bet(1)}>Bet up</button>
      <button className="border border-gray-500 p-1" onClick={() => bet(-1)}>Bet down</button>
      <button className="border border-gray-500 p-1" onClick={endGame}>End Game</button>
    </div>
    <div className=" text-xs text-red-500 mt-4 ">Recent error:{errMsg}</div>
  </div>
}
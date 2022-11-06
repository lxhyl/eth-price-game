import { BigNumber, utils } from "ethers";
import { useCallback, useEffect, useState } from "react";
import { useContracts } from "../hooks/useContracts";

interface Game {
  epoch: number,
  startPrice: BigNumber
  endPrice: BigNumber
  startTime: Date
  ethAmount: BigNumber
  upGamers: string[]
  downGamers: string[]
}

export function BetEthPrice() {
  const gameContract = useContracts("0x21891c0Fa0915656575f041F5bB4321B21e0c283", true)
  const readGameContract = useContracts("0x21891c0Fa0915656575f041F5bB4321B21e0c283")
  const [errMsg, setErrMsg] = useState<string>()
  const [games, setGames] = useState<Game[]>([])
  const startGame = useCallback(() => {
    if (!gameContract) return
    gameContract.start().catch((err: any) => setErrMsg(err.reason))
  }, [gameContract])
  const bet = useCallback((n: number) => {
    if (!gameContract) return
    gameContract.bet(n, { value: 0.001 * 1e18 }).catch((err: any) => setErrMsg(err.reason))
  }, [gameContract])

  const getGameData = useCallback(async () => {
    if (!readGameContract) return
    console.log("gameContract", readGameContract)
    const currentEpoch: BigNumber = await readGameContract.currentEpoch();
    const games: Game[] = []
    for (let epoch = 1; epoch <= currentEpoch.toNumber(); epoch++) {

      const res = await readGameContract.getGameByEpoch(BigNumber.from(epoch))
      console.log("res", res)
      const [startPrice, endPrice, startTime, ethAmount, upGamers, downGamers] = res
      games.push({
        epoch,
        startPrice,
        endPrice,
        ethAmount,
        upGamers,
        downGamers,
        startTime: new Date(startTime.toNumber() * 1000)
      })
    }
    setGames(games)
  }, [readGameContract])
  const endGame = useCallback(async () => {
    if (!gameContract) return
    gameContract.endCurrentGame().catch((err: any) => setErrMsg(err.reason));
  }, [gameContract])
  useEffect(() => {
    getGameData()
    const timer = setInterval(getGameData, 30 * 1000)
    return () => {
      clearInterval(timer)
    }
  }, [getGameData])
  return <div className="flex flex-col items-center">
    <div className="flex gap-4">
      <button className="border border-gray-500 p-1" onClick={startGame}>Start Game</button>
      <button className="border border-gray-500 p-1" onClick={() => bet(1)}>Bet up</button>
      <button className="border border-gray-500 p-1" onClick={() => bet(-1)}>Bet down</button>
      <button className="border border-gray-500 p-1" onClick={endGame}>End Game</button>
    </div>
    <div className="flex items-center  text-xs text-red-500">{errMsg}
      {errMsg && <span className=" text-lg text-black ml-2 cursor-pointer" onClick={() => setErrMsg(undefined)}>X</span>}
    </div>
    <div className="mt-10  bg-slate-200 p-4 rounded-lg">

      {games.reverse().map((game) => <div key={game.startTime.getTime()}>
        <div className="w-full flex items-center justify-center text-2xl font-bold">Game-{game.epoch} </div>
        <div className="my-2 flex gap-4">
          <div className="flex items-center">
            <span className="text-sm">StartEthPrice:</span>
            <span className=" text-xl font-bold">{utils.formatUnits(game.startPrice, 8)}</span></div>
          <div className="flex items-center">
            <span className="text-sm">EndEthPrice:</span>
            <span className=" text-xl font-bold">{game.endPrice.eq(0) ? "?" : utils.formatUnits(game.endPrice, 8)}</span></div>
        </div>
        <div><span className="text-sm">Reward:</span> <span className="text-xl font-bold">{utils.formatEther(game.ethAmount)} eth</span></div>
        <div className="flex flex-col gap-5 mt-8">
          <div className="text-xs p-4 bg-red-500 ">
            <h1 className="text-white text-lg">Up</h1>
            {game.upGamers.map(address => <div key={address} className="text-gray-100">{address}</div>)}
          </div>
          <div className="w-full items-center justify-center flex italic">VS</div>
          <div className="text-xs  p-4 bg-green-400  ">
            <h1 className=" text-black text-lg">Down</h1>
            {game.downGamers.map(address => <div key={address} className="text-gray-800">{address}</div>)}
          </div>
        </div>
      </div>)}
    </div>
  </div>
}
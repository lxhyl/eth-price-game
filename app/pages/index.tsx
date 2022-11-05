
import { BetEthPrice } from "../components/betEthPrice"
import { Connector } from "../components/Connector"
import { Home } from "../components/Home"
export default function Page() {
  return <Home>
    <Connector />
    <BetEthPrice />
  </Home>
}

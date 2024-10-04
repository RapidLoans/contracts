import dotenv from "dotenv";
import promptSync from "prompt-sync";
import {
  TronWeb,
  utils as TronWebUtils,
  Trx,
  TransactionBuilder,
  Contract,
  Event,
  Plugin,
} from "tronweb";
import abi from "./abi.json" assert { type: "json" };
import jstabi from "./jstabi.json" assert { type: "json" };

async function sendMessage() {
  //initialise tronweb
  const tronWeb = new TronWeb({
    fullHost: "https://nile.trongrid.io",
    privateKey: process.env.PRIVATE_KEY_NILE,
  });
  //set liquidity pool address
  const lpAddress = TronWeb.address.fromHex(
    "4139b0b7753db0ccc9fe8ec9da85d2c7b1d618d6fb"
  );
  //initialise liquidity pool contract
  const contract = await tronWeb.contract(abi.abi, lpAddress);
  //call functions on liquidity pool
  let txID = await contract.addTRX().send({ callValue: 100000 });
  //console
  let result = await tronWeb.trx.getTransaction(txID);
  console.log("txid", txID);
  console.log("result", result);

  //   let jst = await tronWeb.contract(
  //     jstabi.jstabi,
  //     "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
  //   );
  //   let txid2 = await jst.approve(100000).send();
  //   console.log("txid2", txid2);
  // }
}
sendMessage();

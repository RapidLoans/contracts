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

// const tronWeb = new TronWeb({
//   fullHost: "https://nile.trongrid.io",
//   privateKey: process.env.PRIVATE_KEY_NILE,
// });
async function sendMessage() {
  const tronWeb = new TronWeb({
    fullHost: "https://nile.trongrid.io",
    privateKey: process.env.PRIVATE_KEY_NILE,
  });
  const contractAddress = TronWeb.address.fromHex(
    "410e2fd45f247847522b57c3544d597ed14c956f4c"
  );

  const contract = await tronWeb.contract(abi.abi, contractAddress);
  console.log(contract);
  //   console.log(abi);

  let txID = await contract.addTRX().send({ callValue: 100000 });
  // now you can visit web page https://nile.tronscan.org/#/transaction/${txID} to view the transaction detail.
  // or using code below:
  let result = await tronWeb.trx.getTransaction(txID);
  console.log("result", result);

  // Commented code for sending messages
  // let lastMessage = await contract.getLastMessage().call();
  // console.log(`The current message is: ${lastMessage}`);
  // let input = prompt("Do you want to send a new message? ([1]: Yes, [2]: No) ");
  // if (input == 1) {
  //   let newMessage = prompt("Type your new message: ");
  //   let txId = await contract.setMessage(newMessage).send();
  //   console.log(
  //     `Check tx on the explorer: https://nile.tronscan.org/#/transaction/${txId}`
  //   );
  //   lastMessage = await contract.getLastMessage().call();
  //   console.log(`The current message is: ${lastMessage}`);
  // }

  //   let txId = await contract.addTRX().send({ callValue: 100000 });
  //   console.log(`Transaction ID: ${txId}`);
}

sendMessage();

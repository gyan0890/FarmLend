import React, { Component } from "react";
import SimpleStorageContract from "./contracts/SimpleStorage.json";
import FarmLend from "./contracts/FarmLend.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = FarmLend.networks[networkId];
      const instance = new web3.eth.Contract(
        FarmLend.abi,
        deployedNetwork && deployedNetwork.address,
      );
      
      console.log("Instance is:", instance);
      //FarmLend code is here
      // const deployedNetwork = FarmLend.networks[networkId];
      // const instance = new web3.eth.Contract(
      //   FarmLend.abi,
      //   deployedNetwork && deployedNetwork.address,
      // );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    const response = await contract.methods.registerFarmerLoanProposal(100,31,10,2021,5,2,2).send({ from: accounts[0] });
    console.log("Response from the contract is", response)
    // Get the value from the contract to prove it worked.
    const response2 = await contract.methods.getNumProposals().call();
    console.log("Another response", response2[0]);
    // Update state with the result.
    this.setState({ storageValue: response });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Good to Go!</h1>
        <p>Your Truffle Box is installed and ready.</p>
        <h2>Smart Contract Example</h2>
        <p>
          If your contracts compiled and migrated successfully, below will show
          a stored value of 5 (by default).
        </p>
        <p>
          Try changing the value stored on <strong>line 49</strong> of App.js.
        </p>
        <div>The boolean value is: {this.state.storageValue}</div>
      </div>
    );
  }
}

export default App;

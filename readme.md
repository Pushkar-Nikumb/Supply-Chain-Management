# Supply Chain Management Smart Contract

This Solidity smart contract facilitates the management of a supply chain involving harvesters, depots, and refineries. It enables transparent and secure tracking of biomass movement from harvesters to depots and from depots to refineries. Below are the key features and functionalities of the contract:

## Features:

1. **Registration of Entities**:
   - Harvesters, depots, and refineries can be registered with their relevant information such as mobile number, location, and city.

2. **Supply Chain Tracking**:
   - Biomass movements are tracked at different stages of transportation, including from harvester to depot and from depot to refinery.
   - Detailed information such as biomass type, origin and destination cities, current location, timestamps, and transportation stages are recorded.

3. **Data Integrity and Security**:
   - The contract ensures data integrity and security through various checks and validations.
   - Access control mechanisms restrict certain functions to be accessible only by the contract owner for enhanced security.

## Usage:

1. **Register Entities**:
   - Use the provided functions to register harvesters, depots, and refineries by providing relevant information.

2. **Add Biomass to Supply Chain**:
   - Add biomass to the supply chain by specifying the harvester, depot, and biomass type.
   - Track biomass movement by updating locations and marking when biomass reaches its destination.

3. **Trace Supply Chain**:
   - Utilize functions to trace the supply chain and retrieve detailed information about biomass movements from harvesters to depots and from depots to refineries.

## Getting Started:

1. Clone the repository containing the smart contract.
2. Deploy the contract on a compatible blockchain network using a suitable development environment (e.g., Remix, Truffle).
3. Interact with the deployed contract using a blockchain wallet or web interface to register entities, add biomass to the supply chain, and trace supply chain movements.

## Dependencies:

- This smart contract is written in Solidity and requires a compatible Ethereum Virtual Machine (EVM) for deployment and execution.
- Integration with a blockchain network (e.g., Ethereum, Binance Smart Chain) is necessary for deploying and interacting with the contract.

## Contributors:

- [Your Name]
- [Your Email]

## License:

This project is licensed under the [MIT License](LICENSE).

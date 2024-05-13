// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SupplyChainManagement {
    address public owner;

    enum TransportationStage {
        nothing,
        HarvesterToDepot,
        DepotToRefinery
    }

    struct Harvester {
        string mobileNumber;
        string harvesterName;
        string location;
        string city;
        // address harvesterAddress;
    }

    struct Depot {
        string mobileNumber;
        string depotInfo;
        string location;
        string city;
    }

    struct Refinery {
        string mobileNumber;
        string refineryInfo;
        string location;
        string city;
    }

    struct Locations {
        string city;
        string currentLocation;
        uint256 timestamp;
    }

    struct Biomass {
        string biomassType;
        string originCity;
        string destinationCity;
        Locations[] currentLocation;
        string OriginLocation;
        string DestinationLocation;
        TransportationStage transportationStage;
        bool reachedDestination;
    }

    mapping(address => Harvester) public harvesters;
    mapping(address => Depot) public depots;
    mapping(address => Refinery) public refineries;
    mapping(string => bool) public doesHarverstorExists;
    mapping(address => bool) public doesDepotExists;
    mapping(address => bool) public doesRefineryExists;
    mapping(string => address) private mobileToHarvesterAddress;

    mapping(string => address) private qrcodeidToHarvestorAddress;
    mapping(string => address) private qrcodeidToDepotAddress;
    mapping(string => address) private qrcodeidToRefineryAddress;

    mapping(string => mapping(address => mapping(address => Biomass)))
        public harvesterToDepotSupplyChain;
    mapping(string => mapping(address => mapping(address => Biomass)))
        public depotToRefinerySupplyChain;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only contract owner can perform this action"
        );
        _;
    }
    modifier depotExists(address depot) {
        require(doesDepotExists[depot] == true, "Depot Does not Exist");
        _;
    }

    modifier refineryExists(address refinery) {
        require(
            doesRefineryExists[refinery] == true,
            "Refinery Does not Exist"
        );
        _;
    }

    modifier harvertorExists(address harverter) {
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerHarvester(
        string memory _mobile,
        string memory _harvesterName,
        string memory _location,
        string memory _city
    ) external onlyOwner {
        require(bytes(_mobile).length > 0, "Mobile number cannot be empty");
        require(
            doesHarverstorExists[_mobile] != true,
            "Harvester with this mobile number already exists"
        );

        bytes32 uniqueHash = keccak256(abi.encodePacked(_mobile));

        address harvesterAddress = address(uint160(uint256(uniqueHash)));
        harvesters[harvesterAddress] = Harvester({
            mobileNumber: _mobile,
            harvesterName: _harvesterName,
            location: _location,
            city: _city
            // harvesterAddress: harvesterAddress
        });
        mobileToHarvesterAddress[_mobile] = harvesterAddress;
        doesHarverstorExists[_mobile] = true;
    }

    function getHarvesterAddress(string memory mobile)
        external
        view
        returns (address)
    {
        require(
            doesHarverstorExists[mobile] == true,
            "Harvester Does not Exist"
        );
        return mobileToHarvesterAddress[mobile];
    }

    function registerDepot(
        address depotAddress,
        string memory mobile,
        string memory info,
        string memory _location,
        string memory _city
    ) external onlyOwner {
        require(
            doesDepotExists[depotAddress] != true,
            "Depot Collector with this Metamask Address already exists"
        );

        Depot storage newDepot = depots[depotAddress];
        newDepot.mobileNumber = mobile;
        newDepot.depotInfo = info;
        newDepot.location = _location;
        newDepot.city = _city;
        doesDepotExists[depotAddress] = true;
    }

    function registerRefinery(
        address refineryAddress,
        string memory mobile,
        string memory info,
        string memory _location,
        string memory _city
    ) external onlyOwner {
        require(
            doesRefineryExists[refineryAddress] != true,
            "Refinery with this Metamask Address already exists"
        );

        Refinery storage newRefinery = refineries[refineryAddress];
        newRefinery.mobileNumber = mobile;
        newRefinery.refineryInfo = info;
        newRefinery.location = _location;
        newRefinery.city = _city;
        doesRefineryExists[refineryAddress] = true;
    }

    function addBiomassToHarvesterToDepotSupplyChain(
        string memory uniqueID,
        address harvester,
        address depot,
        string memory biomassType
    ) external onlyOwner depotExists(depot) {
        require(
            harvesterToDepotSupplyChain[uniqueID][harvester][depot]
                .transportationStage != TransportationStage(1),
            "Supply chain entry already exists"
        );
        Harvester memory harvertorObject = harvesters[harvester];
        string memory mobile = harvertorObject.mobileNumber;
        require(
            doesHarverstorExists[mobile] == true,
            "Harvester Does not Exist"
        );
        Depot memory depotObject = depots[depot];

        Locations memory newLocation = Locations({
            city: harvertorObject.city,
            currentLocation: harvertorObject.location,
            timestamp: block.timestamp
        });

        Biomass storage newBiomass = harvesterToDepotSupplyChain[uniqueID][
            harvester
        ][depot];
        newBiomass.biomassType = biomassType;
        newBiomass.originCity = harvertorObject.city;
        newBiomass.destinationCity = depotObject.city;
        newBiomass.OriginLocation = harvertorObject.location;
        newBiomass.DestinationLocation = depotObject.location;
        newBiomass.transportationStage = TransportationStage.HarvesterToDepot;
        newBiomass.reachedDestination = false;
        newBiomass.currentLocation.push(newLocation);

        qrcodeidToHarvestorAddress[uniqueID] = harvester;
        qrcodeidToDepotAddress[uniqueID] = depot;
    }

    function addLocationsFromHarverterToDepot(
        string memory uniqueID,
        string memory City,
        string memory Location
    ) external onlyOwner {
        address harverterAddress = qrcodeidToHarvestorAddress[uniqueID];
        address depotAddress = qrcodeidToDepotAddress[uniqueID];
        require(
            harvesterToDepotSupplyChain[uniqueID][harverterAddress][
                depotAddress
            ].transportationStage == TransportationStage(1),
            "Supply chain entry didn't exists"
        );

        Locations memory newLocation = Locations({
            city: City,
            currentLocation: Location,
            timestamp: block.timestamp
        });

        Biomass storage BiomassObj = harvesterToDepotSupplyChain[uniqueID][harverterAddress][depotAddress];
        BiomassObj.currentLocation.push(newLocation);
    }

    function reachedDepot(string memory uniqueID) external {
        require(msg.sender == qrcodeidToDepotAddress[uniqueID],"Only Depot Collector can call this function");
                address harverterAddress = qrcodeidToHarvestorAddress[uniqueID];
        address depotAddress = qrcodeidToDepotAddress[uniqueID];
        require(
            harvesterToDepotSupplyChain[uniqueID][harverterAddress][
                depotAddress
            ].transportationStage == TransportationStage(1),
            "Supply chain entry didn't exists"
        );
        Biomass storage BiomassObj = harvesterToDepotSupplyChain[uniqueID][harverterAddress][depotAddress];

        Locations memory newLocation = Locations({
            city: BiomassObj.destinationCity,
            currentLocation: BiomassObj.DestinationLocation,
            timestamp: block.timestamp
        });

        BiomassObj.currentLocation.push(newLocation);
        BiomassObj.reachedDestination = true;

    }

    function addBiomassToDepotToRefinerySupplyChain(
        string memory uniqueID,
        address depot,
        address refinery,
        string memory biomassType
    ) external onlyOwner depotExists(depot) refineryExists(refinery) {
        require(
            depotToRefinerySupplyChain[uniqueID][depot][refinery]
                .transportationStage != TransportationStage(2),
            "Supply chain entry already exists"
        );

        Depot memory depotObject = depots[depot];
        Refinery memory refineryObject = refineries[refinery];

        Locations memory newLocation = Locations({
            city: depotObject.city,
            currentLocation: depotObject.location,
            timestamp: block.timestamp
        });

        Biomass storage newBiomass = depotToRefinerySupplyChain[uniqueID][
            depot
        ][refinery];
        newBiomass.biomassType = biomassType;
        newBiomass.originCity = depotObject.city;
        newBiomass.destinationCity = refineryObject.city;
        newBiomass.OriginLocation = depotObject.location;
        newBiomass.DestinationLocation = refineryObject.location;
        newBiomass.transportationStage = TransportationStage.DepotToRefinery;
        newBiomass.reachedDestination = false;
        newBiomass.currentLocation.push(newLocation);

        qrcodeidToDepotAddress[uniqueID] = depot;
        qrcodeidToRefineryAddress[uniqueID] = refinery;
    }
    
     function addLocationsFromDepotToRefinery(
        string memory uniqueID,
        string memory City,
        string memory Location
    ) external onlyOwner {
        address depotAddress = qrcodeidToDepotAddress[uniqueID];
        address refineryAddress = qrcodeidToRefineryAddress[uniqueID];
        require(
            depotToRefinerySupplyChain[uniqueID][depotAddress][refineryAddress].transportationStage == TransportationStage(2),
            "Supply chain entry didn't exists"
        );

        Locations memory newLocation = Locations({
            city: City,
            currentLocation: Location,
            timestamp: block.timestamp
        });

        Biomass storage BiomassObj = depotToRefinerySupplyChain[uniqueID][depotAddress][refineryAddress];
        BiomassObj.currentLocation.push(newLocation);
    }

    function reachedRefinery(string memory uniqueID) external {    
        require(msg.sender == qrcodeidToRefineryAddress[uniqueID],"Only refinery manager can call this function");

        address depotAddress = qrcodeidToDepotAddress[uniqueID];
        address refineryAddress = qrcodeidToRefineryAddress[uniqueID];
        require(
            depotToRefinerySupplyChain[uniqueID][depotAddress][refineryAddress].transportationStage == TransportationStage(2),
            "Supply chain entry didn't exists"
        );
        Biomass storage BiomassObj = depotToRefinerySupplyChain[uniqueID][depotAddress][refineryAddress];

        Locations memory newLocation = Locations({
            city: BiomassObj.destinationCity,
            currentLocation: BiomassObj.DestinationLocation,
            timestamp: block.timestamp
        });

        BiomassObj.currentLocation.push(newLocation);
        BiomassObj.reachedDestination = true;

    }


    function traceHarverterToDepotSupplyChain(string memory uniqueID)
        external
        view
        returns (
            string memory,
            string memory,
            string memory,
            Locations[] memory,
            string memory,
            string memory,
            bool,
            string memory
        )
    {
        address harverter = qrcodeidToHarvestorAddress[uniqueID];
        address depot = qrcodeidToDepotAddress[uniqueID];
        Biomass memory harvesterToDepotData = harvesterToDepotSupplyChain[
            uniqueID
        ][harverter][depot];

        return (
            harvesterToDepotData.biomassType,
            harvesterToDepotData.originCity,
            harvesterToDepotData.destinationCity,
            harvesterToDepotData.currentLocation,
            harvesterToDepotData.OriginLocation,
            harvesterToDepotData.DestinationLocation,
            harvesterToDepotData.reachedDestination,
            "Harverter to Depot"
        );
    }

        function traceDepotToRefinerySupplyChain(string memory uniqueID)
        external
        view
        returns (
            string memory,
            string memory,
            string memory,
            Locations[] memory,
            string memory,
            string memory,
            bool,
            string memory
        )
    {
        address depot = qrcodeidToDepotAddress[uniqueID];
        address refinery = qrcodeidToRefineryAddress[uniqueID];
        Biomass memory DepotToRefinery = depotToRefinerySupplyChain[uniqueID][depot][refinery];

        return (
            DepotToRefinery.biomassType,
            DepotToRefinery.originCity,
            DepotToRefinery.destinationCity,
            DepotToRefinery.currentLocation,
            DepotToRefinery.OriginLocation,
            DepotToRefinery.DestinationLocation,
            DepotToRefinery.reachedDestination,
            "Depot to Refinery"
        );
    }
}

import VenezuelaNFT_18 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new LocationCard struct 
// and stores it in the VenezuelaNFT_18 smart contract

// Parameters:
//
// region: string representing the region this Location belongs to
// type: string representing the type of influence this card exercises
// generation: UInt32 representing the amount of Influence Points generated per day when equipped
// regionalGeneration: UInt32 representing the amount of Development Points generated per day when equipped
// cardNarratives: a dictionary representing the Card's narrative effect when adopted by the Region
// proposals: we currently stringify the proposals metadata and insert it into the 
// transaction string, but want to use transaction arguments soon

transaction(
    name: String,
    region: String,
    description: String,
    bonusType: String,
    influencePointsGeneration: UInt32,
    regionalGeneration: UInt32,
    cardNarratives: {UInt32: String},
    proposal_1_name: String,
    proposal_1_effect: UInt32,
    proposal_1_duration: UFix64,
    proposal_1_adoptionRequirement: UInt32,
    ipfsCID: String,
    imagePath: String
) {
    let Administrator: &VenezuelaNFT_18.Administrator
    let locationProposals: [VenezuelaNFT_18.LocationProposal]
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_18.Administrator>(from: VenezuelaNFT_18.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_18.nextCardID
        self.locationProposals = []
        let locationStruct = VenezuelaNFT_18.LocationProposal(
            proposalName: proposal_1_name,
            effect: proposal_1_effect,
            duration: proposal_1_duration,
            adoptionRequirement: proposal_1_adoptionRequirement,
        )
        self.locationProposals.append(locationStruct)
    }

    execute {
        let newCardID = self.Administrator.createLocationCard(
            name: name,
            region: region,
            description: description,
            bonusType: bonusType,
            influencePointsGeneration: influencePointsGeneration,
            regionalGeneration: regionalGeneration,
            cardNarratives: cardNarratives,
            proposals: self.locationProposals,
            ipfsCID: ipfsCID,
            imagePath: imagePath
            )
    }
    post {
           
    }
}
import VenezuelaNFT from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new LocationCard struct 
// and stores it in the VenezuelaNFT smart contract

// Parameters:
//
// region: string representing the region this Location belongs to
// type: string representing the type of influence this card exercises
// generation: UInt32 representing the amount of Influence Points generated per day when equipped
// regionalGeneration: UInt32 representing the amount of Development Points generated per day when equipped
// cardNarratives: a dictionary representing the Card's narrative effect when adopted by the Region
// proposals: we currently stringify the proposals metadata and insert it into the 
// transaction string, but want to use transaction arguments soon

transaction() {
    let Administrator: &VenezuelaNFT.Administrator
    let locationProposals: [VenezuelaNFT.LocationProposal]
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT.Administrator>(from: VenezuelaNFT.AdminStoragePath)!
        self.currentCardId = VenezuelaNFT.nextCardID
        self.locationProposals = []
        let locationStruct = VenezuelaNFT.LocationProposal(
            proposalName: "Scholarship Program",
            effect: 10,
            duration: 7.0,
            adoptionRequirement: 30,
        )
        self.locationProposals.append(locationStruct)
    }

    execute {
        let newCardID = self.Administrator.createLocationCard(
            region: "Maracay",
            name: "Central Maracay University",
            type: "Educational",
            generation: 15,
            regionalGeneration: 100,
            cardNarratives: {80: "UCV consolidates as Maracay's intellectual heart", 60: "The university sets the rhythm of Maracay’s life"},
            proposals: self.locationProposals
            )
    }
    post {
           
    }
}
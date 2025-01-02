import VenezuelaNFT_13 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT_13 smart contract



transaction(
    name: String,
    description: String,
    influencePointsGeneration: UInt32,
    votingEffect: {String: UInt32},
    specialEffect: {String: UInt32},
    type: String,
    cardNarratives: {UInt32: String},
    image: String,
    ipfsCID: String
    ) {

    let Administrator: &VenezuelaNFT_13.Administrator
    let culturalItemEffects: VenezuelaNFT_13.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_13.Administrator>(from: VenezuelaNFT_13.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_13.nextCardID

        self.culturalItemEffects = VenezuelaNFT_13.CulturalItemEffects(
            votingEffect: votingEffect,
            specialEffect: specialEffect
        )

    }

    execute {
        let newCardID = self.Administrator.createCulturalItemCard(
            name: name,
            description: description,
            type: type,
            influencePointsGeneration: influencePointsGeneration,
            cardNarratives: cardNarratives,
            specialEffects: self.culturalItemEffects,
            image: image,
            ipfsCID: ipfsCID
        )
    }
    post {
           
    }
}
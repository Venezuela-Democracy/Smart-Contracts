import VenezuelaNFT_5 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT_5 smart contract



transaction(
    name: String,
    votingEffect: {String: UInt32},
    specialEffect: {String: UInt32},
    type: String,
    influencePointsGeneration: UInt32,
    cardNarratives: {UInt32: String},
    ) {

    let Administrator: &VenezuelaNFT_5.Administrator
    let culturalItemEffects: VenezuelaNFT_5.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_5.Administrator>(from: VenezuelaNFT_5.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_5.nextCardID

        self.culturalItemEffects = VenezuelaNFT_5.CulturalItemEffects(
            votingEffect: votingEffect,
            specialEffect: specialEffect
        )

    }

    execute {
        let newCardID = self.Administrator.createCulturalItemCard(
            name: name,
            type: type,
            influencePointsGeneration: influencePointsGeneration,
            cardNarratives: cardNarratives,
            specialEffects: self.culturalItemEffects
        )
    }
    post {
           
    }
}
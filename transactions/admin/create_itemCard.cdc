import VenezuelaNFT_4 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT_4 smart contract



transaction(
    name: String,
    votingEffect: {String: UInt32},
    specialEffect: {String: UInt32},
    type: String,
    influencePointsGeneration: UInt32,
    cardNarratives: {UInt32: String},
    ) {

    let Administrator: &VenezuelaNFT_4.Administrator
    let culturalItemEffects: VenezuelaNFT_4.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_4.Administrator>(from: VenezuelaNFT_4.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_4.nextCardID

        self.culturalItemEffects = VenezuelaNFT_4.CulturalItemEffects(
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
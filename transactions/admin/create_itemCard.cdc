import VenezuelaNFT from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT smart contract



transaction(
    name: String,
    votingEffect: {String: UInt32},
    specialEffect: {String: UInt32},
    type: String,
    influencePointsGeneration: UInt32,
    cardNarratives: {UInt32: String},
    ) {

    let Administrator: &VenezuelaNFT.Administrator
    let culturalItemEffects: VenezuelaNFT.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT.Administrator>(from: VenezuelaNFT.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT.nextCardID

        self.culturalItemEffects = VenezuelaNFT.CulturalItemEffects(
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
import VenezuelaNFT_18 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT_18 smart contract



transaction(
    name: String,
    description: String,
    influencePointsGeneration: UInt32,
    votingEffect: {String: UInt32},
    specialEffect: {String: UInt32},
    bonusType: String,
    cardNarratives: {UInt32: String},
    image: String,
    ipfsCID: String
    ) {

    let Administrator: &VenezuelaNFT_18.Administrator
    let culturalItemEffects: VenezuelaNFT_18.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_18.Administrator>(from: VenezuelaNFT_18.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_18.nextCardID

        self.culturalItemEffects = VenezuelaNFT_18.CulturalItemEffects(
            votingEffect: votingEffect,
            specialEffect: specialEffect
        )

    }

    execute {
        let newCardID = self.Administrator.createCulturalItemCard(
            name: name,
            description: description,
            bonusType: bonusType,
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
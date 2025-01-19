import VenezuelaNFT_19 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT_19 smart contract



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

    let Administrator: &VenezuelaNFT_19.Administrator
    let culturalItemEffects: VenezuelaNFT_19.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_19.Administrator>(from: VenezuelaNFT_19.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_19.nextCardID

        self.culturalItemEffects = VenezuelaNFT_19.CulturalItemEffects(
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
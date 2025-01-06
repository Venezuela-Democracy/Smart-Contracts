import VenezuelaNFT_14 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new CulturalItemCard struct 
// and stores it in the VenezuelaNFT_14 smart contract



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

    let Administrator: &VenezuelaNFT_14.Administrator
    let culturalItemEffects: VenezuelaNFT_14.CulturalItemEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_14.Administrator>(from: VenezuelaNFT_14.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_14.nextCardID

        self.culturalItemEffects = VenezuelaNFT_14.CulturalItemEffects(
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
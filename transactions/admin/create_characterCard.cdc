import VenezuelaNFT_4 from "../../contracts/VenezuelaNFT.cdc"

// This transaction creates a new LocationCard struct 
// and stores it in the VenezuelaNFT_4 smart contract

// Parameters:
//
// region: string representing the region this Location belongs to
// type: string representing the type of influence this card exercises
// generation: UInt32 representing the amount of Influence Points generated per day when equipped
// regionalGeneration: UInt32 representing the amount of Development Points generated per day when equipped
// cardNarratives: a dictionary representing the Card's narrative effect when adopted by the Region
// PresidentEffects: we currently stringify the PresidentEffects metadata and insert it into the 
// transaction string, but want to use transaction arguments soon

transaction(
    name: String,
    characterTypes: [String],
    influencePointsGeneration: UInt32,
    launchCost: UInt32,
    effectCostReduction: {String: UInt32},
    developmentEffect: {String: UInt32},
    bonusEffect: {String: UInt32}?,
    cardNarratives: {UInt32: String}) {

    let Administrator: &VenezuelaNFT_4.Administrator
    let presidentEffects: VenezuelaNFT_4.PresidentEffects
    let currentCardId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_4.Administrator>(from: VenezuelaNFT_4.AdministratorStoragePath)!
        self.currentCardId = VenezuelaNFT_4.nextCardID

        self.presidentEffects = VenezuelaNFT_4.PresidentEffects(
            effectCostReduction: effectCostReduction,
            developmentEffect: developmentEffect,
            bonusEffect: bonusEffect
        )

    }

    execute {
        let newCardID = self.Administrator.createCharacterCard(
            name: name,
            characterTypes: characterTypes,
            influencePointsGeneration: influencePointsGeneration,
            launchCost: launchCost,
            presidentEffects: self.presidentEffects,
            cardNarratives: cardNarratives)
    }
    post {
           
    }
}
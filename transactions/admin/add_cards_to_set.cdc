import VenezuelaNFT_19 from "../../contracts/VenezuelaNFT.cdc"

// This transaction adds multiple cards to a set
		
// Parameters:
//
// setID: the ID of the set to which multiple cards are added
// cards: an array of card IDs being added to the set

transaction(setID: UInt32, cards: [UInt32], cardRarities: [String]) {

    let Administrator: &VenezuelaNFT_19.Administrator
    let cardTypes: [Type]
    let setRef: &VenezuelaNFT_19.Set
    var cardStructs: [{ UInt32: Type}]
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_19.Administrator>(from: VenezuelaNFT_19.AdministratorStoragePath)!
        // borrow a reference to the set to be added to
        self.setRef = self.Administrator.borrowSet(setID: setID)
        self.cardStructs = []
        self.cardTypes = []

        for id in cards {
            let type = VenezuelaNFT_19.getCardType(cardID: id)
            self.cardStructs.append({id : type})
        }
    }

    execute {


        // Add the specified card IDs
        let returned = self.setRef.addCards(cardStructs: self.cardStructs, rarities: cardRarities)
    }
}
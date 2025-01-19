import VenezuelaNFT_19 from "../../contracts/VenezuelaNFT.cdc"

// This transaction adds multiple cards to a set
		
// Parameters:
//
// setID: the ID of the set to which multiple cards are added
// cards: an array of card IDs being added to the set

transaction(setID: UInt32, cardID: UInt32, cardRarity: String) {

    let Administrator: &VenezuelaNFT_19.Administrator
    let cardType: Type
    let setRef: &VenezuelaNFT_19.Set
    var cardStruct: { UInt32: Type} 
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_19.Administrator>(from: VenezuelaNFT_19.AdministratorStoragePath)!
        self.cardStruct = {}
        // borrow a reference to the set to be added to
        self.setRef = self.Administrator.borrowSet(setID: setID)
        self.cardType = VenezuelaNFT_19.getCardType(cardID: cardID)
        self.cardStruct[cardID] = self.cardType
    }

    execute {

        // Add the specified card IDs
        let returned = self.setRef.addCard(cardStruct: self.cardStruct, cardRarity: cardRarity)
    }
}
import VenezuelaNFT_16 from "../../contracts/VenezuelaNFT.cdc"

// This transaction adds multiple cards to a set
		
// Parameters:
//
// setID: the ID of the set to which multiple cards are added
// cards: an array of card IDs being added to the set

transaction(setID: UInt32, cardID: UInt32) {

    let Administrator: &VenezuelaNFT_16.Administrator
    let cardType: Type
    let setRef: &VenezuelaNFT_16.Set
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_16.Administrator>(from: VenezuelaNFT_16.AdministratorStoragePath)!

        // borrow a reference to the set to be added to
        self.setRef = self.Administrator.borrowSet(setID: setID)
        self.cardType = VenezuelaNFT_16.getCardType(cardID: cardID)
    }

    execute {

        // Add the specified card IDs
        let returned = self.setRef.addCard(cardID: cardID, cardType: self.cardType)
    }
}
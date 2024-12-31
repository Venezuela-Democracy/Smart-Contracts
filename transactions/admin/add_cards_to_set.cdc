import VenezuelaNFT_4 from "../../contracts/VenezuelaNFT.cdc"

// This transaction adds multiple cards to a set
		
// Parameters:
//
// setID: the ID of the set to which multiple cards are added
// cards: an array of card IDs being added to the set

transaction(setID: UInt32, cards: [UInt32]) {

    let Administrator: &VenezuelaNFT_4.Administrator
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_4.Administrator>(from: VenezuelaNFT_4.AdministratorStoragePath)!
    }

    execute {

        // borrow a reference to the set to be added to
        let setRef = self.Administrator.borrowSet(setID: setID)

        // Add the specified card IDs
        let returned = setRef.addCards(cardIDs: cards)
    }
}
import VenezuelaNFT_15 from "../../contracts/VenezuelaNFT.cdc"

// This transaction adds multiple cards to a set
		
// Parameters:
//
// setID: the ID of the set to which multiple cards are added
// cards: an array of card IDs being added to the set

transaction(setID: UInt32, cards: [UInt32]) {

    let Administrator: &VenezuelaNFT_15.Administrator
    let cardTypes: [Type]
    let setRef: &VenezuelaNFT_15.Set
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_15.Administrator>(from: VenezuelaNFT_15.AdministratorStoragePath)!

        // borrow a reference to the set to be added to
         self.setRef = self.Administrator.borrowSet(setID: setID)
         self.cardTypes = []

         for id in cards {
            let type = VenezuelaNFT_15.getCardType(cardID: id)
            self.cardTypes.append(type)
         }

    }

    execute {


        // Add the specified card IDs
        let returned = self.setRef.addCards(cardIDs: cards, cardTypes: self.cardTypes)
    }
}
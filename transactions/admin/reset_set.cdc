import VenezuelaNFT_18 from "../../contracts/VenezuelaNFT.cdc"

// This transaction resets a set to add cards again

transaction(setID: UInt32) {

    let Administrator: &VenezuelaNFT_18.Administrator
    let setRef: &VenezuelaNFT_18.Set
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_18.Administrator>(from: VenezuelaNFT_18.AdministratorStoragePath)!

        // borrow a reference to the set to be added to
        self.setRef = self.Administrator.borrowSet(setID: setID)
        
    }

    execute {

        // Add the specified card IDs
        let returned = self.setRef.resetSet()
    }
}
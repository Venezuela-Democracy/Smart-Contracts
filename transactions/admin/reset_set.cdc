import VenezuelaNFT_16 from "../../contracts/VenezuelaNFT.cdc"

// This transaction resets a set to add cards again

transaction(setID: UInt32) {

    let Administrator: &VenezuelaNFT_16.Administrator
    let setRef: &VenezuelaNFT_16.Set
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_16.Administrator>(from: VenezuelaNFT_16.AdministratorStoragePath)!

        // borrow a reference to the set to be added to
        self.setRef = self.Administrator.borrowSet(setID: setID)
        
    }

    execute {

        // Add the specified card IDs
        let returned = self.setRef.resetSet()
    }
}
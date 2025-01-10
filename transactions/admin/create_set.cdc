import VenezuelaNFT_15 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_15 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_15.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_15.Administrator>(from: VenezuelaNFT_15.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_15.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
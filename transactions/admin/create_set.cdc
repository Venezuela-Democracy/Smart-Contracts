import VenezuelaNFT_17 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_17 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_17.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_17.Administrator>(from: VenezuelaNFT_17.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_17.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
import VenezuelaNFT_9 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_9 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_9.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_9.Administrator>(from: VenezuelaNFT_9.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_9.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
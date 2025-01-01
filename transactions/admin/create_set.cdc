import VenezuelaNFT_5 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_5 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_5.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_5.Administrator>(from: VenezuelaNFT_5.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_5.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
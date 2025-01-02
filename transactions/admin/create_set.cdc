import VenezuelaNFT_13 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_13 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_13.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_13.Administrator>(from: VenezuelaNFT_13.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_13.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
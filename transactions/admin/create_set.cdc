import VenezuelaNFT_14 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_14 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_14.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_14.Administrator>(from: VenezuelaNFT_14.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_14.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
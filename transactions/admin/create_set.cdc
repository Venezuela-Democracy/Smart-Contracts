import VenezuelaNFT_7 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_7 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_7.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_7.Administrator>(from: VenezuelaNFT_7.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_7.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
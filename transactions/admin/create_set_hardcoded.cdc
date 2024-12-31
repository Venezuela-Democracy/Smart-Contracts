import VenezuelaNFT from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT.Administrator>(from: VenezuelaNFT.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
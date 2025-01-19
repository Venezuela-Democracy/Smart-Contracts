import VenezuelaNFT_19 from "../../contracts/VenezuelaNFT.cdc"

// This transaction is for the admin to create a new set resource
// and store it in the VenezuelaNFT_19 smart contract

transaction(setName: String) {

    let Administrator: &VenezuelaNFT_19.Administrator
    let currentSetId: UInt32
    
    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&VenezuelaNFT_19.Administrator>(from: VenezuelaNFT_19.AdministratorStoragePath)!
        self.currentSetId = VenezuelaNFT_19.nextSetID
    }

    execute {
        let newCardID = self.Administrator.createSet(name: setName)
    }
    post {
           
    }
}
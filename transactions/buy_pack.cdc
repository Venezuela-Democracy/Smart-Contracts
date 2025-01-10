import VenezuelaNFT_15 from "../contracts/VenezuelaNFT.cdc"

// This transaction is what a citizen would use to mint a single new card 
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_15.ReceiptStorage>(from: VenezuelaNFT_15.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        
        // Commit my bet and get a receipt
        let receipt <- VenezuelaNFT_15.buyPack(setID: setID)
        
        // Check that I don't already have a receiptStorage
        if signer.storage.type(at: VenezuelaNFT_15.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_15.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_15.ReceiptStoragePath)
        }

        // Save that receipt to my storage
        storageRef.deposit(receipt: <- receipt)
    }
}
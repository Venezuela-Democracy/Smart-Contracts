import VenezuelaNFT_13 from "../contracts/VenezuelaNFT.cdc"

// This transaction is what a citizen would use to mint a single new card 
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_13.ReceiptStorage>(from: VenezuelaNFT_13.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        
        // Commit my bet and get a receipt
        let receipt <- VenezuelaNFT_13.buyPack(setID: setID)
        
        // Check that I don't already have a receiptStorage
        if signer.storage.type(at: VenezuelaNFT_13.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_13.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_13.ReceiptStoragePath)
        }

        // Save that receipt to my storage
        storageRef.deposit(receipt: <- receipt)
    }
}
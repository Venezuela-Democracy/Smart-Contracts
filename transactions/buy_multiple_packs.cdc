import VenezuelaNFT_14 from "../contracts/VenezuelaNFT.cdc"

// This transaction is what a citizen would use to mint a single new card 
// and deposit it in their collection

transaction(setID: UInt32, amount: Int) {

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        if signer.storage.type(at: VenezuelaNFT_14.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_14.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_14.ReceiptStoragePath)
        }
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_14.ReceiptStorage>(from: VenezuelaNFT_14.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        
        var counter = 0

        while counter <= amount {
            
            // Commit my bet and get a receipt
            let receipt <- VenezuelaNFT_14.buyPack(setID: setID)

            // Save that receipt to my storage
            storageRef.deposit(receipt: <- receipt)

            counter = counter + 1
        }
    }
}
import VenezuelaNFT from "../contracts/VenezuelaNFT.cdc"

// This transaction is what a citizen would use to mint a single new moment
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        // Commit my bet and get a receipt
        let receipt <- VenezuelaNFT.buyPack(setID: setID)
        
        // Check that I don't already have a receipt stored
        if signer.storage.type(at: VenezuelaNFT.ReceiptStoragePath) != nil {
            panic("Storage collision at path=".concat(VenezuelaNFT.ReceiptStoragePath.toString()).concat(" a Receipt is already stored!"))
        }

        // Save that receipt to my storage
        // Note: production systems would consider handling path collisions
        signer.storage.save(<-receipt, to: VenezuelaNFT.ReceiptStoragePath)
    }
}
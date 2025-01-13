import VenezuelaNFT_16 from "../contracts/VenezuelaNFT.cdc"
import "FlowToken"
import "FungibleToken"

// This transaction is what a citizen would use to mint a single new card 
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        // Get a reference to the signer's stored vault
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("The signer does not store a FlowToken Vault object at the path "
                    .concat("/storage/flowTokenVault. ")
                    .concat("The signer must initialize their account with this vault first!"))


        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_16.ReceiptStorage>(from: VenezuelaNFT_16.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        
        // Commit my bet and get a receipt
        let receipt <- VenezuelaNFT_16.buyPackFlow(setID: setID, payment: <- vaultRef.withdraw(amount: 1.0))
        
        // Check that I don't already have a receiptStorage
        if signer.storage.type(at: VenezuelaNFT_16.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_16.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_16.ReceiptStoragePath)
        }

        // Save that receipt to my storage
        storageRef.deposit(receipt: <- receipt)
    }
}
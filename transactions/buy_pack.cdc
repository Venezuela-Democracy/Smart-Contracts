import VenezuelaNFT_19 from "../contracts/VenezuelaNFT.cdc"
import "FlowToken"
import "FungibleToken"

// This transaction is what a citizen would use to mint a single new card 
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, SaveValue) &Account) {
        if signer.storage.type(at: VenezuelaNFT_19.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_19.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_19.ReceiptStoragePath)
        }
        // Get a reference to the signer's stored vault
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("The signer does not store a FlowToken Vault object at the path "
                    .concat("/storage/flowTokenVault. ")
                    .concat("The signer must initialize their account with this vault first!"))


        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_19.ReceiptStorage>(from: VenezuelaNFT_19.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        
        // Commit my bet and get a receipt
        let receipt <- VenezuelaNFT_19.buyPackFlow(setID: setID, payment: <- vaultRef.withdraw(amount: 1.0))

        // Save that receipt to my storage
        storageRef.deposit(receipt: <- receipt)
    }
}
import VenezuelaNFT_14 from "../contracts/VenezuelaNFT.cdc"


/// Retrieves the saved Receipt and redeems it to reveal the cards
///
transaction(amount: Int) {

    prepare(signer: auth(BorrowValue, LoadValue) &Account) {
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_14.ReceiptStorage>(from: VenezuelaNFT_14.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")


        var counter = 0
        
        while counter <= amount {
            // Load my receipt from storage
            let receipt <- storageRef.withdraw()

            // Reveal by redeeming my receipt - fingers crossed!
            VenezuelaNFT_14.revealPack(receipt: <- receipt, minter: signer.address, emptyDict: {})

            counter = counter + 1
        }
    }
}
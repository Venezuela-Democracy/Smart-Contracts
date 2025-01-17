import VenezuelaNFT_17 from "../contracts/VenezuelaNFT.cdc"


/// Retrieves the saved Receipt and redeems it to reveal the cards
///
transaction {

    prepare(signer: auth(BorrowValue, LoadValue) &Account) {
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_17.ReceiptStorage>(from: VenezuelaNFT_17.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        // Load my receipt from storage
        let receipt <- storageRef.withdraw()
/*         let receipt <- signer.storage.load<@VenezuelaNFT_17.Receipt>(from: VenezuelaNFT_17.ReceiptStoragePath)
            ?? panic("No Receipt found in storage at path=".concat(VenezuelaNFT_17.ReceiptStoragePath.toString())) */

        // Reveal by redeeming my receipt - fingers crossed!
        VenezuelaNFT_17.revealPack(receipt: <- receipt, minter: signer.address, emptyDict: {})

    }
}
import VenezuelaNFT_19 from "../contracts/VenezuelaNFT.cdc"


/// Retrieves the saved Receipt and redeems it to reveal the cards
///
transaction {

    prepare(signer: auth(BorrowValue, LoadValue) &Account) {
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_19.ReceiptStorage>(from: VenezuelaNFT_19.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        // Load my receipt from storage
        let receipt <- storageRef.withdraw()
/*         let receipt <- signer.storage.load<@VenezuelaNFT_19.Receipt>(from: VenezuelaNFT_19.ReceiptStoragePath)
            ?? panic("No Receipt found in storage at path=".concat(VenezuelaNFT_19.ReceiptStoragePath.toString())) */

        // Reveal by redeeming my receipt - fingers crossed!
        VenezuelaNFT_19.revealPack(receipt: <- receipt, minter: signer.address, emptyDict: {})

    }
}
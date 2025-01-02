import VenezuelaNFT_9 from "../contracts/VenezuelaNFT.cdc"


/// Retrieves the saved Receipt and redeems it to reveal the coin toss result, depositing winnings with any luck
///
transaction {

    prepare(signer: auth(BorrowValue, LoadValue) &Account) {
        let receiverRef = signer.capabilities.borrow<&{VenezuelaNFT_9.VenezuelaNFT_9CollectionPublic}>(VenezuelaNFT_9.CollectionPublicPath)
            ?? panic("Cannot borrow a reference to the recipient's moment collection")
        // Load my receipt from storage
        let receipt <- signer.storage.load<@VenezuelaNFT_9.Receipt>(from: VenezuelaNFT_9.ReceiptStoragePath)
            ?? panic("No Receipt found in storage at path=".concat(VenezuelaNFT_9.ReceiptStoragePath.toString()))

        // Reveal by redeeming my receipt - fingers crossed!
        VenezuelaNFT_9.revealPack(receipt: <- receipt, minter: signer.address, emptyDict: {})

    }
}
import VenezuelaNFT_7 from "../contracts/VenezuelaNFT.cdc"


/// Retrieves the saved Receipt and redeems it to reveal the coin toss result, depositing winnings with any luck
///
transaction {

    prepare(signer: auth(BorrowValue, LoadValue) &Account) {
        let receiverRef = signer.capabilities.borrow<&{VenezuelaNFT_7.VenezuelaNFT_7CollectionPublic}>(VenezuelaNFT_7.CollectionPublicPath)
            ?? panic("Cannot borrow a reference to the recipient's moment collection")
        // Load my receipt from storage
        let receipt <- signer.storage.load<@VenezuelaNFT_7.Receipt>(from: VenezuelaNFT_7.ReceiptStoragePath)
            ?? panic("No Receipt found in storage at path=".concat(VenezuelaNFT_7.ReceiptStoragePath.toString()))

        // Reveal by redeeming my receipt - fingers crossed!
        VenezuelaNFT_7.revealPack(receipt: <- receipt, minter: signer.address, emptyDict: {})

    }
}
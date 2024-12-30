import VenezuelaNFT from "../contracts/VenezuelaNFT.cdc"


/// Retrieves the saved Receipt and redeems it to reveal the coin toss result, depositing winnings with any luck
///
transaction {

    prepare(signer: auth(BorrowValue, LoadValue) &Account) {
        let receiverRef = signer.capabilities.borrow<&{VenezuelaNFT.VenezuelaNFTCollectionPublic}>(VenezuelaNFT.CollectionPublicPath)
            ?? panic("Cannot borrow a reference to the recipient's moment collection")
        // Load my receipt from storage
        let receipt <- signer.storage.load<@VenezuelaNFT.Receipt>(from: VenezuelaNFT.ReceiptStoragePath)
            ?? panic("No Receipt found in storage at path=".concat(VenezuelaNFT.ReceiptStoragePath.toString()))

        // Reveal by redeeming my receipt - fingers crossed!
        VenezuelaNFT.revealPack(receipt: <- receipt, minter: signer.address)

    }
}
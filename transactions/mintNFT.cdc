import VenezuelaNFT from "../contracts/VenezuelaNFT.cdc"

// This transaction is what a citizen would use to mint a single new moment
// and deposit it in their collection

transaction(setID: UInt32, cardID: UInt32) {

    let address: Address

    prepare(signer: &Account) {
        self.address = signer.address
    }

    execute {
        // Mint NFT
        VenezuelaNFT.mintNFT(cardID: cardID, setID: setID, minter: self.address)
    }
}
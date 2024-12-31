import VenezuelaNFT from "../contracts/VenezuelaNFT.cdc"
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

// This transaction is what a citizen would use to mint a single new moment
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        let collectionData = VenezuelaNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Return early if the account already has a collection
        if signer.storage.borrow<&VenezuelaNFT.Collection>(from: collectionData.storagePath) != nil {
            return
        }
        // Create a new empty collection
        let collection <- VenezuelaNFT.createEmptyCollection(nftType: Type<@VenezuelaNFT.NFT>())

        // save it to the account
        signer.storage.save(<-collection, to: collectionData.storagePath)

        // the old "unlink"
        let oldLink = signer.capabilities.unpublish(collectionData.publicPath)
        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&VenezuelaNFT.Collection>(collectionData.storagePath)
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
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
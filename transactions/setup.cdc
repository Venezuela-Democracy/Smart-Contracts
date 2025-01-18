import VenezuelaNFT_18 from "../contracts/VenezuelaNFT.cdc"
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"


transaction {
    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {

        let collectionData = VenezuelaNFT_18.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Return early if the account already has a collection
        if signer.storage.borrow<&VenezuelaNFT_18.Collection>(from: collectionData.storagePath) != nil {
            return
        }
        // Create a new empty collection
        let collection <- VenezuelaNFT_18.createEmptyCollection(nftType: Type<@VenezuelaNFT_18.NFT>())

        // save it to the account
        signer.storage.save(<-collection, to: collectionData.storagePath)

        // the old "unlink"
        let oldLink = signer.capabilities.unpublish(collectionData.publicPath)
        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&VenezuelaNFT_18.Collection>(collectionData.storagePath)
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
    }
}
import VenezuelaNFT_14 from "../contracts/VenezuelaNFT.cdc"
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

// This transaction is what a citizen would use to mint a single new moment
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        let collectionData = VenezuelaNFT_14.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Return early if the account already has a collection
        if signer.storage.borrow<&VenezuelaNFT_14.Collection>(from: collectionData.storagePath) != nil {
            return
        }
        // Create a new empty collection
        let collection <- VenezuelaNFT_14.createEmptyCollection(nftType: Type<@VenezuelaNFT_14.NFT>())

        // save it to the account
        signer.storage.save(<-collection, to: collectionData.storagePath)

        // the old "unlink"
        let oldLink = signer.capabilities.unpublish(collectionData.publicPath)
        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&VenezuelaNFT_14.Collection>(collectionData.storagePath)
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_14.ReceiptStorage>(from: VenezuelaNFT_14.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        // Buy pack and get a receipt
        let receipt <- VenezuelaNFT_14.buyPack(setID: setID)
        
        // Check that I don't already have a receiptStorage
        if signer.storage.type(at: VenezuelaNFT_14.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_14.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_14.ReceiptStoragePath)
        }

        // Save that receipt to my storage
        storageRef.deposit(receipt: <- receipt)
    }
}
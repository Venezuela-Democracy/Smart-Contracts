import VenezuelaNFT_18 from "../contracts/VenezuelaNFT.cdc"
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import "FlowToken"
import "FungibleToken"
// This transaction is what a citizen would use to mint a single new moment
// and deposit it in their collection

transaction(setID: UInt32) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        let collectionData = VenezuelaNFT_18.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Return early if the account already has a collection
        if signer.storage.borrow<&VenezuelaNFT_18.Collection>(from: collectionData.storagePath) != nil {
            return
        }

                // Get a reference to the signer's stored vault
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("The signer does not store a FlowToken Vault object at the path "
                    .concat("/storage/flowTokenVault. ")
                    .concat("The signer must initialize their account with this vault first!"))
        
        // Create a new empty collection
        let collection <- VenezuelaNFT_18.createEmptyCollection(nftType: Type<@VenezuelaNFT_18.NFT>())

        // save it to the account
        signer.storage.save(<-collection, to: collectionData.storagePath)

        // the old "unlink"
        let oldLink = signer.capabilities.unpublish(collectionData.publicPath)
        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&VenezuelaNFT_18.Collection>(collectionData.storagePath)
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
        // get ref to ReceiptStorage
        let storageRef = signer.storage.borrow<&VenezuelaNFT_18.ReceiptStorage>(from: VenezuelaNFT_18.ReceiptStoragePath)
            ?? panic("Cannot borrow a reference to the recipient's VenezuelaNFT ReceiptStorage")
        // Buy pack and get a receipt
        let receipt <- VenezuelaNFT_18.buyPackFlow(setID: setID, payment: <- vaultRef.withdraw(amount: 1.0))
        
        // Check that I don't already have a receiptStorage
        if signer.storage.type(at: VenezuelaNFT_18.ReceiptStoragePath) == nil {
            let storage <- VenezuelaNFT_18.createEmptyStorage()
            signer.storage.save(<- storage, to: VenezuelaNFT_18.ReceiptStoragePath)
        }

        // Save that receipt to my storage
        storageRef.deposit(receipt: <- receipt)
    }
}
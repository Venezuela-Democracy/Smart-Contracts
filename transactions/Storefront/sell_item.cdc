import "FlowToken"
import "FungibleToken"
import "NonFungibleToken"
import "MetadataViews"
import "NFTStorefront"
import VenezuelaNFT_18 from "../../contracts/VenezuelaNFT.cdc"

/// Transaction used to facilitate the creation of the listing under the signer's owned storefront resource.
/// It accepts the certain details from the signer,i.e. - 
///
/// `saleItemID` - ID of the NFT that is put on sale by the seller.
/// `saleItemPrice` - Amount of tokens (FT) buyer needs to pay for the purchase of listed NFT.
/// `customID` - Optional string to represent identifier of the dapp.
/// `commissionAmount` - Commission amount that will be taken away by the purchase facilitator.
/// `expiry` - Unix timestamp at which created listing become expired.
/// `marketplacesAddress` - List of addresses that are allowed to get the commission.

/// If the given nft has a support of the RoyaltyView then royalties will added as the sale cut.

transaction(
    saleItemID: UInt64,
    saleItemPrice: UFix64,
    customID: String?,
    commissionAmount: UFix64,
    marketplacesAddress: [Address]
) {
    
    let tokenReceiver: Capability<&{FungibleToken.Receiver}>
    let VenezuelaNFTProvider: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>
    let storefront: auth(NFTStorefront.CreateListing) &NFTStorefront.Storefront
    var saleCuts: [NFTStorefront.SaleCut]
    var marketplacesCapability: [Capability<&{FungibleToken.Receiver}>]

    prepare(acct: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        self.saleCuts = []
        self.marketplacesCapability = []

        let collectionData = VenezuelaNFT_18.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // Receiver for the sale cut.
        self.tokenReceiver = acct.capabilities.get<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        assert(self.tokenReceiver.borrow() != nil, message: "Missing or mis-typed FlowToken receiver")

        self.VenezuelaNFTProvider = acct.capabilities.storage.issue<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                collectionData.storagePath
            )
        assert(self.VenezuelaNFTProvider.check(), message: "Missing or mis-typed VenezuelaNFT provider")

        let collection = acct.capabilities.borrow<&{NonFungibleToken.Collection}>(
                collectionData.publicPath
            ) ?? panic("Could not borrow a reference to the signer's collection")

        var totalRoyaltyCut = 0.0
        let effectiveSaleItemPrice = saleItemPrice - commissionAmount
        let nft = collection.borrowNFT(saleItemID)!
        // Check whether the NFT implements the MetadataResolver or not.
        if nft.getViews().contains(Type<MetadataViews.Royalties>()) {
            let royaltiesRef = nft.resolveView(Type<MetadataViews.Royalties>())?? panic("Unable to retrieve the royalties")
            let royalties = (royaltiesRef as! MetadataViews.Royalties).getRoyalties()
            for royalty in royalties {
                // TODO - Verify the type of the vault and it should exists
                self.saleCuts.append(
                    NFTStorefront.SaleCut(
                        receiver: royalty.receiver,
                        amount: royalty.cut * effectiveSaleItemPrice
                    )
                )
                totalRoyaltyCut = totalRoyaltyCut + (royalty.cut * effectiveSaleItemPrice)
            }
        }
        // Append the cut for the seller.
        self.saleCuts.append(
            NFTStorefront.SaleCut(
                receiver: self.tokenReceiver,
                amount: effectiveSaleItemPrice - totalRoyaltyCut
            )
        )

        self.storefront = acct.storage.borrow<auth(NFTStorefront.CreateListing) &NFTStorefront.Storefront>(
                from: NFTStorefront.StorefrontStoragePath
            ) ?? panic("Missing or mis-typed NFTStorefront Storefront")

        for marketplace in marketplacesAddress {
            // Here we are making a fair assumption that all given addresses would have
            // the capability to receive the `FlowToken`
            self.marketplacesCapability.append(
                getAccount(marketplace).capabilities.get<&{FungibleToken.Receiver}>(/public/FlowTokenReceiver)
            )
        }
    }

    execute {
        // Create listing
        let listingID = self.storefront.createListing(
            nftProviderCapability: self.VenezuelaNFTProvider,
            nftType: Type<@VenezuelaNFT_18.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: self.saleCuts,
        )
    }
}
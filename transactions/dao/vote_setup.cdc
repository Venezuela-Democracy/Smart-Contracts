// This transaction is a transaction to allow
// anyone to add a Vault resource to their account so that
// they can use the InfluencePoint and Vote

import "InfluencePoint"
import "FungibleToken"
import "ViewResolver"
import "FungibleTokenMetadataViews"
import "Governance"

transaction (topicID: UInt64, option: String) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {

        let vaultData = InfluencePoint.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
            ?? panic("Could not resolve FTVaultData view. The InfluencePoint"
                .concat(" contract needs to implement the FTVaultData Metadata view in order to execute this transaction."))

        // Create a IP vault if it doesn't already stores a InfluencePoint Vault
        if signer.storage.borrow<&InfluencePoint.Vault>(from: vaultData.storagePath) == nil {
            let vault <- InfluencePoint.createEmptyVault(vaultType: Type<@InfluencePoint.Vault>())
            // Create a new InfluencePoint Vault and put it in storage
            signer.storage.save(<-vault, to: vaultData.storagePath)
            // Create a public capability to the Vault that exposes the Vault interfaces
            let vaultCap = signer.capabilities.storage.issue<&InfluencePoint.Vault>(
                vaultData.storagePath
            )
            signer.capabilities.publish(vaultCap, at: vaultData.metadataPath)

            // Create a public Capability to the Vault's Receiver functionality
            let receiverCap = signer.capabilities.storage.issue<&InfluencePoint.Vault>(
                vaultData.storagePath
            )
            signer.capabilities.publish(receiverCap, at: vaultData.receiverPath)
        }

        // submit the vote
        Governance.vote(topicID: topicID, account: signer.address, option: option)
    }
}
// This transaction is a template for a transaction to allow
// anyone to add a Vault resource to their account so that
// they can use the InfluencePoint

import InfluencePoint from "../../contracts/InfluencePoint.cdc"
import "FungibleToken"
import "ViewResolver"
import "FungibleTokenMetadataViews"

transaction () {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {

        let vaultData = InfluencePoint.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
            ?? panic("Could not resolve FTVaultData view. The InfluencePoint"
                .concat(" contract needs to implement the FTVaultData Metadata view in order to execute this transaction."))

        // Return early if the account already stores a InfluencePoint Vault
        if signer.storage.borrow<&InfluencePoint.Vault>(from: vaultData.storagePath) != nil {
            return
        }

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
}
// This script reads the balance field
// of an account's InfluencePoint Balance

import "FungibleToken"
import "InfluencePoint"
import "FungibleTokenMetadataViews"

access(all) fun main(address: Address): UFix64 {
    let vaultData = InfluencePoint.resolveContractView(resourceType: nil, viewType: Type<FungibleTokenMetadataViews.FTVaultData>()) as! FungibleTokenMetadataViews.FTVaultData?
        ?? panic("Could not resolve FTVaultData view. The InfluencePoint"
            .concat(" contract needs to implement the FTVaultData Metadata view in order to execute this transaction."))

    return getAccount(address).capabilities.borrow<&{FungibleToken.Balance}>(
            vaultData.metadataPath
        )?.balance
        ?? panic("Could not borrow a balance reference to the FungibleToken Vault in account "
                .concat(address.toString()).concat(" at path ").concat(vaultData.metadataPath.toString())
                .concat(". Make sure you are querying an address that has ")
                .concat("a FungibleToken Vault set up properly at the specified path."))
}
import VenezuelaNFT_16 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_16

access(all) fun main(cardID: UInt32): VenezuelaNFT_16.CulturalItemCard {

    return VenezuelaNFT_16.getItemMetaData(cardID: cardID)!
}
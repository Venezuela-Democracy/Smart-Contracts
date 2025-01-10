import VenezuelaNFT_15 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_15

access(all) fun main(cardID: UInt32): VenezuelaNFT_15.CulturalItemCard {

    return VenezuelaNFT_15.getItemMetaData(cardID: cardID)!
}
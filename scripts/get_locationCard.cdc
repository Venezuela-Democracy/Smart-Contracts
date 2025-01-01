import VenezuelaNFT_5 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_5

access(all) fun main(cardID: UInt32): AnyStruct? {

    return VenezuelaNFT_5.getLocationMetaData(cardID: cardID)
}
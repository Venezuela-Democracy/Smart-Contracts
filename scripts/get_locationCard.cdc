import VenezuelaNFT_9 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_9

access(all) fun main(cardID: UInt32): AnyStruct? {

    return VenezuelaNFT_9.getLocationMetaData(cardID: cardID)
}
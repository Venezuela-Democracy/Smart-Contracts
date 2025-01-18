import VenezuelaNFT_18 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_18

access(all) fun main(cardID: UInt32): Type {

    return VenezuelaNFT_18.getCardType(cardID: cardID)
    
}
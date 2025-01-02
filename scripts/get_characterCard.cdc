import VenezuelaNFT_13 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_13

access(all) fun main(cardID: UInt32): VenezuelaNFT_13.CharacterCard {

    return VenezuelaNFT_13.getCharacterMetaData(cardID: cardID)!
}
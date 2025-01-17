import VenezuelaNFT_17 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_17

access(all) fun main(cardID: UInt32): VenezuelaNFT_17.CharacterCard {

    return VenezuelaNFT_17.getCharacterMetaData(cardID: cardID)!
}
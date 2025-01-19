import VenezuelaNFT_19 from "../contracts/VenezuelaNFT.cdc"

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [AnyStruct]
// array of all plays created for VenezuelaNFT_19

access(all) fun main(cardID: UInt32): VenezuelaNFT_19.CharacterCard {

    return VenezuelaNFT_19.getCharacterMetaData(cardID: cardID)!
}
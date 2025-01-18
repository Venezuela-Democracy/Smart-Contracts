import VenezuelaNFT_18 from "../contracts/VenezuelaNFT.cdc"
import MetadataViews from "MetadataViews"

access(all) fun main(account: Address): [AnyStruct]?  {

    let account = getAccount(account)
    let answer: [AnyStruct]  = []
    var nft: AnyStruct = nil

        
    let cap = account.capabilities.borrow<&VenezuelaNFT_18.Collection>(VenezuelaNFT_18.CollectionPublicPath)!
    log(cap)

    let ids = cap.getIDs()


    for id in ids {
        // Ref to the VenezuelaNFT to get the Card's metadata
        let nftRef = cap.borrowVenezuelaNFT(id: id)!
        let resolver = cap.borrowViewResolver(id: id)!
        let displayView: MetadataViews.Display = MetadataViews.getDisplay(resolver)!
        let serialView = MetadataViews.getSerial(resolver)!
        let traits = MetadataViews.getTraits(resolver)!
        let cardType = VenezuelaNFT_18.getCardType(cardID: UInt32(id))

        nft = {
        "cardMetadataID": nftRef.cardID,
        "display": displayView,
        "nftID": nftRef.id,
        "serial": serialView,
        "traits": traits,
        "type": cardType
        }
        
        answer.append(nft
        )
    }
    return answer 
}
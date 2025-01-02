import VenezuelaNFT_13 from "../contracts/VenezuelaNFT.cdc"
import MetadataViews from "MetadataViews"

access(all) fun main(account: Address): [AnyStruct]?  {

    let account = getAccount(account)
    let answer: [AnyStruct]  = []
    var nft: AnyStruct = nil

        
    let cap = account.capabilities.borrow<&VenezuelaNFT_13.Collection>(VenezuelaNFT_13.CollectionPublicPath)!
    log(cap)

    let ids = cap.getIDs()

    for id in ids {
        let resolver = cap.borrowViewResolver(id: id)!
        let displayView: MetadataViews.Display = MetadataViews.getDisplay(resolver)!
        let serialView = MetadataViews.getSerial(resolver)!
        let traits = MetadataViews.getTraits(resolver)!
        let cardType = VenezuelaNFT_13.getCardType(cardID: UInt32(id))

        nft = {
        "nftId": id,
        "serial": serialView,
        "display": displayView,
        "traits": traits,
        "type": cardType
        }
        
        answer.append(nft
        )
    }
    return answer 
}
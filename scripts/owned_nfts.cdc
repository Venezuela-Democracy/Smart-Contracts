import VenezuelaNFT_14 from "../contracts/VenezuelaNFT.cdc"
import MetadataViews from "MetadataViews"

access(all) fun main(account: Address): [AnyStruct]?  {

    let account = getAccount(account)
    let answer: [AnyStruct]  = []
    var nft: AnyStruct = nil

        
    let cap = account.capabilities.borrow<&VenezuelaNFT_14.Collection>(VenezuelaNFT_14.CollectionPublicPath)!
    log(cap)

    let ids = cap.getIDs()


    for id in ids {
        let nftRef = cap.borrowVenezuelaNFT(id: id)!
        let resolver = cap.borrowViewResolver(id: id)!
        let displayView: MetadataViews.Display = MetadataViews.getDisplay(resolver)!
        let serialView = MetadataViews.getSerial(resolver)!
        let traits = MetadataViews.getTraits(resolver)!
        let cardType = VenezuelaNFT_14.getCardType(cardID: UInt32(id))

        nft = {
        "nftId": id,
        "serial": serialView,
        "display": displayView,
        "traits": traits,
        "type": cardType,
        "cardID": nftRef.cardID
        }
        
        answer.append(nft
        )
    }
    return answer 
}
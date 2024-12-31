import VenezuelaNFT from "VenezuelaNFT"
import MetadataViews from "MetadataViews"

access(all) fun main(account: Address): [AnyStruct]?  {

    let account = getAccount(account)
    let answer: [AnyStruct]  = []
    var nft: AnyStruct = nil

        
    let cap = account.capabilities.borrow<&VenezuelaNFT.Collection>(VenezuelaNFT.CollectionPublicPath)!
    log(cap)

    let ids = cap.getIDs()

    for id in ids {
        let resolver = cap.borrowViewResolver(id: id)!
        let displayView: MetadataViews.Display = MetadataViews.getDisplay(resolver)!
        let serialView = MetadataViews.getSerial(resolver)!

        nft = {
        "nftId": id,
        "serial": serialView,
        "display": displayView
        }
        
        answer.append(nft
        )
    }
    return answer 
}
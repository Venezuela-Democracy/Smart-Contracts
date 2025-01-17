import VenezuelaNFT_17 from "../contracts/VenezuelaNFT.cdc"


access(all) fun main(account: Address): Int {
    let account = getAccount(account)
    var packs = 0

    let cap = account.capabilities.borrow<&VenezuelaNFT_17.ReceiptStorage>(VenezuelaNFT_17.ReceiptStoragePublic)!

    packs = cap.getBalance()
    
    return packs
}
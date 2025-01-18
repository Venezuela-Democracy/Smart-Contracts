import VenezuelaNFT_18 from "../contracts/VenezuelaNFT.cdc"


access(all) fun main(account: Address): Int {
    let account = getAccount(account)
    var packs = 0

    let cap = account.capabilities.borrow<&VenezuelaNFT_18.ReceiptStorage>(VenezuelaNFT_18.ReceiptStoragePublic)!

    packs = cap.getBalance()

    return packs
}
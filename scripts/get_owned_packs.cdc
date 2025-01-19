import VenezuelaNFT_19 from "../contracts/VenezuelaNFT.cdc"


access(all) fun main(account: Address): Int {
    let account = getAccount(account)
    var packs = 0

    let cap = account.capabilities.borrow<&VenezuelaNFT_19.ReceiptStorage>(VenezuelaNFT_19.ReceiptStoragePublic)!

    packs = cap.getBalance()

    return packs
}
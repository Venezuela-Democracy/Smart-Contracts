import Governance from "../../contracts/Governance.cdc"

transaction(option: String) {

    prepare(signer: &Account) {

        Governance.vote(account: signer.address, option: option)
    }

}

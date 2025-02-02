import "Governance"

transaction(topicID: UInt64, option: String) {

    prepare(signer: &Account) {

        Governance.vote(topicID: topicID, account: signer.address, option: option)
    }

}

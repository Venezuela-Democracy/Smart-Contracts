import "Governance"

transaction(title: String, description: String, minimumVotes: Int, options: [String]) {

    let Administrator: &Governance.Administrator

    prepare(deployer: auth(BorrowValue) &Account) {
        self.Administrator = deployer.storage.borrow<&Governance.Administrator>(from: Governance.AdministratorStoragePath)!

    }

    execute {
        self.Administrator.createTopic(title: title, description: description, minimumVotes: minimumVotes, options: options)
    }
} 
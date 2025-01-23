import "InfluencePoint"
import "DevelopmentPoint"

access(all) contract Governance {

    access(all) let topics: [Topic]
    // -----------------------------------------------------------------------
    // Venezuela_Governance account paths
    // -----------------------------------------------------------------------
    
    access(all) let TopicsStoragePath: StoragePath
	access(all) let TopicsPublicPath: PublicPath


    access(all) struct Topic {

        access(all) let title: String
        access(all) let description: String
        access(all) let minimumVote: Int
        access(all) let options: [String]
        access(all) let votes: {String: Int}
        access(all) let listVoters: {String: Bool}
        access(all) var endAt: UFix64

        init(
            title: String,
            description: String,
            minimumVote: Int,
            options: [String],
            votes: {String: Int}
            ) {
            self.title = title
            self.description = description
            self.minimumVote = minimumVote
            self.options = options
            self.votes = votes
            self.listVoters = {}
            self.endAt = getCurrentBlock().timestamp + 86400.0 * 14.0
        }

        access(self) view fun hasVoted(account: Address): Bool {

            if self.listVoters[account.toString()] != nil {
                return true
            }
            return false
        }
        access(all) fun vote(account: Address, option: String) {
            pre {
                self.hasVoted(account: account) != nil: "This account has already voted"
                self.votes[option] == nil: "This is not an option for this vote"
            }

            self.votes[option] = self.votes[option]! + 1
        }
    }

    access(all) fun vote(account: Address, option: String) {
        let topicRef = self.topics[0] 
        topicRef.vote(account: account, option: option)
    }

    init() {
        self.topics = []

        let identifier = "Venezuela_Governance".concat(self.account.address.toString())
        self.TopicsStoragePath = StoragePath(identifier: identifier.concat("_Topics"))!
		self.TopicsPublicPath = PublicPath(identifier: identifier.concat("_Topics"))!
    }
}
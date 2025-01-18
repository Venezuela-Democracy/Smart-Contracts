import InfluencePoint from "./InfluencePoint.cdc"

access(all) contract Governance {

    access(all) let topics: [Topic]
    
    access(all) struct Topic {

        access(all) let title: String
        access(all) let description: String
        access(all) let minimumVote: Int
        access(all) let options: [String]
        access(all) let votes: {String: Int}
        access(all) let listVoters: {String: Bool}
        access(all) var endAt: UFix64

        init() {
            self.title = "Next Region"
            self.description = "We're voting to select the next region to be integrated."
            self.minimumVote = 3
            self.options = []
            self.options.append("Barinas")
            self.options.append("Amazonas")
            self.votes = {}
            self.votes["Barinas"] = 0
            self.votes["Amazonas"] = 0
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

        let topic =  Topic()
        self.topics.append(topic)
    }
}
import "InfluencePoint"
import "DevelopmentPoint"

access(all) contract Governance {
    // -----------------------------------------------------------------------
    // Venezuela_Governance contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------
    // The ID that is used to create Topics. 
    // Every time a Topic is created, topicID is assigned 
    // to the new Topic's ID and then is incremented by 1.
    access(all) var nextTopicID: UInt64


    access(all) let topics: [Topic]

    // -----------------------------------------------------------------------
    // Venezuela_Governance account paths
    // -----------------------------------------------------------------------
    
    access(all) let TopicStoragePath: StoragePath
	access(all) let TopicPublicPath: PublicPath

    // -----------------------------------------------------------------------
    // Venezuela_Governance contract-level Composite Type definitions
    // -----------------------------------------------------------------------

    /// Defines the methods that are particular to the Topics storage
    ///
    access(all) resource interface TopicStoragePublic {
        access(all) view fun getTopic(topicID: UInt64): Topic
    }
    // Set is a resource type that contains the functions to add and remove
    // Cards from a set and mint VenezuelaNFT_19s.
    //
	access(all) resource TopicStorage: TopicStoragePublic {
		// List of Creator 
		access(all) var topicsIDs: {UInt64: Topic}

        init() {
            self.topicsIDs = {}
        }
        // function to Get a Topic
        access(all)
        view fun getTopic(topicID: UInt64): Topic {
            pre {
                self.topicsIDs[topicID] != nil: "This topicID doesn't belong to any Topic in the list"
            }

            let topic = self.topicsIDs[topicID]!
            return topic
        }
        // function to add a Topic to the list
        access(all)
        fun addTopic(topic: Topic) {
            pre {
                self.topicsIDs[topic.id] != nil: "This Topic is already in the list"
            }
            self.topicsIDs[topic.id] = topic
        }
        // function to Vote on the Topic
        access(all)
        fun vote(account: Address, topicID: UInt64, option: String) {
            pre {
                self.topicsIDs[topicID]!.hasVoted(account: account)
                self.topicsIDs[topicID]!.votes[option] == nil: "This is not an option for this vote"
            }

            self.topicsIDs[topicID]!.vote(account: account, option: option)
        }
    }

    access(all) struct Topic {

        access(all) let id: UInt64
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
            self.id = Governance.nextTopicID
            self.title = title
            self.description = description
            self.minimumVote = minimumVote
            self.options = options
            self.votes = votes
            self.listVoters = {}
            self.endAt = getCurrentBlock().timestamp + 86400.0 * 14.0

            Governance.nextTopicID = Governance.nextTopicID + 1
        }

        access(account) view fun hasVoted(account: Address): Bool {

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
        self.nextTopicID = 1

        let identifier = "Venezuela_Governance".concat(self.account.address.toString())
        self.TopicStoragePath = StoragePath(identifier: identifier.concat("_Topics"))!
		self.TopicPublicPath = PublicPath(identifier: identifier.concat("_Topics"))!
    }
}
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


    // access(all) let topics: {UInt64: Topic}

    // -----------------------------------------------------------------------
    // Venezuela_Governance account paths
    // -----------------------------------------------------------------------
    
    access(all) let TopicStoragePath: StoragePath
	access(all) let TopicPublicPath: PublicPath
	access(all) let AdministratorStoragePath: StoragePath
    // -----------------------------------------------------------------------
    // Venezuela_Governance contract Events
    // -----------------------------------------------------------------------
    access(all) event ContractInitialized()
    access(all) event NewTopic(topicID: UInt64, topicTitle: String, minimumVotes: Int, endAt: UFix64)
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
        // function to get All Topics
        access(all)
        view fun getTopics(): {UInt64: Governance.Topic} {
            return self.topicsIDs
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
                self.topicsIDs[topic.id] == nil: "This Topic is already in the list"
            }
            self.topicsIDs[topic.id] = topic
        }
        // function to Vote on the Topic
        access(all)
        fun vote(account: Address, topicID: UInt64, option: String) {
            pre {
                self.topicsIDs[topicID]!.hasVoted(account: account) != true: "This account has already voted"
                self.topicsIDs[topicID]!.votes[option] != nil: "This is not an option for this vote"
            }

            self.topicsIDs[topicID]!.vote(account: account, option: option)
        }
    }

    access(all) struct Topic {
        // Unique identifier for each Topic
        access(all) let id: UInt64
        // Topic's title
        access(all) let title: String
        // Topic's description
        access(all) let description: String
        // Minimnum amount of votes to pass this Topic
        access(all) let minimumVotes: Int
        // Vote options
        access(all) let options: [String]
        // Amount of votes for each option
        access(all) let votes: {String: Int}
        // Dictionary of all voters
        // get list with listVoters.keys
        access(all) let listVoters: {String: Bool}
        // End date for the voting round
        access(all) var endAt: UFix64

        init(
            _ title: String,
            _ description: String,
            _ minimumVote: Int,
            _ options: [String]) {
            self.id = Governance.nextTopicID
            self.title = title
            self.description = description
            self.minimumVotes = minimumVote
            self.options = options
            self.listVoters = {}
            self.endAt = getCurrentBlock().timestamp + 86400.0 * 14.0
            self.votes = {}

            var counter = 0
            while counter < options.length {
                self.votes[options[counter]] = 0
                counter = counter + 1
            }
            // Increase nextTopic ID
            Governance.nextTopicID = Governance.nextTopicID + 1
            // Emit New Topic event
            emit NewTopic(topicID: self.id, topicTitle: self.title,  minimumVotes: self.minimumVotes, endAt: self.endAt)
        }

        access(account) view fun hasVoted(account: Address): Bool {
            if self.listVoters[account.toString()] != nil {
                return true
            }
            return false
        }
        access(all) fun vote(account: Address, option: String) {
            pre {
                self.hasVoted(account: account) != true: "This account has already voted"
                self.votes[option] != nil: "This is not an option for this vote"
            }

            self.votes[option] = self.votes[option]! + 1
        }
    }

    // -----------------------------------------------------------------------
    // Venezuela_Governance Administrator Resource
    // -----------------------------------------------------------------------
    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the DAO, like creating and magaging Topics
    //
    access(all) resource Administrator {
        // createTopic creates a new Topic struct 
        // and stores it in the TopicStorage resource inside the Venezuela_Governance account
        //
        // Returns: the ID of the new Topic object
        //
        access(all) 
        fun createTopic(
            title: String,
            description: String,
            minimumVotes: Int,
            options: [String]) {
                // Load the TopicStorage from the Venezuela account
                let topicStorage = Governance.account.storage.borrow<&Governance.TopicStorage>(from: Governance.TopicStoragePath)!
                // Create the Topic struct
                let topic = Topic(title, description, minimumVotes, options)
                // add Topic to the Storage
                let topicID = topicStorage.addTopic(topic: topic)
            }
    }

    // -----------------------------------------------------------------------
    // Governance public functions
    // -----------------------------------------------------------------------
    // Public function to get list of Topics
    access(all) view fun getTopics(): {UInt64: Topic} {
        // Load the TopicStorage from the Venezuela account
        let topicStorage = Governance.account.storage.borrow<&Governance.TopicStorage>(from: Governance.TopicStoragePath)!
        // get topics
        let topics = topicStorage.getTopics()
        // return topics
        return topics
    }
    access(all) fun vote(topicID: UInt64, account: Address, option: String) {
/*         pre {
            self.topics[topicID] == nil: "This Topic doesn't exists"
        } */
        // Get ref to the Topic
        let topicStorage = Governance.account.storage.borrow<&Governance.TopicStorage>(from: Governance.TopicStoragePath)!
        // Submit vote 
        topicStorage.vote(account: account, topicID: topicID, option: option)
    }

    init() {
//        self.topics = {}
        self.nextTopicID = 1

        let identifier = "Venezuela_Governance".concat(self.account.address.toString())
        self.TopicStoragePath = StoragePath(identifier: identifier.concat("_Topics"))!
		self.TopicPublicPath = PublicPath(identifier: identifier.concat("_Topics"))!
		self.AdministratorStoragePath = StoragePath(identifier: identifier.concat("Administrator"))!

    	// Create a Administrator resource and save it to Venezuela account storage
		let administrator <- create Administrator()
		self.account.storage.save(<- administrator, to: self.AdministratorStoragePath)
    	// Create a TopicStorage resource and save it to Venezuela account storage
		let topicStorage <- create TopicStorage()
		self.account.storage.save(<- topicStorage, to: self.TopicStoragePath)

        // Emit contract init event
		emit ContractInitialized()
    }
}
import "FlowToken"
import "FungibleToken"
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"

access(all)
contract VenezuelaNFT {
    // -----------------------------------------------------------------------
    // VenezuelaNFT contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------

    // A struct containing all the information related to the contract
	access(self) let collectionInfo: {String: AnyStruct}
    // Season is a concept that indicates a group of Sets through time.
    // Many Sets can exist at a time, but only one Season.
    access(all) var currentSeason: UInt32
    // Variable size dictionary of SetData structs
    access(self) var setDatas: {UInt32: SetData}
    // The total number of NFTs that have been created
    // Because NFTs can be destroyed, it doesn't necessarily mean that this
    // reflects the total number of NFTs in existence, just the number that
    // have been minted to date. 
    access(all) var totalSupply: UInt64
    // The ID that is used to create Cards. 
    // Every time a Card is created, cardID is assigned 
    // to the new Card's ID and then is incremented by 1.
    access(all) var nextCardID: UInt32
    // The ID that is used to create Sets. Every time a Set is created
    // setID is assigned to the new set's ID and then is incremented by 1.
    access(all) var nextSetID: UInt32

    // -----------------------------------------------------------------------
    // VenezuelaNFT contract Events
    // -----------------------------------------------------------------------

    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
	access(all) event Deposit(id: UInt64, to: Address?)
	access(all) event Minted(id: UInt64, serial: UInt64, recipient: Address, creatorID: UInt64)

    // -----------------------------------------------------------------------
    // VenezuelaNFT account paths
    // -----------------------------------------------------------------------

	access(all) let CollectionStoragePath: StoragePath
	access(all) let CollectionPublicPath: PublicPath
	access(all) let CollectionPrivatePath: PrivatePath
	access(all) let AdministratorStoragePath: StoragePath

    // -----------------------------------------------------------------------
    // VenezuelaNFT contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------

    // Card is a Struct that holds metadata associated 
    // with a specific VenezuelaNFT Card
    // VenezuelaNFTs will all reference a single Card as the owner of
    // its metadata. The Cards are publicly accessible, so anyone can
    // read the metadata associated with a specific Card ID
    //
    access(all) struct Card {

        // The unique ID for the Card
        access(all) let cardID: UInt32

        // Stores all the metadata about the Card as a string mapping
        access(all) let metadata: {String: String}

        init(metadata: {String: String}) {
            pre {
                metadata.length != 0: "New Card metadata cannot be empty"
            }
            self.cardID = VenezuelaNFT.nextCardID
            self.metadata = metadata
        }

        /// This function is intended to backfill the Card on blockchain with a more detailed
        /// description of the Card. The benefit of having the description is that anyone would
        /// be able to know the story of the Card directly from Flow
        access(contract) fun updateTagline(tagline: String): UInt32 {
            self.metadata["Tagline"] = tagline

            // VenezuelaNFT.cardsDatas[self.CardID] = self
            return self.cardID
        }
    }

    // A Set is a grouping of Cards that make up a related group of collectibles
    // like sets of baseball or Magic cards. 
    // A Card can exist in multiple different sets.

    // SetData is a struct that is stored in a field of the contract.
    // Anyone can query the constant information
    // about a set by calling various getters located 
    // at the end of the contract. Only the admin has the ability 
    // to modify any data in the private Set resource.
    //
    access(all) struct SetData {
        // Unique ID for the Set
        access(all) let setID: UInt32
        // Name of the Set
        // ex. "Base set or Venezuela National Parks"
        access(all) let name: String

        // Season that this Set belongs to.
        // Season is a concept that indicates a group of Sets through time.
        // Many Sets can exist at a time, but only one Season.
        access(all) let season: UInt32

        init(name: String) {
            pre {
                name.length > 0: "New Set name cannot be empty"
            }
            self.setID = VenezuelaNFT.nextSetID
            self.name = name
            self.season = VenezuelaNFT.currentSeason
        }
    }

    // NonFungibleToken

    // CollectionResource

    // Administrator

    // Public functions

    // ViewResolver

    // Init

    init() {
        let identifier = "VenezuelaNFT_".concat(self.account.address.toString())
        self.collectionInfo = {}
        self.setDatas = {}
        self.totalSupply = 0
        self.currentSeason = 0
        self.nextCardID = 0
        self.nextSetID = 0
		// Set the named paths
		self.CollectionStoragePath = StoragePath(identifier: identifier)!
		self.CollectionPublicPath = PublicPath(identifier: identifier)!
		self.CollectionPrivatePath = PrivatePath(identifier: identifier)!
		self.AdministratorStoragePath = StoragePath(identifier: identifier.concat("Administrator"))!

        // Emit contract init event
		emit ContractInitialized()
    }
}
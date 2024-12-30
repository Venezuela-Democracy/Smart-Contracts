import "FlowToken"
import "FungibleToken"
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"

access(all)
contract VenezuelaNFT: NonFungibleToken, ViewResolver {
    // -----------------------------------------------------------------------
    // VenezuelaNFT contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------

    // A struct containing all the information related to the contract
	access(self) let collectionInfo: {String: AnyStruct}
    // Variable size dictionary of LocationCard structs
    access(self) var locationCardDatas: {UInt32: LocationCard}
    // Variable size dictionary of CharacterCard structs
    access(self) var characterCardDatas: {UInt32: CharacterCard}
    // Variable size dictionary of CulturalItemCard structs
    access(self) var culturalItemCardDatas: {UInt32: CulturalItemCard}
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
    access(all) event CardCreated(cardID: UInt32, cardType: String)
	access(all) event VenezuelaNFTMinted(nftID: UInt64, cardID: UInt32, setID: UInt32, serialNumber: UInt64, recipient: Address)

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

    // Struct to store a LocationCard available proposals
    // citizens vote on proposals and the card's effects activate
    // based on the % of adoption of said proposal
    access(all) struct LocationProposal {
        // The name of the proposal
        access(all) let proposalName: String
        // The proposal's effect when adopted
        // this is usually a % increase on Development Points
        // generation during a set time
        access(all) let effect: UInt32
        // Duration of the effect
        access(all) let duration: UFix64
        // Adoption % required to be activated
        access(all) let adoptionRequirement: UInt32

        init(proposalName: String, effect: UInt32, duration: UFix64, adoptionRequirement: UInt32) {
            self.proposalName = proposalName
            self.effect = effect
            self.duration = duration
            self.adoptionRequirement = adoptionRequirement
        }
    }
    // LocationCard is a Struct that holds metadata associated 
    // with a specific VenezuelaNFT Card
    // VenezuelaNFTs will all reference a single Card as the owner of
    // its metadata. The Cards are publicly accessible, so anyone can
    // read the metadata associated with a specific Card ID
    //    
    access(all) struct LocationCard {
        // The unique ID for the Card
        access(all) let cardID: UInt32
        // The Location's region
        access(all) let region: String
        // The type of bonus this Card gives
        access(all) let type: String
        // The amount of Influence Points generated per day when equipped
        access(all) let generation: UInt32
        // The amount of Development Points generated per day when equipped
        // DP represent the region's economic
        access(all) let regionalGeneration: UInt32
        // Card's avaible proposals for the Region
        access(all) let availableProposals: [LocationProposal]
        // Card's narrative effect when adopted by the Region
        // there are different narratives depending on the % of adoption
        access(all) let cardNarratives: {UInt32: String}

        init(
            region: String,
            type: String,
            generation: UInt32,
            regionalGeneration: UInt32,
            cardNarratives: {UInt32: String},
            proposals: [LocationProposal]
            ) {
            pre {
                region.length != 0: "Location region cannot be empty"
                type.length != 0: "Location type cannot be empty"
                generation > 0: "Location generation cannot be zero or less"
                regionalGeneration > 0: "Location regional generation cannot be zero or less"
                cardNarratives != nil: "Card's narratives can't be empty"
            }
            self.cardID = VenezuelaNFT.nextCardID
            self.region = region
            self.type = type
            self.generation = generation
            self.regionalGeneration = regionalGeneration
            self.cardNarratives = cardNarratives
            self.availableProposals = proposals
        }
    }
    // Struct to store a CharacterCard effects
    // citizens vote on Character to become a region's governor
    // or the Country's President and the card's effects activate
    // when the CharacterCard is selected
    access(all) struct PresidentEffects {
        // Global cost effect
        // this affects the cost % of a specific
        // type of proposals
        // this maps proposal cost reduction % and on what type
        access(all) let effectCostReduction: {String: UInt32}
        // Development Generation % effect
        access(all) let developmentEffect: {String: UInt32}
        // Special Bonus
        // some character have an extra bonus effect when Elected
        access(all) let bonusEffect: {String: UInt32}?

        init(
            effectCostReduction: {String: UInt32},
            developmentEffect: {String: UInt32},
            bonusEffect: {String: UInt32}?
            ) {
            pre {
                effectCostReduction != nil: "Cost Effect cannot be empty"
                developmentEffect != nil: "Development Effect cannot be empty"     
            }
            self.effectCostReduction = effectCostReduction
            self.developmentEffect = developmentEffect
            self.bonusEffect = bonusEffect
        }
    }
    
    // CharacterCard is a Struct that holds metadata associated 
    // with a specific VenezuelaNFT Card
    access(all) struct CharacterCard {
        // The unique ID for the Card
        access(all) let cardID: UInt32
        // Character type
        // characters have different influence types
        // ex: Educational, Technological, etc
        // a character can belong to multiple types
        access(all) let characterTypes: [String]
        // Character Influence Points generation 
        // characters generate IP per day when equipped
        access(all) let influencePointsGeneration: UInt32
        // Character launch cost
        // it costs Development points to launch a Character
        // this represents a political campaign cost
        access(all) let launchCost: UInt32
        // Character effects as President
        access(all) let presidentEffects: PresidentEffects
        // Card's narrative effect when adopted by the Region
        // there are different narratives depending on the % of adoption
        access(all) let cardNarratives: {UInt32: String}

        init(
            characterTypes: [String],
            influencePointsGeneration: UInt32,
            launchCost: UInt32,
            presidentEffects: PresidentEffects,
            cardNarratives: {UInt32: String}
            ) {
            pre {
                characterTypes.length != 0: "Character must have at least one(1) type"
                influencePointsGeneration > 0: "IP generation must be higher than zero"
                launchCost > 0: "Launch cost  must be higher than zero"
                cardNarratives != nil: "Card's narratives can't be empty"
            }
            self.cardID = VenezuelaNFT.nextCardID
            self.characterTypes = characterTypes
            self.influencePointsGeneration = influencePointsGeneration
            self.launchCost = launchCost
            self.cardNarratives = cardNarratives
            self.presidentEffects = presidentEffects
        }
    }
    // Struct to store a CulturalItemCard effects
    // citizens vote on CulturalItems to be adopted by the region
    access(all) struct CulturalItemEffects {
        // CulturalItem effects influence your voting power
        // on certain type of proposals
        // ex: Arepas, when equipped, double your voting power 
        // in food-related proposals
        access(all) let votingEffect: {String: UInt32}

        // Special effect
        // CulturalItems have special effects that active
        // when the item has been adopted by the region
        // these effect are related to Crisis-management
        // not all items have one
        access(all) let specialEffect: {String: UInt32}
        init(
            votingEffect: {String: UInt32},
            specialEffect: {String: UInt32}
        ) {
            pre {
                votingEffect != nil: "Voting Effect cannot be empty"    
            }
            self.votingEffect = votingEffect
            self.specialEffect = specialEffect
        }
    }

    // CulturalItemCard is a Struct that holds metadata associated 
    // with a specific VenezuelaNFT Card
    access(all) struct CulturalItemCard {
        // The unique ID for the Card
        access(all) let cardID: UInt32
        // Card type defines what kind of development
        // this card influences
        access(all) let type: String
        // Card Influence Points generation per day when equipped
        access(all) let influencePointsGeneration: UInt32
        // Card's narrative effect when adopted by the Region
        // there are different narratives depending on the % of adoption
        access(all) let cardNarratives: {UInt32: String}
        // CulturalItem's special effects when equipped or 
        // adopted by the region
        access(all) let specialEffects: CulturalItemEffects
        init(
            type: String,
            influencePointsGeneration: UInt32,
            cardNarratives: {UInt32: String},
            specialEffects: CulturalItemEffects
        ) {
            pre {
                type.length > 0: "Type can't be empty"
                influencePointsGeneration > 0: "IP generation must be higher than zero"
                cardNarratives != nil: "Card's narratives can't be empty"
                specialEffects != nil: "Card's special effects can't be empty"
            }
            self.cardID = VenezuelaNFT.nextCardID
            self.type = type
            self.influencePointsGeneration = influencePointsGeneration
            self.cardNarratives = cardNarratives
            self.specialEffects = specialEffects
        }
    }

    // Metadata struct for each Card
    // this is created and used at the time of minting/revealing
    access(all) struct CardData {
        // The ID of the Set that the Card comes from
        access(all) let setID: UInt32
        // The ID of the Card that the Card references
        access(all) let cardID: UInt32
        // Address of the original minter
        access(all) let minter: Address
        // The place in the edition that this Card was minted
        access(all) let serialNumber: UInt64

        init(_ setID: UInt32,_ cardID: UInt32,_ serialNumber: UInt64,_ minter: Address) {
            self.setID = setID
            self.cardID = cardID
            self.serialNumber = serialNumber
            self.minter = minter
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
    // Set is a resource type that contains the functions to add and remove
    // Cards from a set and mint VenezuelaNFTs.
    //
    // It is stored in a private field in the contract so that
    // the admin resource can call its methods.
    //
    // The admin can add Cards to a Set so that the set can mint VenezuelaNFTs
    // that reference that metadata.
    // The VenezuelaNFTs that are minted by a Set will be listed as belonging to
    // the Set that minted it, as well as the Card it references.
    //
    // If the admin locks the Set, no more Cards can be added to it, but 
    // VenezuelaNFTs can still be minted.
    access(all) resource Set {

        // Unique ID for the set
        access(all) let setID: UInt32

        // Array of cards that are a part of this set.
        // When a Card is added to the set, its ID gets appended here.
        // The ID does not get removed from this array when a Card is retired.
        access(contract) var cards: [UInt32]

        // Indicates if the Set is currently locked.
        // When a Set is created, it is unlocked 
        // and cards are allowed to be added to it.
        // When a set is locked, cards cannot be added.
        // A Set can never be changed from locked to unlocked,
        // the decision to lock a Set it is final.
        // If a Set is locked, cards cannot be added, but
        // VenezuelaNFTs can still be minted from cards
        // that exist in the Set.
        access(all) var locked: Bool

        // Mapping of Card IDs that indicates the number of VenezuelaNFTs 
        // that have been minted for specific cards in this Set.
        // When a VenezuelaNFT is minted, this value is stored in the VenezuelaNFT to
        // show its place in the Set, eg. 13 of 60.
        access(contract) var numberMintedPerCard: {UInt32: UInt32}

        init(name: String) {
            self.setID = VenezuelaNFT.nextSetID
            self.cards = []
            self.locked = false
            self.numberMintedPerCard = {}

            // Create a new SetData for this Set and store it in contract storage
            VenezuelaNFT.setDatas[self.setID] = SetData(name: name)
        }
    }
    //
    /// The resource that represents a VenezulaNFT
	access(all) resource NFT: NonFungibleToken.NFT {
		access(all) let id: UInt64
		// The 'metadataId' is what maps this NFT to its 'NFTMetadata'
        access(all) let metadata: CardData

		init(serialNumber: UInt64, cardID: UInt32, setID: UInt32, minter: Address) {
            // Increment the global Cards IDs
            VenezuelaNFT.totalSupply = VenezuelaNFT.totalSupply + 1

            self.id = VenezuelaNFT.totalSupply
			// Set the metadata struct
			self.metadata = CardData(setID, cardID, serialNumber, minter)
            // Emit event
            emit VenezuelaNFTMinted(
                nftID: self.id,
                cardID: cardID,
                setID: self.metadata.setID,
                serialNumber: self.metadata.serialNumber,
                recipient: minter
            )
		}

/*  		access(all) fun getMetadata(): CardData {
			return self.metadata
		}  */
        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        /// @{NonFungibleToken.Collection}
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-VenezuelaNFT.createEmptyCollection(nftType: Type<@VenezuelaNFT.NFT>())
        }

		access(all) view fun getViews(): [Type] {
			return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>(),
                Type<MetadataViews.EVMBridgedMetadata>()
			]
		}

		access(all) fun resolveView(_ view: Type): AnyStruct? {
			let metadata = self.metadata
			switch view {
				case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: "Card Name",
						description: "Card Description",
						thumbnail: MetadataViews.HTTPFile( // GOTTA CHANGE
            				url: "https://media.discordapp.net/attachments/1075564743152107530/1149417271597473913/VenezuelaNFT_collection_image.png?width=1422&height=1422"
            			)
					)
				case Type<MetadataViews.Traits>():
					return MetadataViews.dictToTraits(dict: {"String": 2}, excludedNames: nil)
				case Type<MetadataViews.NFTView>():
					return MetadataViews.NFTView(
						id: self.id,
						uuid: self.uuid,
						display: self.resolveView(Type<MetadataViews.Display>()) as! MetadataViews.Display?,
						externalURL: self.resolveView(Type<MetadataViews.ExternalURL>()) as! MetadataViews.ExternalURL?,
						collectionData: self.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?,
						collectionDisplay: self.resolveView(Type<MetadataViews.NFTCollectionDisplay>()) as! MetadataViews.NFTCollectionDisplay?,
						royalties: self.resolveView(Type<MetadataViews.Royalties>()) as! MetadataViews.Royalties?,
						traits: self.resolveView(Type<MetadataViews.Traits>()) as! MetadataViews.Traits?
					)
				case Type<MetadataViews.NFTCollectionData>():
					return VenezuelaNFT.resolveContractView(resourceType: Type<@VenezuelaNFT.NFT>(), viewType: Type<MetadataViews.NFTCollectionData>())
        		case Type<MetadataViews.ExternalURL>():
        			return VenezuelaNFT.getCollectionAttribute(key: "website") as! MetadataViews.ExternalURL
		        case Type<MetadataViews.NFTCollectionDisplay>():
					return VenezuelaNFT.resolveContractView(resourceType: Type<@VenezuelaNFT.NFT>(), viewType: Type<MetadataViews.NFTCollectionDisplay>())
				case Type<MetadataViews.Medias>():
                    let metadata = 10
					if metadata != nil {
						return MetadataViews.Medias(
							[
								MetadataViews.Media(
									file: MetadataViews.HTTPFile(
										url: "metadata.embededHTML"
									),
									mediaType: "html"
								)
							]
						)
					}
        		case Type<MetadataViews.Royalties>():
          			return MetadataViews.Royalties([
            			MetadataViews.Royalty(
              				receiver: getAccount(VenezuelaNFT.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
              				cut: 0.10, // 10% royalty on secondary sales
              				description: "The creator of the original content gets 10% of every secondary sale."
            			)
          			])
				case Type<MetadataViews.Serial>():
					return MetadataViews.Serial(
						self.metadata.serialNumber
					)
			}
			return nil
		}

	}
    // CollectionResource
	access(all) resource Collection: NonFungibleToken.Collection {
        // *** Collection Variables *** //
		access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}
        // *** Collection Constructor *** //
        init () {
			self.ownedNFTs <- {}
		}
        // *** Collection Functions *** //

        /// Returns a list of NFT types that this receiver accepts
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[Type<@VenezuelaNFT.NFT>()] = true
            return supportedTypes
        }
        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@VenezuelaNFT.NFT>()
        }
		// Withdraw removes a VenezuelaNFTNFT from the collection and moves it to the caller(for Trading)
		access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
			let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("This Collection doesn't own a VenezuelaNFTNFT by id: ".concat(withdrawID.toString()))

			emit Withdraw(id: token.id, from: self.owner?.address)

			return <-token
		}
		// Deposit takes a VenezuelaNFTNFT and adds it to the collections dictionary
		// and adds the ID to the id array
		access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
			let newVenezuelaNFT <- token as! @NFT
			let id: UInt64 = newVenezuelaNFT.id
			// Add the new VenezuelaNFTNFT to the dictionary
            let oldVenezuelaNFT <- self.ownedNFTs[id] <- newVenezuelaNFT
            // Destroy old VenezuelaNFT in that slot
            destroy oldVenezuelaNFT

			emit Deposit(id: id, to: self.owner?.address)
		}

		// GetIDs returns an array of the IDs that are in the collection
		access(all) view fun getIDs(): [UInt64] {
			return self.ownedNFTs.keys
		}
        /// Gets the amount of NFTs stored in the collection
        access(all) view fun getLength(): Int {
            return self.ownedNFTs.length
        }

		// BorrowNFT gets a reference to an NFT in the collection
		access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
			return &self.ownedNFTs[id]
		}

		access(all) view fun borrowViewResolver(id: UInt64): &{ViewResolver.Resolver}? {
            if let nft = &self.ownedNFTs[id] as &{NonFungibleToken.NFT}? {
                return nft as &{ViewResolver.Resolver}
            }
            return nil
		}
        /// createEmptyCollection creates an empty Collection of the same type
        /// and returns it to the caller
        /// @return A an empty collection of the same type
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-VenezuelaNFT.createEmptyCollection(nftType: Type<@VenezuelaNFT.NFT>())
        }

        /// Gets a reference to an NFT in the collection so that 
        /// the caller can read its metadata and call its methods
        ///
        /// @param id: The ID of the wanted NFT
        /// @return A reference to the wanted NFT resource
        ///        
/*         access(all) fun borrowVenezuelaNFT(id: UInt64): &VenezuelaNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &VenezuelaNFT.NFT
            }

            return nil
        } */


/* 		access(all) fun claim() {
			if let storage = &VenezuelaNFT.nftStorage[self.owner!.address] as &{UInt64: NFT}? {
				for id in storage.keys {
					self.deposit(token: <- storage.remove(key: id)!)
				}
			}
		} */
	}

    // -----------------------------------------------------------------------
    // VenezuelaNFT Administrator Resource
    // -----------------------------------------------------------------------
    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the Cards, Sets, and Seasons
    //
    access(all) resource Administrator {
        // createLocationCard creates a new LocationCard struct 
        // and stores it in the LocationCards dictionary in the VenezuelaNFT smart contract
        //
        // Returns: the ID of the new Card object
        //
        access(all) fun createLocationCard(
            region: String,
            type: String,
            generation: UInt32,
            regionalGeneration: UInt32,
            cardNarratives: {UInt32: String},
            proposals: [LocationProposal]): UInt32 {
            // Create the new Card
            var newCard = LocationCard(
                region: region,
                type: type,
                generation: generation,
                regionalGeneration: regionalGeneration,
                cardNarratives: cardNarratives,
                proposals: proposals
            )
            let newID = newCard.cardID

            // Increment the ID so that it isn't used again
            VenezuelaNFT.nextCardID = VenezuelaNFT.nextCardID + 1
            // Store it in the contract storage
            // for LocationCards
            VenezuelaNFT.locationCardDatas[newID] = newCard
            // emit event
            emit CardCreated(cardID: newCard.cardID, cardType: "Location")

            return newID
        }
        // createCharacterCard creates a new CharacterCard struct 
        // and stores it in the CharacterCards dictionary in the VenezuelaNFT smart contract
        //
        // Returns: the ID of the new Card object
        //
        access(all) fun createCharacterCard(
            characterTypes: [String],
            influencePointsGeneration: UInt32,
            launchCost: UInt32,
            presidentEffects: PresidentEffects,
            cardNarratives: {UInt32: String}): UInt32 {
            // Create the new Card
            var newCard = CharacterCard(
                characterTypes: characterTypes,
                influencePointsGeneration: influencePointsGeneration,
                launchCost: launchCost,
                presidentEffects: presidentEffects,
                cardNarratives: cardNarratives
            )
            let newID = newCard.cardID

            // Increment the ID so that it isn't used again
            VenezuelaNFT.nextCardID = VenezuelaNFT.nextCardID + 1
            // Store it in the contract storage
            VenezuelaNFT.characterCardDatas[newID] = newCard
            // emit event
            emit CardCreated(cardID: newCard.cardID, cardType: "Character")

            return newID
        }
        // createCulturalItemCard creates a new CulturalItemCard struct 
        // and stores it in the CulturalItemCards dictionary in the VenezuelaNFT smart contract
        //
        // Returns: the ID of the new Card object
        //
        access(all) fun createCulturalItemCard(
            type: String,
            influencePointsGeneration: UInt32,
            cardNarratives: {UInt32: String},
            specialEffects: CulturalItemEffects): UInt32 {
            // Create the new Card
            var newCard = CulturalItemCard(
                type: type,
                influencePointsGeneration: influencePointsGeneration,
                cardNarratives: cardNarratives,
                specialEffects: specialEffects
            )
            let newID = newCard.cardID

            // Increment the ID so that it isn't used again
            VenezuelaNFT.nextCardID = VenezuelaNFT.nextCardID + 1
            // Store it in the contract storage
            VenezuelaNFT.culturalItemCardDatas[newID] = newCard
            // emit event
            emit CardCreated(cardID: newCard.cardID, cardType: "Cultural Item")

            return newID
        }

        access(all) fun createSet(setName: String, cardId: UInt32): UInt32 {
            return 0
        }
    }
    
    // -----------------------------------------------------------------------
    // VenezuelaNFT public functions
    // -----------------------------------------------------------------------
    /// Function that returns all the Metadata Views implemented by a Non Fungible Token
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>(),
            Type<MetadataViews.EVMBridgedMetadata>()
        ]
    }
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                let collectionData = MetadataViews.NFTCollectionData(
                    storagePath: self.CollectionStoragePath,
                    publicPath: self.CollectionPublicPath,
                    publicCollection: Type<&VenezuelaNFT.Collection>(),
                    publicLinkedType: Type<&VenezuelaNFT.Collection>(),
                    createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                        return <-VenezuelaNFT.createEmptyCollection(nftType: Type<@VenezuelaNFT.NFT>())
                    })
                )
                return collectionData
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = VenezuelaNFT.getCollectionAttribute(key: "image") as! MetadataViews.Media
                return MetadataViews.NFTCollectionDisplay(
                    name: "VenezuelaNFT",
                    description: "Sell VenezuelaNFTs of any Tweet in seconds.",
                    externalURL: MetadataViews.ExternalURL("https://VenezuelaNFT.gg/"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/CreateAVenezuelaNFT")
                    }
                )
            
/*             case Type<MetadataViews.EVMBridgedMetadata>():
                // Implementing this view gives the project control over how the bridged NFT is represented as an ERC721
                // when bridged to EVM on Flow via the public infrastructure bridge.

                // Compose the contract-level URI. In this case, the contract metadata is located on some HTTP host,
                // but it could be IPFS, S3, a data URL containing the JSON directly, etc.
                return MetadataViews.EVMBridgedMetadata(
                    name: "ExampleNFT",
                    symbol: "XMPL",
                    uri: MetadataViews.URI(
                        baseURI: nil, // setting baseURI as nil sets the given value as the uri field value
                        value: "https://example-nft.onflow.org/contract-metadata.json"
                    )
                ) */
            // case Type<MetadataViews.EVMBridgedMetadata>():
            //     return MetadataViews.EVMBridgedMetadata(
            //         name: self.name,
            //         symbol: "XMPL",
            //         uri: MetadataViews.URI(
            //             baseURI: nil,
            //             value: SerializeMetadata.serializeNFTMetadataAsURI(&self as &{NonFungibleToken.NFT})
            //         )
            //     )
        }
        return nil
    }
    /// createEmptyCollection creates an empty Collection for the specified NFT type
    /// and returns it to the caller so that they can own NFTs
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- create Collection()
    }
    // Public function to fetch a collection attribute
    access(all) fun getCollectionAttribute(key: String): AnyStruct {
		return self.collectionInfo[key] ?? panic(key.concat(" is not an attribute in this collection."))
	}

    // Init

    init() {
        let identifier = "VenezuelaNFT_".concat(self.account.address.toString())
        self.locationCardDatas = {}
        self.characterCardDatas = {}
        self.culturalItemCardDatas = {}
        self.setDatas = {}
        self.totalSupply = 0
        self.currentSeason = 0
        self.nextCardID = 0
        self.nextSetID = 0
        self.collectionInfo = {}
		self.collectionInfo["image"] = MetadataViews.Media(
            			file: MetadataViews.HTTPFile(
            				url: "https://media.discordapp.net/attachments/1075564743152107530/1149417271597473913/VenezuelaNFT_collection_image.png?width=1422&height=1422"
            			),
            			mediaType: "image/jpeg"
          			)
		// Set the named paths
		self.CollectionStoragePath = StoragePath(identifier: identifier)!
		self.CollectionPublicPath = PublicPath(identifier: identifier)!
		self.CollectionPrivatePath = PrivatePath(identifier: identifier)!
		self.AdministratorStoragePath = StoragePath(identifier: identifier.concat("Administrator"))!

		// Create a Administrator resource and save it to VenezuelaNFT account storage
		let administrator <- create Administrator()
		self.account.storage.save(<- administrator, to: self.AdministratorStoragePath)
        // Emit contract init event
		emit ContractInitialized()

    }
}
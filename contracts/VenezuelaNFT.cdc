import "FlowToken"
import "FungibleToken"
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "RandomConsumer"
import "Xorshift128plus"
import "Burner"

access(all)
contract VenezuelaNFT_19: NonFungibleToken, ViewResolver {
    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------

    // A struct containing all the information related to the contract
	access(self) let collectionInfo: {String: AnyStruct}

    access(self) var cardDatas: {UInt32: AnyStruct}

    // Variable size dictionary of Cards structs
    access(self) var locationsData: {UInt32: LocationCard}
    // Variable size dictionary of Cards structs
    access(self) var charactersData: {UInt32: CharacterCard}    
    // Variable size dictionary of Cards structs
    access(self) var culturalItemsData: {UInt32: CulturalItemCard}    
    // Variable size dictionary of cardType structs
    access(self) var cardTypes: {UInt32: Type}
    // Variable size dictionary of SetData structs
    access(self) var setDatas: {UInt32: SetData}
    // Variable size dictionary of Set resources
    access(self) var sets: @{UInt32: Set}
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
    // Season is a concept that indicates a group of Sets through time.
    // Many Sets can exist at a time, but only one Season.
    access(all) var currentSeason: UInt32
    /// The RandomConsumer.Consumer resource used to request & fulfill randomness
    access(self) let consumer: @RandomConsumer.Consumer

    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 contract Events
    // -----------------------------------------------------------------------

    access(all) event ContractInitialized()
    access(all) event Withdraw(id: UInt64, from: Address?)
	access(all) event Deposit(id: UInt64, to: Address?)
    access(all) event CardCreated(cardID: UInt32, cardType: String)
    access(all) event SetCreated(setID: UInt32, season: UInt32)
    access(all) event CardAddedToSet(setID: UInt32, cardID: UInt32)
	access(all) event BoughtPack(commitBlock: UInt64, receiptID: UInt64)
    access(all) event ReceiptDeposit(id: UInt64, to: Address?)
    access(all) event ReceiptWithdraw(id: UInt64, from: Address?)
    access(all) event PackRevealed(nftID: UInt64, cardID: UInt32, setID: UInt32, serialNumber: UInt64, recipient: Address, commitBlock: UInt64, receiptID: UInt64)
    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 account paths
    // -----------------------------------------------------------------------
	access(all) let CollectionStoragePath: StoragePath
	access(all) let CollectionPublicPath: PublicPath
	access(all) let AdministratorStoragePath: StoragePath
    /// The canonical path for common Receipt storage
    access(all) let ReceiptStoragePath: StoragePath
	access(all) let ReceiptStoragePublic: PublicPath
    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------

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
    // with a specific VenezuelaNFT_19 Card
    // VenezuelaNFT_19s will all reference a single Card as the owner of
    // its metadata. The Cards are publicly accessible, so anyone can
    // read the metadata associated with a specific Card ID
    //    
    access(all) struct LocationCard {
        // Card Type 
        access(all) let cardType: Type
        // The unique ID for the Card
        access(all) let cardID: UInt32
        // The card's name
        access(all) let name: String        
        // The card's description
        access(all) let description: String
        // The Location's region
        access(all) let region: String
        // The type of bonus this Card gives
        access(all) let bonusType: String
        // The amount of Influence Points generated per day when equipped
        access(all) let influencePointsGeneration: UInt32
        // The amount of Development Points generated per day when equipped
        // DP represent the region's economic
        access(all) let regionalGeneration: UInt32
        // Card's avaible proposals for the Region
        access(all) let availableProposals: [LocationProposal]
        // Card's narrative effect when adopted by the Region
        // there are different narratives depending on the % of adoption
        access(all) let cardNarratives: {UInt32: String}
        // The main image of the NFT
        // it's an IPFS link
        access(all) let image: String
        access(all) let ipfsCID: String

        init(
            name: String,
            region: String,
            description: String,
            bonusType: String,
            influencePointsGeneration: UInt32,
            regionalGeneration: UInt32,
            cardNarratives: {UInt32: String},
            proposals: [LocationProposal],
            image: String,
            ipfsCID: String
            ) {
            pre {
                region.length != 0: "Location region cannot be empty"
                name.length != 0: "Location name cannot be empty"
                bonusType.length != 0: "Location type cannot be empty"
                influencePointsGeneration > 0: "Location generation cannot be zero or less"
                regionalGeneration > 0: "Location regional generation cannot be zero or less"
                cardNarratives != nil: "Card's narratives can't be empty"
            }
            self.cardType = self.getType()
            self.cardID = VenezuelaNFT_19.nextCardID
            self.region = region
            self.name = name
            self.description = description
            self.bonusType = bonusType
            self.influencePointsGeneration = influencePointsGeneration
            self.regionalGeneration = regionalGeneration
            self.cardNarratives = cardNarratives
            self.availableProposals = proposals
            self.image = image
            self.ipfsCID = ipfsCID
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
    // with a specific VenezuelaNFT_19 Card
    access(all) struct CharacterCard {
        // Card Type 
        access(all) let cardType: Type
        // The unique ID for the Card
        access(all) let cardID: UInt32
        // The card's name
        access(all) let name: String
        // The card's description
        access(all) let description: String
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
        // The main image of the NFT
        // it's an IPFS link
        access(all) let image: String
        access(all) let ipfsCID: String

        init(
            name: String,
            description: String,
            characterTypes: [String],
            influencePointsGeneration: UInt32,
            launchCost: UInt32,
            presidentEffects: PresidentEffects,
            cardNarratives: {UInt32: String},
            image: String,
            ipfsCID: String
            ) {
            pre {
                name.length != 0: "Character name cannot be empty"
                characterTypes.length != 0: "Character must have at least one(1) type"
                influencePointsGeneration > 0: "IP generation must be higher than zero"
                launchCost > 0: "Launch cost  must be higher than zero"
                cardNarratives != nil: "Card's narratives can't be empty"
            }
            self.cardType = self.getType()
            self.cardID = VenezuelaNFT_19.nextCardID
            self.name = name
            self.description = description
            self.characterTypes = characterTypes
            self.influencePointsGeneration = influencePointsGeneration
            self.launchCost = launchCost
            self.cardNarratives = cardNarratives
            self.presidentEffects = presidentEffects
            self.image = image
            self.ipfsCID = ipfsCID
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
    // with a specific VenezuelaNFT_19 Card
    access(all) struct CulturalItemCard {
        // Card Type 
        access(all) let cardType: Type
        // The unique ID for the Card
        access(all) let cardID: UInt32
        // Name of the card
        access(all) let name: String
        // The card's description
        access(all) let description: String
        // Card type defines what kind of development
        // this card influences
        access(all) let bonusType: String
        // Card Influence Points generation per day when equipped
        access(all) let influencePointsGeneration: UInt32
        // Card's narrative effect when adopted by the Region
        // there are different narratives depending on the % of adoption
        access(all) let cardNarratives: {UInt32: String}
        // CulturalItem's special effects when equipped or 
        // adopted by the region
        access(all) let specialEffects: CulturalItemEffects
        // The main image of the NFT
        // it's an IPFS link
        access(all) let image: String
        access(all) let ipfsCID: String
        init(
            name: String,
            description: String,
            bonusType: String,
            influencePointsGeneration: UInt32,
            cardNarratives: {UInt32: String},
            specialEffects: CulturalItemEffects,
            image: String,
            ipfsCID: String
        ) {
            pre {
                bonusType.length > 0: "Type can't be empty"
                influencePointsGeneration > 0: "IP generation must be higher than zero"
                cardNarratives != nil: "Card's narratives can't be empty"
                specialEffects != nil: "Card's special effects can't be empty"
            }
            self.cardType = self.getType()
            self.cardID = VenezuelaNFT_19.nextCardID
            self.name = name
            self.description = description
            self.bonusType = bonusType
            self.influencePointsGeneration = influencePointsGeneration
            self.cardNarratives = cardNarratives
            self.specialEffects = specialEffects
            self.image = image
            self.ipfsCID = ipfsCID
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
            self.setID = VenezuelaNFT_19.nextSetID
            self.name = name
            self.season = VenezuelaNFT_19.currentSeason
        }
    }
    // Set is a resource type that contains the functions to add and remove
    // Cards from a set and mint VenezuelaNFT_19s.
    //
    // It is stored in a private field in the contract so that
    // the admin resource can call its methods.
    //
    // The admin can add Cards to a Set so that the set can mint VenezuelaNFT_19s
    // that reference that metadata.
    // The VenezuelaNFT_19s that are minted by a Set will be listed as belonging to
    // the Set that minted it, as well as the Card it references.
    //
    // If the admin locks the Set, no more Cards can be added to it, but 
    // VenezuelaNFT_19s can still be minted.
    access(all) resource Set {

        // Unique ID for the set
        access(all) let setID: UInt32

        // Array of cards that are a part of this set.
        // When a Card is added to the set, its ID gets appended here.
        // The ID does not get removed from this array when a Card is retired.
        // Cards are categorized by rarity
        access(contract) var cards: {String: [{UInt32: Type}]}
        // access(contract) var cards: {UInt32: Type}


        // Indicates if the Set is currently locked.
        // When a Set is created, it is unlocked 
        // and cards are allowed to be added to it.
        // When a set is locked, cards cannot be added.
        // A Set can never be changed from locked to unlocked,
        // the decision to lock a Set it is final.
        // If a Set is locked, cards cannot be added, but
        // VenezuelaNFT_19s can still be minted from cards
        // that exist in the Set.
        access(all) var locked: Bool

        // Mapping of Card IDs that indicates the number of VenezuelaNFT_19s 
        // that have been minted for specific cards in this Set.
        // When a VenezuelaNFT_19 is minted, this value is stored in the VenezuelaNFT_19 to
        // show its place in the Set, eg. 13 of 60.
        access(contract) var numberMintedPerCard: {UInt32: UInt64}

        init(name: String) {
            self.setID = VenezuelaNFT_19.nextSetID
            self.cards = {}
            self.cards["Common"] = []
            self.cards["Uncommon"] = []
            self.cards["Rare"] = []
            self.cards["Epic"] = []
            self.cards["Legendary"] = []
            self.locked = false
            self.numberMintedPerCard = {}

            // Create a new SetData for this Set and store it in contract storage
            VenezuelaNFT_19.setDatas[self.setID] = SetData(name: name)
        }
        // addCard adds a card to the set
        //
        // Parameters: cardID: The ID of the card that is being added
        //
        // Pre-Conditions:
        // The card needs to be an existing card
        // The Set needs to be not locked
        // The card can't have already been added to the Set
        //
        access(all) fun addCard(cardStruct: {UInt32: Type}, cardRarity: String) {
            pre {
                !self.locked: "Cannot add the card to the Set after the set has been locked."
                self.numberMintedPerCard[cardStruct.keys[0]] == nil: "The card has already beed added to the set."
            }

            // Add the Card to the array of Cards in the set
            self.cards[cardRarity]?.append(cardStruct)!

            // Initialize the VenezuelaNFT_19 count to zero
            self.numberMintedPerCard[cardStruct.keys[0]] = 0

            emit CardAddedToSet(setID: self.setID, cardID: cardStruct.keys[0])
        }
        // Function to return a card's type
        access(all) fun getCardType(cardSlot: UInt32, rarity: String): Type {
            let cards = self.cards[rarity]!
            let card = cards[cardSlot]
            return card.values[0]
        }
        // Function to return a card's type
        access(all) fun getCardID(cardSlot: UInt32, rarity: String): UInt32 {
            let cards = self.cards[rarity]!
            let card = cards[cardSlot]
            return card.keys[0]
        }
        // Function to return a card's type
        access(all) fun getCardRarity(cardID: UInt32): String {
            if self.cards["Common"]![cardID] != nil {
                return "Common"
            } else if self.cards["Uncommon"]![cardID] != nil {
                return "Uncommon"
            } else if self.cards["Rare"]![cardID] != nil {
                return "Rare"
            } else if self.cards["Epic"]![cardID] != nil {
                return "Epic"
            } else if self.cards["Legendary"]![cardID] != nil {
                return "Legendary"
            }
            return "This card is not in the set"
        }
        // addCards adds multiple Cards to the Set
        //
        // Parameters: cardIDs: The IDs of the Cards that are being added
        //                      as an array
        //
        access(all) fun addCards(cardStructs: [{ UInt32: Type }], rarities: [String]) {
            var counter = 0
            for i in  cardStructs{
                self.addCard(cardStruct: i, cardRarity: rarities[counter])
                counter = counter + 1
            }
        }
        // Function to increase mint count of a Card
        access(all) fun incrementCount(cardID: UInt32) {
            let currentCount = self.numberMintedPerCard[cardID]!
            self.numberMintedPerCard[cardID] = currentCount + 1
        }
        // Function to determine a card's rarity at mint
        access(all) fun determineRarity(randomNumber: UInt64): String {
            if randomNumber < 10 {
                return "Legendary"
            } else if randomNumber < 100 {
                return "Epic"
            } else if randomNumber < 1000 {
                return "Rare"
            } else if randomNumber < 5500 {
                return "Uncommon"
            }

            return "Common"
        }
        access(all) fun getCardsWithRarity(rarity: String): [{UInt32: Type}] {
            return self.cards[rarity]!
        }
        // Function to reset set
/*         access(all) fun resetSet() {
            self.cards = {}
        } */
    }
    //
    /// The resource that represents a VenezulaNFT
	access(all) resource NFT: NonFungibleToken.NFT {
        // NFT id in relation to all NFTs
		access(all) let id: UInt64
        // Card Id in relation to Metadata
		access(all) let cardID: UInt64
        access(all) let name: String
        access(all) let description: String
        access(all) let img: String
        access(all) let ipfsCID: String
        // Card Type to filter metadata
        access(all) let cardType: Type
        // Card rarity
        access(all) let rarity: String
        // Influence Points generation
        access(all) let influence_generation: UFix64
        // SetId
        access(all) let setId: UInt32
		// SerialNumber
        access(all) let serial: UInt64
        // access(all) let metadata: CardData
        access(all) let orignalMinter: Address
        

        // Return the Type of this Card
        // Could be Location, Character or CulturalItem
        access(all)
        view fun getCardType(): Type {
            return self.cardType
        }
        // Return the card as its specific struct
        // based on its card type        
        access(all) 
        view fun get_LocationCard(): VenezuelaNFT_19.LocationCard {
            return VenezuelaNFT_19.getLocationMetaData(cardID: UInt32(self.id))!
        }
        view access(all) 
        fun get_CharacterCard(): VenezuelaNFT_19.CharacterCard {
            return VenezuelaNFT_19.getCharacterMetaData(cardID: UInt32(self.id))!
        }
        view access(all) 
        fun get_CulturalItemCard(): VenezuelaNFT_19.CulturalItemCard {
            return VenezuelaNFT_19.getItemMetaData(cardID: UInt32(self.id))!
        }
        view access(all)
        fun getTraits(): {String: AnyStruct} {
            let metadata: {String: AnyStruct} = {"name": self.name}
        //    metadata["cardType"] = self.cardType
            metadata["influence_generation"] = self.influence_generation
            metadata["setId"] = self.setId
            metadata["orignalMinter"] = self.orignalMinter
            metadata["cardMetadataID"] = self.id
            metadata["nftUUID"] = self.uuid
            metadata["rarity"] = self.rarity
            metadata["serial"] = self.serial

            return metadata
        }

		init(
            cardName: String, 
            cardDescription: String,
            rarity: String,
            cardImg: String,
            ipfsCID: String,
            cardType: Type,
            cardID: UInt32,
            influencePoints: UFix64,
            serialNumber: UInt64,
            setID: UInt32,
            minter: Address,
            
            ) {
            // Increment the global Cards IDs
            VenezuelaNFT_19.totalSupply = VenezuelaNFT_19.totalSupply + 1

            self.id = VenezuelaNFT_19.totalSupply 
            self.cardID = UInt64(cardID)
            self.name = cardName
            self.rarity = rarity
            self.description = cardDescription
            self.img = cardImg
            self.ipfsCID = ipfsCID
            self.cardType = cardType
            self.influence_generation = influencePoints
            self.serial = serialNumber
            self.setId = setID
            self.orignalMinter = minter
		}

        /// createEmptyCollection creates an empty Collection
        /// and returns it to the caller so that they can own NFTs
        /// @{NonFungibleToken.Collection}
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-VenezuelaNFT_19.createEmptyCollection(nftType: Type<@VenezuelaNFT_19.NFT>())
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
            // let data = VenezuelaNFT_19.getCardMetadata(cardID: UInt32(self.id), cardType: self.cardType) as! cardType
			switch view {
				case Type<MetadataViews.Display>():
					return MetadataViews.Display(
						name: self.name,
						description:  self.description,
						thumbnail: MetadataViews.HTTPFile( 
            				url: self.img
            			),
                        
					)
				case Type<MetadataViews.Traits>():
                    let traits = self.getTraits()
					return MetadataViews.dictToTraits(dict: traits, excludedNames: nil)
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
					return VenezuelaNFT_19.resolveContractView(resourceType: Type<@VenezuelaNFT_19.NFT>(), viewType: Type<MetadataViews.NFTCollectionData>())
        		case Type<MetadataViews.ExternalURL>():
        			return VenezuelaNFT_19.getCollectionAttribute(key: "website") as! MetadataViews.ExternalURL
		        case Type<MetadataViews.NFTCollectionDisplay>():
					return VenezuelaNFT_19.resolveContractView(resourceType: Type<@VenezuelaNFT_19.NFT>(), viewType: Type<MetadataViews.NFTCollectionDisplay>())
				case Type<MetadataViews.Medias>():
                    let metadata = 10
					if metadata != nil {
						return MetadataViews.Medias(
							[
								MetadataViews.Media(
									file: MetadataViews.HTTPFile(
										url: self.img
									),
									mediaType: "jpg"
								)
							]
						)
					}
        		case Type<MetadataViews.Royalties>():
          			return MetadataViews.Royalties([
            			MetadataViews.Royalty(
              				receiver: getAccount(VenezuelaNFT_19.account.address).capabilities.get<&FlowToken.Vault>(/public/flowTokenReceiver),
              				cut: 0.5, // 5% royalty on secondary sales
              				description: "The deployer gets 5% of every secondary sale."
            			)
          			])
				case Type<MetadataViews.Serial>():
					return MetadataViews.Serial(
						self.serial
					)
			}
			return nil
		}

	}
    // to allow others to deposit VenezuelaNFT_19s into their Collection. It also allows for reading
    // the IDs of VenezuelaNFT_19s in the Collection.
    /// Defines the methods that are particular to this NFT contract collection
    ///
    access(all) resource interface VenezuelaNFT_19CollectionPublic {
        access(all) fun deposit(token: @{NonFungibleToken.NFT})
        access(all) fun getIDs(): [UInt64]
    //    access(all) fun getCardType(): Type
    }


    // Collection is a resource that every user who owns NFTs 
    // will store in their account to manage their NFTS
    //
	access(all) resource Collection: NonFungibleToken.Collection, VenezuelaNFT_19CollectionPublic {
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
            supportedTypes[Type<@VenezuelaNFT_19.NFT>()] = true
            return supportedTypes
        }
        /// Returns whether or not the given type is accepted by the collection
        /// A collection that can accept any type should just return true by default
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@VenezuelaNFT_19.NFT>()
        }
		// Withdraw removes a VenezuelaNFT_19NFT from the collection and moves it to the caller(for Trading)
		access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
			let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("This Collection doesn't own a VenezuelaNFT_19NFT by id: ".concat(withdrawID.toString()))

			emit Withdraw(id: token.id, from: self.owner?.address)

			return <-token
		}
		// Deposit takes a VenezuelaNFT_19NFT and adds it to the collections dictionary
		// and adds the ID to the id array
		access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
			let newVenezuelaNFT_19 <- token as! @NFT
			let id: UInt64 = newVenezuelaNFT_19.id
			// Add the new VenezuelaNFT_19NFT to the dictionary
            let oldVenezuelaNFT_19 <- self.ownedNFTs[id] <- newVenezuelaNFT_19
            // Destroy old VenezuelaNFT_19 in that slot
            destroy oldVenezuelaNFT_19

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
		// BorrowNFT gets a reference to an NFT in the collection
        access(all) fun borrowVenezuelaNFT(id: UInt64): &VenezuelaNFT_19.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as  &{NonFungibleToken.NFT}?)!
                return ref as! &VenezuelaNFT_19.NFT
            }

            return nil
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
            return <-VenezuelaNFT_19.createEmptyCollection(nftType: Type<@VenezuelaNFT_19.NFT>())
        }

        // Get cardType
/*         access(all) fun getCardType(cardId: UInt64): AnyStruct {
            let ref = self.borrowNFT(cardId)!
            let cardType = ref.
            return nil
        } */


/* 		access(all) fun claim() {
			if let storage = &VenezuelaNFT_19.nftStorage[self.owner!.address] as &{UInt64: NFT}? {
				for id in storage.keys {
					self.deposit(token: <- storage.remove(key: id)!)
				}
			}
		} */
	}

    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 Administrator Resource
    // -----------------------------------------------------------------------
    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the Cards, Sets, and Seasons
    //
    access(all) resource Administrator {
        // createLocationCard creates a new LocationCard struct 
        // and stores it in the LocationCards dictionary in the VenezuelaNFT_19 smart contract
        //
        // Returns: the ID of the new Card object
        //
        access(all) 
        fun createLocationCard(
            name: String,
            region: String,
            description: String,
            bonusType: String,
            influencePointsGeneration: UInt32,
            regionalGeneration: UInt32,
            cardNarratives: {UInt32: String},
            proposals: [LocationProposal],
            ipfsCID: String,
            imagePath: String): UInt32 {
            // Create the new Card
            var newCard = LocationCard(
                name: name,
                region: region,
                description: description,
                bonusType: bonusType,
                influencePointsGeneration: influencePointsGeneration,
                regionalGeneration: regionalGeneration,
                cardNarratives: cardNarratives,
                proposals: proposals,
                image: imagePath,
                ipfsCID: ipfsCID 
            )
            let newID = newCard.cardID

            // Store it in the contract storage
            // for LocationCards
            VenezuelaNFT_19.locationsData[newID] = newCard
            // Store it in the contract storage
            // for card types
            VenezuelaNFT_19.cardTypes[newID] = Type<VenezuelaNFT_19.LocationCard>()
            // Increment the ID so that it isn't used again
            VenezuelaNFT_19.nextCardID = VenezuelaNFT_19.nextCardID + 1

            // emit event
            emit CardCreated(cardID: newCard.cardID, cardType: "Location")

            return newID
        }
        // createCharacterCard creates a new CharacterCard struct 
        // and stores it in the CharacterCards dictionary in the VenezuelaNFT_19 smart contract
        //
        // Returns: the ID of the new Card object
        //
        access(all) fun createCharacterCard(
            name: String,
            description: String,
            characterTypes: [String],
            influencePointsGeneration: UInt32,
            launchCost: UInt32,
            presidentEffects: PresidentEffects,
            cardNarratives: {UInt32: String},
            image: String,
            ipfsCID: String): UInt32 {
            // Create the new Card
            var newCard = CharacterCard(
                name: name,
                description: description,
                characterTypes: characterTypes,
                influencePointsGeneration: influencePointsGeneration,
                launchCost: launchCost,
                presidentEffects: presidentEffects,
                cardNarratives: cardNarratives,
                image: image,
                ipfsCID: ipfsCID
            )
            let newID = newCard.cardID

            // Store it in the contract storage
            VenezuelaNFT_19.charactersData[newID] = newCard
            // Store it in the contract storage
            // for card types
            VenezuelaNFT_19.cardTypes[newID] = Type<VenezuelaNFT_19.CharacterCard>()
            // Increment the ID so that it isn't used again
            VenezuelaNFT_19.nextCardID = VenezuelaNFT_19.nextCardID + 1
            // emit event
            emit CardCreated(cardID: newCard.cardID, cardType: "Character")

            return newID
        }
        // createCulturalItemCard creates a new CulturalItemCard struct 
        // and stores it in the CulturalItemCards dictionary in the VenezuelaNFT_19 smart contract
        //
        // Returns: the ID of the new Card object
        //
        access(all) fun createCulturalItemCard(
            name: String,
            description: String,
            bonusType: String,
            influencePointsGeneration: UInt32,
            cardNarratives: {UInt32: String},
            specialEffects: CulturalItemEffects,
            image: String,
            ipfsCID: String): UInt32 {
            // Create the new Card
            var newCard = CulturalItemCard(
                name: name,
                description: description,
                bonusType: bonusType,
                influencePointsGeneration: influencePointsGeneration,
                cardNarratives: cardNarratives,
                specialEffects: specialEffects,
                image: image,
                ipfsCID: ipfsCID
            )
            let newID = newCard.cardID

            // Store it in the contract storage
            VenezuelaNFT_19.culturalItemsData[newID] = newCard
            // Store it in the contract storage
            // for card types
            VenezuelaNFT_19.cardTypes[newID] = Type<VenezuelaNFT_19.CulturalItemCard>()
            // Increment the ID so that it isn't used again
            VenezuelaNFT_19.nextCardID = VenezuelaNFT_19.nextCardID + 1
            // emit event
            emit CardCreated(cardID: newCard.cardID, cardType: "Cultural Item")

            return newID
        }

        // createSet creates a new Set resource and stores it
        // in the sets mapping in the VenezuelaNFT_19 contract
        //
        // Parameters: name: The name of the Set
        //
        // Returns: The ID of the created set
        access(all) fun createSet(name: String): UInt32 {

            // Create the new Set
            var newSet <- create Set(name: name)

            // Increment the setID so that it isn't used again
            VenezuelaNFT_19.nextSetID = VenezuelaNFT_19.nextSetID + 1

            let newID = newSet.setID

            emit SetCreated(setID: newSet.setID, season: VenezuelaNFT_19.currentSeason)

            // Store it in the sets mapping field
            VenezuelaNFT_19.sets[newID] <-! newSet

            return newID
        }
        // Get a ref to a set to call its functions
        access(all) view fun borrowSet(setID: UInt32): &Set {
            pre {
                VenezuelaNFT_19.sets[setID] != nil: "Cannot borrow Set: The Set doesn't exist"
            }
            
            // Get a reference to the Set and return it
            // use `&` to indicate the reference to the object and type
            return (&VenezuelaNFT_19.sets[setID])!
        }
        // Delete a set
/*         access(all) fun deleteSet(setID: UInt32): &{UInt32: Type} {
            let setRef = self.borrowSet(setID: setID)
            setRef.resetSet()

            return setRef.cards
        } */
    }

    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 Receipts Storage Resource
    // -----------------------------------------------------------------------

    access(all) resource ReceiptStorage {
		// List of Receipts 
		access(all) var receipts: @[Receipt]    

        init () {
            self.receipts <- []
        }

		// Deposit takes a Receipt and adds it to the storage list
		access(all) fun deposit(receipt: @Receipt) {
            let id = receipt.uuid
            self.receipts.append(<- receipt)

            // Emit event
			emit ReceiptDeposit(id: id, to: self.owner?.address) 
		}
		// Withdraw removes the oldest Receipt from the list and moves it to the caller(to reveal)
		access(all) fun withdraw(): @Receipt {
			let receipt <- self.receipts.removeFirst()
            let id = receipt.uuid
			
            emit ReceiptWithdraw(id: id, from: self.owner?.address)
            return <- receipt
		}
        // Get number of packs in storage
        access(all) fun getBalance(): Int {

            return self.receipts.length
        }
    }
    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 Receipt Resource
    // -----------------------------------------------------------------------
    /// The Receipt resource is used to store the associated randomness request. By listing the
    /// RandomConsumer.RequestWrapper conformance, this resource inherits all the default implementations of the
    /// interface. This is why the Receipt resource has access to the getRequestBlock() and popRequest() functions
    /// without explicitly defining them.
    ///
    access(all) resource Receipt : RandomConsumer.RequestWrapper {
        /// The associated randomness request which contains the block height at which the request was made
        // The setID of the intended pack
        access(all) let setID: UInt32
        /// and whether the request has been fulfilled.
        access(all) var request: @RandomConsumer.Request?

        init(setID: UInt32, request: @RandomConsumer.Request) {
            self.setID = setID
            self.request <- request
        }
    }
    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 private functions
    // -----------------------------------------------------------------------
    // borrowSet returns a reference to a set in the VenezuelaNFT_19
    // contract so that the admin can call methods on it
    //
    // Parameters: setID: The ID of the Set that you want to
    // get a reference to
    //
    // Returns: A reference to the Set with all of the fields
    // and methods exposed
    //
    access(account) view fun borrowSet(setID: UInt32): &Set {
        pre {
            VenezuelaNFT_19.sets[setID] != nil: "Cannot borrow Set: The Set doesn't exist"
        }
            
        // Get a reference to the Set and return it
        // use `&` to indicate the reference to the object and type
        return (&VenezuelaNFT_19.sets[setID])!
    }
    /// Returns a random number between 0 and 1 using the RandomConsumer.Consumer resource contained in the contract.
    /// For the purposes of this contract, a simple modulo operation could have been used though this is not the case
    /// for all ranges. Using the Consumer.fulfillRandomInRange function ensures that we can get a random number
    /// within any range without a risk of bias.
    ///
    access(self) 
    fun _randomNumber(request: @RandomConsumer.Request, max: Int): UInt64 {
        return self.consumer.fulfillRandomInRange(request: <-request, min: 0, max: UInt64(max))
    }
    // -----------------------------------------------------------------------
    // VenezuelaNFT_19 public functions
    // -----------------------------------------------------------------------

    /// createEmptyCollection creates an empty Collection for the specified NFT type
    /// and returns it to the caller so that they can own NFTs
    access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {
        return <- create Collection()
    }
    /// createEmptyStorage creates an empty ReceiptStorage 
    /// and returns it to the caller
    access(all) fun createEmptyStorage(): @ReceiptStorage {
        return <- create ReceiptStorage()
    }
    // buyPack mints a new VenezuelaNFT_19.Receipt and returns it
    // 
    // Parameters: setID: The ID of the Set that the VenezuelaNFT_19 references
    //             payment: 1.0 Flow
    //
    // Pre-Conditions:
    // The Set must exist in the Set and be allowed to mint new VenezuelaNFT_19s
    //
    // Returns: A Receipt for it to be redeemed later
    // 
    access(all) fun buyPackFlow(setID: UInt32, payment: @{FungibleToken.Vault}): @Receipt {
        pre {
            payment.balance == 1.0: "Payment is not 1 Flow"
        }

        let request <- self.consumer.requestRandomness()
        let receipt <- create Receipt(setID: setID, request: <-request)
        // Get contract's Vault
		let VenezuelaTreasury = getAccount(VenezuelaNFT_19.account.address).capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        // Deposit the Flow into the account
        VenezuelaTreasury.deposit(from: <- payment)
        
        emit BoughtPack(commitBlock: receipt.getRequestBlock()!, receiptID: receipt.uuid)

        return <- receipt
    }
    // Same as buyPackFlow but with Influence Points
    access(all) fun buyPackIP(setID: UInt32, payment: @{FungibleToken.Vault}): @Receipt {
        pre {
            payment.balance == 1.0: "Payment is not 1 Flow"
        }

        let request <- self.consumer.requestRandomness()
        let receipt <- create Receipt(setID: setID, request: <-request)
        // Get contract's Vault
		let VenezuelaTreasury = getAccount(VenezuelaNFT_19.account.address).capabilities.borrow<&{FungibleToken.Receiver}>(/public/VenezuelaIPReceiver)!
        // Deposit the Flow into the account
        VenezuelaTreasury.deposit(from: <- payment)
        
        emit BoughtPack(commitBlock: receipt.getRequestBlock()!, receiptID: receipt.uuid)

        return <- receipt
    }
    /* --- Reveal --- */
    //
    /// Here the caller provides the Receipt given to them at commitment. The contract then "reveals pack" with
    /// _randomNumber(), providing the Receipt's contained Request.
    ///
    access(all) fun revealPack(receipt: @Receipt, minter: Address, emptyDict: {String: String}) {
        pre {
            receipt.request != nil: 
            "VenezuelaNFT_19.revealPack: Cannot reveal the pack! The provided receipt has already been revealed."
            receipt.getRequestBlock()! <= getCurrentBlock().height:
            "VenezuelaNFT_19.revealPack: Cannot reveal the pack! The provided receipt was committed for block height ".concat(receipt.getRequestBlock()!.toString())
            .concat(" which is greater than the current block height of ")
            .concat(getCurrentBlock().height.toString())
            .concat(". The reveal can only happen after the committed block has passed.")
        }
        // Get reference to set
        let commitBlock = receipt.getRequestBlock()!
        let receiptID = receipt.uuid
        // Get reference to set
        let set = self.borrowSet(setID: receipt.setID)
        let recipient = getAccount(minter)
        // Get reference to recipient's account
        let receiverRef = recipient.capabilities.borrow<&{VenezuelaNFT_19.VenezuelaNFT_19CollectionPublic}>(VenezuelaNFT_19.CollectionPublicPath)
            ?? panic("Cannot borrow a reference to the recipient's moment collection")
        // fulfill the request with a PRG to generate multiple random numbers from
        let prg = self.consumer.fulfillWithPRG(request: <-receipt.popRequest())
        let prgRef = &prg as &Xorshift128plus.PRG
        // Declare the rarity var
        var rarity = ""
        var cardID: UInt32 = 0
        var cardSlot: UInt32 = 0


        var count = 0

        while count < 2 {

            if rarity == "" {
                // Determine the card's rarity randomly 
                let randomIDIndex = RandomConsumer.getNumberInRange(prg: prgRef, min: 0, max: 10000)
                // Get the name of the rarity
                rarity = set.determineRarity(randomNumber: randomIDIndex)

                count = count + 1

            } else {
                // Get all cards with that rarity
                let possibleCards = set.getCardsWithRarity(rarity: rarity)
                // Get a card picked at random among the possible cards
                cardSlot = UInt32(RandomConsumer.getNumberInRange(prg: prgRef, min: 0, max: UInt64(possibleCards.length - 1)))

                count = count + 1
            }
        }

        // Burn the receipt
        Burner.burn(<-receipt) 
        // get card's type
        let cardType = set.getCardType(cardSlot: cardSlot, rarity: rarity)
        // get card's type
        cardID = set.getCardID(cardSlot: cardSlot, rarity: rarity)
        emptyDict["rarity"] = rarity   
        // Get card's metadata
        switch cardType {
            case Type<VenezuelaNFT_19.LocationCard>():
                let cardMetadata = self.getLocationMetaData(cardID: cardID)!
                let cardName = cardMetadata.name
                let cardImg = cardMetadata.image
                let ipfsCID = cardMetadata.ipfsCID
                let description = cardMetadata.description
                emptyDict["cardName"] = cardName
                emptyDict["img"] = cardImg
                emptyDict["ipfsCID"] = ipfsCID
                emptyDict["description"] = description
                emptyDict["card"] = description
            case Type<VenezuelaNFT_19.CharacterCard>():
                let cardMetadata = self.getCharacterMetaData(cardID: cardID)!
                let cardName = cardMetadata.name
                let cardImg = cardMetadata.image
                let ipfsCID = cardMetadata.ipfsCID
                let description = cardMetadata.description
                emptyDict["cardName"] = cardName
                emptyDict["img"] = cardImg
                emptyDict["ipfsCID"] = ipfsCID
                emptyDict["description"] = description
            case Type<VenezuelaNFT_19.CulturalItemCard>():
                let cardMetadata = self.getItemMetaData(cardID: cardID)!
                let cardName = cardMetadata.name
                let cardImg = cardMetadata.image
                let ipfsCID = cardMetadata.ipfsCID
                let description = cardMetadata.description
                emptyDict["cardName"] = cardName
                emptyDict["img"] = cardImg
                emptyDict["ipfsCID"] = ipfsCID
                emptyDict["description"] = description
        }
        // Gets the number of VenezuelaNFT_19 that have been minted for this cardID
        // to use as this VenezuelaNFT_19's serial number
        let currentSerial = set.numberMintedPerCard[cardID]!
        // Mint the new VenezuelaNFT_19
        let newNFT: @NFT <- create NFT(cardName: emptyDict["cardName"]!,
                                        cardDescription: emptyDict["description"]!,
                                        rarity: emptyDict["rarity"]!,
                                        cardImg: emptyDict["img"]!,
                                        ipfsCID: emptyDict["ipfsCID"]!,
                                        cardType: cardType,
                                        cardID: cardID,
                                        influencePoints: 1.0,
                                        serialNumber: currentSerial + 1,
                                        setID: set.setID,
                                        minter: minter
                                    )
        // Emit event
        emit PackRevealed(
            nftID: newNFT.uuid,
            cardID: cardID,
            setID: set.setID,
            serialNumber: currentSerial + 1,
            recipient: minter,
            commitBlock: commitBlock,
            receiptID: receiptID,
            )
        // Deposit NFT into user's account
        receiverRef.deposit(token: <- newNFT)
        // Increment the count of VenezuelaNFT_19 minted for this Card
        set.incrementCount(cardID: cardID)

        // return <- newNFT
    }
    // Public function to fetch a collection attribute
    access(all) fun getCollectionAttribute(key: String): AnyStruct {
		return self.collectionInfo[key] ?? panic(key.concat(" is not an attribute in this collection."))
	}
    access(all) view fun getCardMetadata(cardID: UInt32, cardType: Type): AnyStruct {
            switch cardType {
                case Type<VenezuelaNFT_19.LocationCard>():
                    return self.getLocationMetaData(cardID: cardID)
                case Type<VenezuelaNFT_19.CharacterCard>():
                    return self.getCharacterMetaData(cardID: cardID)
                case Type<VenezuelaNFT_19.CulturalItemCard>():
                    return self.getItemMetaData(cardID: cardID)
            }
            return nil
    }

    //
    // Returns: An array of all the locations that have been created
    access(all) view fun getAllLocationCards(): [LocationCard] {
        return VenezuelaNFT_19.locationsData.values
    }
    // Returns: An array of all the characters that have been created
    access(all) view fun getAllCharacterCards(): [CharacterCard] {
        return VenezuelaNFT_19.charactersData.values
    }
    // Returns: An array of all the items that have been created
    access(all) view fun getAllItemsCards(): [CulturalItemCard] {
        return VenezuelaNFT_19.culturalItemsData.values
    }
    access(all) view fun getAllTypes(): {UInt32: Type} {
        return self.cardTypes
    }
    // Returns: Type of the card associated with this id
    access(all) view fun getCardType(cardID: UInt32): Type {

        return self.cardTypes[cardID]!
    }
    // getCardMetaData returns all the metadata associated with a specific Card
    // 
    // Parameters: cardID: The id of the Card that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    access(all) view fun getLocationMetaData(cardID: UInt32): LocationCard? {
        return self.locationsData[cardID]
    }
    access(all) view fun getCharacterMetaData(cardID: UInt32): CharacterCard? {
        return self.charactersData[cardID]
    }
    access(all) view fun getItemMetaData(cardID: UInt32): CulturalItemCard? {
        return self.culturalItemsData[cardID]
    }
    /// Function that returns all the Metadata Views implemented by a Non Fungible Token
    ///
    /// @return An array of Types defining the implemented views. This value will be used by
    ///         developers to know which parameter to pass to the resolveView() method.
    ///
    access(all) view fun getContractViews(resourceType: Type?): [Type] {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        //    Type<MetadataViews.EVMBridgedMetadata>()
        ]
    }
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                let collectionData = MetadataViews.NFTCollectionData(
                    storagePath: self.CollectionStoragePath,
                    publicPath: self.CollectionPublicPath,
                    publicCollection: Type<&VenezuelaNFT_19.Collection>(),
                    publicLinkedType: Type<&VenezuelaNFT_19.Collection>(),
                    createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                        return <-VenezuelaNFT_19.createEmptyCollection(nftType: Type<@VenezuelaNFT_19.NFT>())
                    })
                )
                return collectionData
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = VenezuelaNFT_19.getCollectionAttribute(key: "image") as! MetadataViews.Media
                return MetadataViews.NFTCollectionDisplay(
                    name: "VenezuelaNFT_19",
                    description: "VenezuelaNFT_19s and Telegram governance.",
                    externalURL: MetadataViews.ExternalURL("https://VenezuelaNFT_19.gg/"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/VenezuelaNFT_19")
                    }
                )
        }
        return nil
    }
    // Init

    init() {
        self.cardDatas = {}
        self.locationsData = {}
        self.charactersData = {}
        self.locationsData = {}
        self.culturalItemsData = {}
        self.cardTypes = {}
        self.setDatas = {}
        self.sets <- {}
        self.totalSupply = 0
        self.currentSeason = 0
        self.nextCardID = 0
        self.nextSetID = 0
        self.collectionInfo = {}
		self.collectionInfo["image"] = MetadataViews.Media(
            			file: MetadataViews.HTTPFile(
            				url: "https://bafybeiceaod6tlnx36curr5fheppn43yuum42iuqodwnd4ve3hfsncagly.ipfs.dweb.link?filename=Logo"
            			),
            			mediaType: "image/jpeg"
          			)
        self.collectionInfo["website"] = MetadataViews.ExternalURL("https://www.Venezuela.gg/")
        self.collectionInfo["socials"] = {"Twitter": MetadataViews.ExternalURL("https:x/Vzla.app/")}
        self.collectionInfo["dateCreated"] = getCurrentBlock().timestamp
        self.collectionInfo["description"] = "Venezuela Democracy app"
        self.collectionInfo["name"] = "VenezuelaNFT"
        // Create a RandomConsumer.Consumer resource
        self.consumer <-RandomConsumer.createConsumer()
		// Set the named paths
        let identifier = "VenezuelaNFT_19_".concat(self.account.address.toString())
		self.CollectionStoragePath = StoragePath(identifier: identifier)!
		self.CollectionPublicPath = PublicPath(identifier: identifier)!
		// self.CollectionPrivatePath = PrivatePath(identifier: identifier)!
		self.AdministratorStoragePath = StoragePath(identifier: identifier.concat("Administrator"))!
		self.ReceiptStoragePath = StoragePath(identifier: identifier.concat("ReceiptStorage"))!
		self.ReceiptStoragePublic = PublicPath(identifier: identifier.concat("ReceiptStorage"))!

		// Create a Collection resource and save it to storage
		let collection <- create Collection()
		self.account.storage.save(<- collection, to: self.CollectionStoragePath)
        // create a public capability for the collection
	    let collectionCap = self.account.capabilities.storage.issue<&VenezuelaNFT_19.Collection>(self.CollectionStoragePath)
		self.account.capabilities.publish(collectionCap, at: self.CollectionPublicPath)
		// Create a Administrator resource and save it to VenezuelaNFT_19 account storage
		let administrator <- create Administrator()
		self.account.storage.save(<- administrator, to: self.AdministratorStoragePath)
		// Create a ReceiptStorage resource and save it to VenezuelaNFT_19 account storage
		let storage <- create ReceiptStorage()
		self.account.storage.save(<- storage, to: self.ReceiptStoragePath)
        // create a public capability for the storage
	    let storageCap = self.account.capabilities.storage.issue<&VenezuelaNFT_19.ReceiptStorage>(self.ReceiptStoragePath)
		self.account.capabilities.publish(storageCap, at: self.ReceiptStoragePublic)
        // Emit contract init event
		emit ContractInitialized()
    }
}

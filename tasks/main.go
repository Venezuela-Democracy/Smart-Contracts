package main

import (
	"fmt"

	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
)

func main() {
	// Comienza el programa overflow"
	o := Overflow(
		WithGlobalPrintOptions(),
	)
	fmt.Println("Testing Vzla Democracy cadence contracts")
	//
	///// Probando CADENCE en Overflow /////
	//
	// Setup
	o.Tx("/setup",
		WithSigner("bob"),
	)
	color.Red("Admin should be able to upload metadata to the contract")
	// Admin create characterCard
	o.Tx("admin/create_characterCard",
		WithSigner("account"),
		WithArg("name", "Andrés Bello"),
		WithArg("description", "Andrés Bello (1781–1865) was an intellectual titan whose influence on Latin American thought remains profound. A polymath and visionary, Bello was a poet, philosopher, educator, linguist, and statesman. Born in Caracas, Venezuela, he was a leading figure in the cultural and intellectual renaissance of Latin America in the 19th century. His work bridged the Enlightenment ideals of Europe with the social and political realities of the Americas, making him one of the most prominent intellectuals of his time."),
		WithArg("influencePointsGeneration", "20"),
		WithArg("characterTypes", `["Educational", "Cultural"]`),
		WithArg("launchCost", "800"),
		WithArg("effectCostReduction", `{"Educational": 40}`),
		WithArg("developmentEffect", `{"Educational": 50}`),
		WithArg("bonusEffect", `{"Educational": 50}`),
		WithArg("cardNarratives", `{70: "Bello's legacy defines regional identity", 50: "Bello's ideas inspire local development"}`),
		WithArg("image", "https://historiahoy.com.ar/wp-content/uploads/2020/10/0000089139-1-762x1024.jpg"),
		WithArg("ipfsCID", "Andrés Bello"),
	).Print()

	o.Tx("admin/create_itemCard",
		WithSigner("account"),
		WithArg("name", "Arepa"),
		WithArg("description", "Venezuelan arepas are a mouthwatering celebration of flavor and tradition, offering a delightful experience with every bite. These golden, slightly crispy pockets of cornmeal are soft on the inside, their delicate texture providing the perfect contrast to the crisp, golden crust. Versatile and deeply satisfying, arepas can be filled with a myriad of ingredients, making them the ideal canvas for both savory and sweet creations."),
		WithArg("influencePointsGeneration", "10"),
		WithArg("votingEffect", `{"Gastronomic": 2}`),
		WithArg("specialEffect", `{"Gastronomic": 20}`),
		WithArg("type", "Gastronomic"),
		WithArg("cardNarratives", `{90: "The arepa crowns itself as the region’s undisputed symbol", 70: "The arepa defines local gastronomic identity"}`),
		WithArg("image", "https://imag.bonviveur.com/arepas-venezolanas-caseras-rellenas.jpg"),
		WithArg("ipfsCID", "Arepa"),
	).Print()
	// upload_metadata
	o.Tx("admin/create_locationCard",
		WithSigner("account"),
		WithArg("name", "University of Los Andes"),
		WithArg("region", "Merida"),
		WithArg("description", "The University of Los Andes (Universidad de Los Andes, ULA) is a prestigious and historic institution nestled in the Andean mountain range of Venezuela, in the vibrant city of Mérida. Established in 1810, it is one of the oldest and most renowned universities in Latin America, with a rich legacy of academic excellence, innovation, and cultural significance. Set against the backdrop of stunning mountainous landscapes, ULA is not just a place of higher learning but a symbol of intellectual pursuit, contributing profoundly to Venezuela's educational, scientific, and cultural development."),
		WithArg("type", "Educational"),
		WithArg("influencePointsGeneration", "15"),
		WithArg("regionalGeneration", "100"),
		WithArg("cardNarratives", `{80: "ULA consolidates as Merida's intellectual heart", 60: "The university sets the rhythm of Merida’s life"}`),
		WithArg("proposal_1_name", "Scholarship Program"),
		WithArg("proposal_1_effect", "10"),
		WithArg("proposal_1_duration", "7.0"),
		WithArg("proposal_1_adoptionRequirement", "30"),
		WithArg("ipfsCID", "Qmc2rHqzmHxxswAZDYHTLiosiaaqnPmFSSBtsBEWbM6MS1"),
		WithArg("imagePath", "https://bafybeiglorbajdtbqtqngzfvz3cpn6a3j7qzkn5knxjai76ksm5sxv43qi.ipfs.dweb.link?filename=waseemkhan_10131_Lagos-Brazilians_built_schools_Realistic_pic_w_485d45ba-5cab-4bc7-b33e-627c0de38e32.jpeg"),
	).Print()

	o.Tx("admin/create_locationCard",
		WithSigner("account"),
		WithArg("name", "Angel Falls"),
		WithArg("region", "Bolivar"),
		WithArg("description", "Angel Falls, the world's highest uninterrupted waterfall, is a breathtaking natural wonder located deep within the heart of Venezuela's Canaima National Park in the Gran Sabana region. Cascading from a towering height of 3,212 feet (979 meters), with an awe-inspiring free-fall of 2,648 feet (807 meters), Angel Falls is a magnificent sight to behold, its water streaming like liquid silver as it plunges from the flat-topped Auyán Tepui, one of the park's majestic tepui formations."),
		WithArg("type", "Cultural"),
		WithArg("influencePointsGeneration", "15"),
		WithArg("regionalGeneration", "100"),
		WithArg("cardNarratives", `{80: "Angela Falls consolidates as Bolivar's cultural heart"}`),
		WithArg("proposal_1_name", "Tourist Program"),
		WithArg("proposal_1_effect", "10"),
		WithArg("proposal_1_duration", "7.0"),
		WithArg("proposal_1_adoptionRequirement", "30"),
		WithArg("ipfsCID", "QmTe6PUp7MrFto3XYBdaDcvawYrEYAm2FSzX7uSNchQ71p"),
		WithArg("imagePath", "https://bafybeihe3r7nwgutoxzjj2eewwj5uml23zmwhhjfac6b5677sxxv7wosaa.ipfs.dweb.link?filename=image%204.jpg"),
	).Print()

	// Script to get LocationCard metadata
	// o.Script("get_locationCard", WithArg("cardID", "0")).Print()
	// Script to get card metadata
	// o.Script("get_card_metadata", WithArg("cardID", "2")).Print()

	color.Red("Admin should be able to create a set")
	// Incrementa el contador
	o.Tx("admin/create_set",
		WithSigner("account"),
		WithArg("setName", "Base Locations"),
	).Print()
	color.Red("Admin should be able to add cards to a set")
	// create_season
	o.Tx("admin/add_cards_to_set",
		WithSigner("account"),
		WithArg("setID", "0"),
		WithArg("cards", "[0, 1, 2, 3]"),
	).Print()
	// Script to get all cards

	color.Red("User should be able to buy a Pack")

	o.Tx("buy_pack",
		WithSigner("account"),
		WithArg("setID", "0"),
	).Print()

	color.Red("User should be able to open a Pack")

	o.Tx("reveal_pack",
		WithSigner("account"),
	).Print()

	o.Script("owned_nfts",
		WithArg("account", "account"),
	).Print()

	// o.Script("get_all_cards").Print()

	color.Red("User should be able to buy a second Pack")
	o.Tx("buy_pack",
		WithSigner("account"),
		WithArg("setID", "0"),
	)
	o.Tx("reveal_pack",
		WithSigner("account"),
	)
	// STOREFRONT
	color.Red("User should be able to sell an NFT")
	o.Tx("/Storefront/setup",
		WithSigner("bob"),
	)
	o.Tx("/Storefront/setup",
		WithSigner("account"),
	)
	listingResourceID, error := o.Tx("/Storefront/sell_item",
		WithSigner("account"),
		WithArg("saleItemID", "1"),
		WithArg("saleItemPrice", "10.0"),
		WithArg("customID", "0"),
		WithArg("commissionAmount", "0.5"),
		WithArg("marketplacesAddress", "[]"),
	).GetIdFromEvent("ListingAvailable", "listingResourceID")
	fmt.Print(error)
	fmt.Print(listingResourceID)

	o.Script("/Storefront/get_ids",
		WithArg("account", "account"),
	)

	color.Red("Bob should be able to buy an NFT")
	o.Tx("/Storefront/buy_item",
		WithSigner("bob"),
		WithArg("listingResourceID", listingResourceID),
		WithArg("storefrontAddress", "account"),
		WithArg("commissionRecipient", "account"),
	)

	// create_season
	/* 	o.Tx("admin/start_new_season",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	) */
}

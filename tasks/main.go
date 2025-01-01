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
	//	WithNetwork("testnet"),
	)
	fmt.Println("Testing Vzla Democracy cadence contracts")
	//
	///// Probando CADENCE en Overflow /////
	//
	color.Red("Admin should be able to upload metadata to the contract")
	// upload_metadata
	o.Tx("admin/create_locationCard",
		WithSigner("account"),
		WithArg("region", "Merida"),
		WithArg("name", "University of Los Andes"),
		WithArg("type", "Educational"),
		WithArg("generation", "15"),
		WithArg("regionalGeneration", "100"),
		WithArg("cardNarratives", `{80: "ULA consolidates as Merida's intellectual heart", 60: "The university sets the rhythm of Merida’s life"}`),
		WithArg("proposal_1_name", "Scholarship Program"),
		WithArg("proposal_1_effect", "10"),
		WithArg("proposal_1_duration", "7.0"),
		WithArg("proposal_1_adoptionRequirement", "30"),
		WithArg("ipfsCID", "Qmdk2fvqTmTeuTHWrGQo4MqgXpB1qHFSaE9PrVd8cdczCf"),
		WithArg("imagePath", "https://bafybeicoyjl7hlvfbcxvxxli45wl2v2wqoe5aqfp4lpheb4vsd2izojrx4.ipfs.dweb.link?filename=waseemkhan_10131_Lagos-Brazilians_built_schools_Realistic_pic_w_485d45ba-5cab-4bc7-b33e-627c0de38e32.png"),
	).Print()

	/* 	o.Tx("admin/create_locationCard",
		WithSigner("account"),
		WithArg("region", "Bolivar"),
		WithArg("name", "Angela Falls"),
		WithArg("type", "Cultural"),
		WithArg("generation", "15"),
		WithArg("regionalGeneration", "100"),
		WithArg("cardNarratives", `{80: "Angela Falls consolidates as Bolivar's cultural heart"}`),
		WithArg("proposal_1_name", "Tourist Program"),
		WithArg("proposal_1_effect", "10"),
		WithArg("proposal_1_duration", "7.0"),
		WithArg("proposal_1_adoptionRequirement", "30"),
		WithArg("ipfsCID", "QmTe6PUp7MrFto3XYBdaDcvawYrEYAm2FSzX7uSNchQ71p"),
		WithArg("imagePath", "https://bafybeihe3r7nwgutoxzjj2eewwj5uml23zmwhhjfac6b5677sxxv7wosaa.ipfs.dweb.link?filename=image%204.jpg"),
	).Print() */

	// Script to get LocationCard metadata
	o.Script("get_locationCard", WithArg("cardID", "0")).Print()
	// Admin create characterCard
	/* 	o.Tx("admin/create_characterCard",
	   		WithSigner("account"),
	   		WithArg("name", "Andrés Bello"),
	   		WithArg("characterTypes", `["Educational", "Cultural"]`),
	   		WithArg("influencePointsGeneration", "20"),
	   		WithArg("launchCost", "800"),
	   		WithArg("effectCostReduction", `{"Educational": 40}`),
	   		WithArg("developmentEffect", `{"Educational": 50}`),
	   		WithArg("bonusEffect", `{"Educational": 50}`),
	   		WithArg("cardNarratives", `{70: "Bello's legacy defines regional identity", 50: "Bello's ideas inspire local development"}`),
	   	).Print()
	   	// Script to get card metadata
	   	o.Script("get_card_metadata", WithArg("cardID", "1")).Print()
	   	o.Tx("admin/create_itemCard",
	   		WithSigner("account"),
	   		WithArg("name", "Arepa"),
	   		WithArg("votingEffect", `{"Gastronomic": 2}`),
	   		WithArg("specialEffect", `{"Gastronomic": 20}`),
	   		WithArg("type", "Gastronomic"),
	   		WithArg("influencePointsGeneration", "10"),
	   		WithArg("cardNarratives", `{90: "The arepa crowns itself as the region’s undisputed symbol", 70: "The arepa defines local gastronomic identity"}`),
	   	).Print()
	   	// Script to get card metadata
	   	o.Script("get_card_metadata", WithArg("cardID", "2")).Print()
	*/

	/* 	color.Red("Admin should be able to create a set")
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
	   		WithArg("cards", "[0, 1]"),
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
	   	).Print() */
	/*
		color.Red("User should be able to buy a second Pack")
		o.Tx("buy_pack",
			WithSigner("account"),
			WithArg("setID", "0"),
		)
		o.Tx("reveal_pack",
			WithSigner("account"),
		) */

	// create_season
	/* 	o.Tx("admin/start_new_season",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	) */
}

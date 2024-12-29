package main

import (
	"fmt"

	. "github.com/bjartek/overflow/v2"
	"github.com/fatih/color"
)

func main() {
	// Comienza el programa overflow
	o := Overflow(
		WithGlobalPrintOptions(),
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
		WithArg("type", "Educational"),
		WithArg("generation", "15"),
		WithArg("regionalGeneration", "100"),
		WithArg("cardNarratives", `{80: "ULA consolidates as Merida's intellectual heart", 60: "The university sets the rhythm of Merida’s life"}`),
		WithArg("proposal_1_name", "Scholarship Program"),
		WithArg("proposal_1_effect", "10"),
		WithArg("proposal_1_duration", "7.0"),
		WithArg("proposal_1_adoptionRequirement", "30"),
	)
	o.Tx("admin/create_characterCard",
		WithSigner("account"),
		WithArg("characterTypes", `["Educational", "Cultural"]`),
		WithArg("influencePointsGeneration", "20"),
		WithArg("launchCost", "800"),
		WithArg("effectCostReduction", `{"Educational": 40}`),
		WithArg("developmentEffect", `{"Educational": 50}`),
		WithArg("bonusEffect", `{"Educational": 50}`),
		WithArg("cardNarratives", `{70: "Bello's legacy defines regional identity", 50: "Bello's ideas inspire local development"}`),
	)
	o.Tx("admin/create_itemCard",
		WithSigner("account"),
		WithArg("votingEffect", `{"Gastronomic": 2}`),
		WithArg("specialEffect", `{"Gastronomic": 20}`),
		WithArg("type", "Gastronomic"),
		WithArg("influencePointsGeneration", "10"),
		WithArg("cardNarratives", `{90: "The arepa crowns itself as the region’s undisputed symbol", 70: "The arepa defines local gastronomic identity"}`),
	)
	color.Red("Admin should be able to create a set")
	// Incrementa el contador
	o.Tx("admin/create_set",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
	color.Red("Admin should be able to add cards to a set")
	// create_season
	o.Tx("admin/add_card_to_set",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
	color.Red("Admin should be able to starts a new season with selected sets")
	// create_season
	o.Tx("admin/start_new_season",
		WithSigner("account"),
		WithArg("", ""),
		WithArg("", ""),
		WithArg("", ""),
	)
}

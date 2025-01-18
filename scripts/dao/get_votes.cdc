import Governance from "../../contracts/Governance.cdc"

access(all) fun main(): &{String: Int} {
    return Governance.topics[0].votes
}
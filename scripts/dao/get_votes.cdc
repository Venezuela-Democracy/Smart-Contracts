import Governance from "../../contracts/Governance.cdc"

access(all) 
fun main(topicID: UInt64): {String: Int} {
    return Governance.getVotes(topicID: topicID)
}
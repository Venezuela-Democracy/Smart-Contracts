import "Governance"

access(all) fun main(): {UInt64: Governance.Topic} {
    return Governance.getTopics()
}
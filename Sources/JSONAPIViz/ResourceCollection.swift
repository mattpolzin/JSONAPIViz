//
//  ResourceCollection.swift
//  
//
//  Created by Mathew Polzin on 1/7/20.
//

import JSONAPI

public struct ResourceCollection<Resource: ResourceType> {
    public let resources: Set<Resource>
    /// If non-nil, each array will be a group of nodes that should end up at the same rank in the graph output.
    public let ranks: [[String]]?

    public init<T: Collection>(resources: T, ranks: [[String]]? = nil) where T.Element == Resource {
        self.resources = Set(resources)
        self.ranks = ranks
    }

    public func byResourceGraphVizDOT() -> String {
        return
"""
strict digraph D {
        \(resources.enumerated().map { (idx, resource) in subgraph(resource, idx: idx) }.joined(separator: "\n"))
}
"""
    }

    func subgraph(_ resource: Resource, idx: Int) -> String {
        return
"""
subgraph {
        \(edges(resource, suffix: String(repeating: " ", count: idx) ))
}
"""
    }

    public func fullGraphVizDOT(
        nodeFilter: (Resource) -> Bool = { _ in true },
        edgeFilter: (Resource.Relative) -> Bool = { _ in true },
        coloring: (Resource) -> Color? = { _ in nil }
    ) -> String {
        return
"""
strict digraph D {
    concentrate=true
    nodesep=0.25
    ranksep=0.75
    ratio=auto
    node [shape=box;style=rounded]
    \(rankedGroups(ranks))
    { \(nodesAndEdges(resources, nodeFilter: nodeFilter, edgeFilter: edgeFilter, coloring: coloring)) }
}
"""
    }

    func rankedGroups(_ ranks: [[String]]?) -> String {
        ranks.map { ranks in
            ranks.enumerated().map { rankGroup($0.element, idx: $0.offset) }.joined(separator: "\n")
                + "\n"
                + rankGroupEdges(count: ranks.count)
        } ?? ""
    }

    func rankGroup(_ rank: [String], idx: Int) -> String {
        let rankSpecifier: Rank = idx == 0 ? .source : .same
        return "{rank=\(rankSpecifier);\(rank.joined(separator: ";"));\(idx+1) [style=invis]}"
    }

    func rankGroupEdges(count: Int) -> String {
        return (1..<count).map { "\($0) -> \($0+1) [style=invis]" }
            .joined(separator: "\n")
    }

    func nodesAndEdges(
        _ resources: Set<Resource>,
        nodeFilter: (Resource) -> Bool = { _ in true },
        edgeFilter: (Resource.Relative) -> Bool = { _ in true },
        coloring: (Resource) -> Color? = { _ in nil }
    ) -> String {
        return resources.filter(nodeFilter).map { resource in
            return
"""
\(coloring(resource).map { "\(resource.typeName) [fillcolor=\($0.rawValue);style=\"filled,rounded,bold\"]" } ?? "")
\(edges(resource, edgeFilter: edgeFilter))
"""
        }.joined(separator: "\n")
    }

    func edges(
        _ resources: Set<Resource>,
        nodeFilter: (Resource) -> Bool = { _ in true },
        edgeFilter: (Resource.Relative) -> Bool = { _ in true }
    ) -> String {
        resources.filter(nodeFilter).map { edges($0, edgeFilter: edgeFilter) }.joined(separator: "\n\n")
    }

    func edges(
        _ resource: Resource,
        suffix: String = "",
        edgeFilter: (Resource.Relative) -> Bool = { _ in true }
    ) -> String {
        resource.relatives.filter(edgeFilter).map { relative in
            edge(from: resource, to: relative, suffix: suffix)
        }.joined(separator: "\n")
    }

    func edge(from resource: Resource, to relative: Resource.Relative, suffix: String = "") -> String {
        return "\"\(resource.typeName+suffix)\" -> \"\(relative.typeName+suffix)\" [\(edgeStyle(relative.relationship))]"
    }

    func edgeStyle(_ relationship: Relationship) -> String {
        // TODO: to-many vs to-one
        return "style=solid arrowhead=normal"
    }
}

fileprivate enum Rank: String {
    case source
    case min
    case same
    case max
    case sink
}

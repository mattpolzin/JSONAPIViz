//
//  ResourceObject.swift
//  
//
//  Created by Mathew Polzin on 1/7/20.
//

import JSONAPI

public protocol ResourceType: Hashable {
    associatedtype Relative: RelativeType

    var typeName: String { get }
    var relatives: Set<Relative> { get }
}

public struct ResourceObject: Hashable {
    public let jsonType: String
    public let relatives: Set<Relative>

    public init<T: JSONAPI.ResourceObjectType>(_ resource: T) {
        self.jsonType = T.jsonType

        relatives = resource.relatives
    }

    public init<T: Collection>(jsonType: String, relatives: T) where T.Element == Relative {
        self.jsonType = jsonType
        self.relatives = Set(relatives)
    }
}

extension JSONAPIViz.ResourceObject: ResourceType {
    public var typeName: String { jsonType }
}

extension JSONAPI.ResourceObjectType {
    var relatives: Set<Relative> {
        let mirror = Mirror(reflecting: relationships)

        let relativesArray = mirror.children
            .compactMap { child in
                zip(child.label, child.value as? _RelationshipType.Type) { (name: $0, type: $1) }
        }.map { child in Relative(name: child.name, child.type) }

        return Set(relativesArray)
    }
}

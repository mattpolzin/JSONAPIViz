//
//  Relative.swift
//  
//
//  Created by Mathew Polzin on 1/7/20.
//

import JSONAPI

public protocol RelativeType: Hashable {
    var name: String { get }
    var typeName: String { get }
    var relationship: Relationship { get }
}

public enum Relationship: Hashable {
    case toOne(Optionality)
    case toMany(Optionality)

    public enum Optionality: Hashable {
        case required
        case optional
    }
}

public struct Relative: Hashable {

    public let name: String
    public let jsonType: String
    public let relationship: Relationship

    public init(name: String, jsonType: String, relationship: Relationship) {
        self.name = name
        self.jsonType = jsonType
        self.relationship = relationship
    }

    internal init(name: String, _ relationshipType: _RelationshipType.Type) {
        self.name = name
        self.jsonType = relationshipType.jsonType
        self.relationship = relationshipType.relationship
    }

    // A required to-one relationship
    public init<Identifiable, MetaType: JSONAPI.Meta, LinksType: JSONAPI.Links>(name: String, _ relationshipType: JSONAPI.ToOneRelationship<Identifiable, MetaType, LinksType>.Type) where Identifiable: Relatable {
        self.name = name
        self.jsonType = Identifiable.jsonType
        self.relationship = .toOne(.required)
    }

    // A nullable to-one relationship
    public init<Identifiable, MetaType: JSONAPI.Meta, LinksType: JSONAPI.Links>(name: String, _ relationshipType: JSONAPI.ToOneRelationship<Identifiable, MetaType, LinksType>.Type) where Identifiable: OptionalRelatable {
        self.name = name
        self.jsonType = Identifiable.jsonType
        self.relationship = .toOne(.optional)
    }

    // An omittable to-one relationship
    public init<Identifiable: JSONAPIIdentifiable, MetaType: JSONAPI.Meta, LinksType: JSONAPI.Links>(name: String, _ relationshipType: JSONAPI.ToOneRelationship<Identifiable, MetaType, LinksType>?.Type) {
        self.name = name
        self.jsonType = Identifiable.jsonType
        self.relationship = .toOne(.optional)
    }

    // A required to-many relationship
    public init<Relatable: JSONAPI.Relatable, MetaType: JSONAPI.Meta, LinksType: JSONAPI.Links>(name: String, _ relationshipType: ToManyRelationship<Relatable, MetaType, LinksType>.Type) {
        self.name = name
        self.jsonType = Relatable.jsonType
        self.relationship = .toMany(.required)
    }

    // An omittable to-many relationship
    public init<Relatable: JSONAPI.Relatable, MetaType: JSONAPI.Meta, LinksType: JSONAPI.Links>(name: String, _ relationshipType: ToManyRelationship<Relatable, MetaType, LinksType>?.Type) {
        self.name = name
        self.jsonType = Relatable.jsonType
        self.relationship = .toMany(.optional)
    }
}

extension Relative: RelativeType {
    public var typeName: String { jsonType }
}

internal protocol _Optional {}
extension Optional: _Optional {}

internal protocol _RelationshipType {
    static var jsonType: String { get }
    static var relationship: Relationship { get }
}
extension ToOneRelationship: _RelationshipType {
    static var jsonType: String {
        Identifiable.jsonType
    }

    static var relationship: Relationship {
        .toOne(Identifiable.self is _Optional.Type ? .optional : .required)
    }
}
extension ToManyRelationship: _RelationshipType {
    static var jsonType: String {
        Relatable.jsonType
    }

    static var relationship: Relationship {
        .toMany(.required)
    }
}

//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

@resultBuilder
public struct ResourceBuilder {
    public typealias Component = [FileRepresentative]
    public typealias Expression = FileRepresentative
    
    public static func buildExpression(_ element: Expression) -> Component {
        return [element]
    }
    public static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else { return [] }
        return component
    }
    public static func buildEither(first component: Component) -> Component {
        return component
    }
    public static func buildEither(second component: Component) -> Component {
        return component
    }
    public static func buildArray(_ components: [Component]) -> Component {
        return Array(components.joined())
    }
    public static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
}

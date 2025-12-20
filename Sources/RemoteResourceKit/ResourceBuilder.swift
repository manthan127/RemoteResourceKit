//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

@resultBuilder
public struct ResourceBuilder {
    public static func buildOptional(_ components: [any FileRepresentative]?) -> [any FileRepresentative] {
        components ?? []
    }
    
    public static func buildEither(first component: [any FileRepresentative]) -> [any FileRepresentative] {
        component
    }
    
    public static func buildEither(second component: [any FileRepresentative]) -> [any FileRepresentative] {
        component
    }
    
    public static func buildBlock(_ components: [any FileRepresentative]...) -> [any FileRepresentative] {
        components.flatMap{$0}
    }
    
    public static func buildExpression(_ components: any FileRepresentative)-> [any FileRepresentative] {
        [components]
    }
}

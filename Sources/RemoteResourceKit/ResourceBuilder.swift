//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

// TODO: - not handling optional properly will need major changes
@resultBuilder
public struct ResourceBuilder {
    public static func buildBlock(_ components: FileRepresentative...) -> [FileRepresentative] {
        components
    }
    
    public static func buildExpression(_ expression: FileRepresentative) -> [any FileRepresentative] {
        [expression]
    }
    
    // function below are not working
//    public static func buildOptional(_ component: [any FileRepresentative]?) -> [any FileRepresentative] {
//        component ?? []
//    }
    
    public static func buildOptional(_ component: FileRepresentative?) -> [any FileRepresentative] {
        if let component {
            [component]
        } else {
            []
        }
    }
    
    public static func buildEither(first component: any FileRepresentative) -> [any FileRepresentative] {
        [ component ]
    }
    public static func buildEither(second component: any FileRepresentative) -> [any FileRepresentative] {
        [ component ]
    }
    
    public static func buildEither(first component: [any FileRepresentative]) -> [any FileRepresentative] {
        component
    }
    
    public static func buildEither(second component: [any FileRepresentative]) -> [any FileRepresentative] {
        component
    }
    
//    public static func buildExpression(_ components: any FileRepresentative)-> [any FileRepresentative] {
//        [components]
//    }
}


/*
@resultBuilder public struct ViewBuilder {
    
    /// Builds an expression within the builder.
    public static func buildExpression<Content>(_ content: Content) -> Content where Content : View
    
    /// Builds an empty view from a block containing no statements.
    public static func buildBlock() -> EmptyView
    
    /// Passes a single view written as a child view through unmodified.
    ///
    /// An example of a single view written as a child view is
    /// `{ Text("Hello") }`.
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : View
    
    public static func buildBlock<each Content>(_ content: repeat each Content) -> TupleView<(repeat each Content)> where repeat each Content : View
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ViewBuilder {
    
    /// Produces an optional view for conditional statements in multi-statement
    /// closures that's only visible when the condition evaluates to true.
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : View
    
    /// Produces content for a conditional statement in a multi-statement closure
    /// when the condition is true.
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent : View, FalseContent : View
    
    /// Produces content for a conditional statement in a multi-statement closure
    /// when the condition is false.
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent : View, FalseContent : View
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ViewBuilder {
    
    /// Processes view content for a conditional compiler-control
    /// statement that performs an availability check.
    public static func buildLimitedAvailability<Content>(_ content: Content) -> AnyView where Content : View
}

*/

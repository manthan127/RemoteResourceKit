//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

// TODO: - add something to verify that name is valid or not
public protocol FileRepresentative {
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]])
}

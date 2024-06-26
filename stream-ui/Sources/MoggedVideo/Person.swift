//
//  File 2.swift
//
//
//  Created by Jordan Howlett on 6/26/24.
//

import Foundation

public struct Person: Identifiable {
    public let id = UUID()
    public let name: String
    public let image: String
    public let flag: String
    public let ethnicity: String
    public let openskillMu: Double
    public let openskillSigma: Double
}

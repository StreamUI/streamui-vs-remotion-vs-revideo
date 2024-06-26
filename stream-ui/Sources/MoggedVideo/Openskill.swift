//
//  File.swift
//
//
//  Created by Jordan Howlett on 6/26/24.
//

import Foundation

public class OpenSkillHelper {
    public struct Constants {
        public let epsilon: Double
        public let twoBetaSq: Double
        public let beta: Double
        public let betaSq: Double
        public let z: Double
        public let tau: Double
        
        public init(options: [String: Double] = [:]) {
            let z = options["z"] ?? 3
            let mu = options["mu"] ?? 25
            let tau = options["tau"] ?? mu / 300
            let sigma = options["sigma"] ?? mu / z
            let epsilon = options["epsilon"] ?? 0.0001
            let beta = options["beta"] ?? sigma / 2
            let betaSq = pow(beta, 2)
            
            self.epsilon = epsilon
            self.twoBetaSq = 2 * betaSq
            self.beta = beta
            self.betaSq = betaSq
            self.z = z
            self.tau = tau
        }
    }
    
    public struct Rating {
        public let mu: Double
        public let sigma: Double
    }
    
    public typealias Team = [Rating]
    
    let constants: Constants
    
    public init(options: [String: Double] = [:]) {
        self.constants = Constants(options: options)
    }
    
    public func rating(mu: Double? = nil, sigma: Double? = nil) -> Rating {
        let defaultMu = constants.z * constants.beta
        let defaultSigma = defaultMu / constants.z
        return Rating(mu: mu ?? defaultMu, sigma: sigma ?? defaultSigma)
    }
    
    public func predictWin(_ teams: [Team]) -> [Double] {
        let teamRatings = teams.map { team in
            (team.map { $0.mu }.reduce(0, +), team.map { pow($0.sigma, 2) }.reduce(0, +))
        }
        let n = Double(teams.count)
        let denom = (n * (n - 1)) / 2
        
        return teamRatings.enumerated().map { i, ratingA in
            teamRatings.enumerated()
                .filter { $0.offset != i }
                .map { _, ratingB in
                    let muDiff = ratingA.0 - ratingB.0
                    let sigmaSqSum = ratingA.1 + ratingB.1
                    return phiMajor(muDiff / sqrt(n * constants.betaSq + sigmaSqSum))
                }
                .reduce(0, +) / denom
        }
    }
    
    private func phiMajor(_ x: Double) -> Double {
        0.5 * (1 + erf(x / sqrt(2)))
    }
    
    private func erf(_ x: Double) -> Double {
        let t = 1.0 / (1.0 + 0.5 * abs(x))
        let tau = t * exp(-pow(x, 2) - 1.26551223 + 1.00002368 * t + 0.37409196 * pow(t, 2) + 0.09678418 * pow(t, 3) -
            0.18628806 * pow(t, 4) + 0.27886807 * pow(t, 5) - 1.13520398 * pow(t, 6) +
            1.48851587 * pow(t, 7) - 0.82215223 * pow(t, 8) + 0.17087277 * pow(t, 9))
        return x >= 0 ? 1.0 - tau : tau - 1.0
    }
}

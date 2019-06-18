//
//  RandomNumberGenerator.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 18/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import GameKit

class RandomNumberGenerator {
    
    var seedValue: UInt64
    
    let rs = GKMersenneTwisterRandomSource()
    
    init(seedValue: UInt64) {
        self.seedValue = seedValue
        rs.seed = seedValue
    }
    
    func generateNextValue(lowest: Int, highest: Int) -> Int {
        let valueRd = GKRandomDistribution(randomSource: rs, lowestValue: lowest, highestValue: highest)
        let seedRd = GKRandomDistribution(randomSource: rs, lowestValue: 1000, highestValue: 9999)
        
        seedValue = UInt64(seedRd.nextInt())
        let value = valueRd.nextInt()
        return value
    }

}




//
//  StringExtensions.swift
//  COMP90018_APP
//
//  Created by Shuyu Chen on 5/11/2023.
//

import Foundation

// String+Levenshtein.swift
extension String {
    func levenshteinDistance(to string: String) -> Int {
        let empty = Array(repeating: 0, count: string.count)
        var last = [Int](0...string.count)

        for (i, selfChar) in self.enumerated() {
            var cur = [i + 1] + empty
            for (j, stringChar) in string.enumerated() {
                cur[j + 1] = selfChar == stringChar ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last.last!
    }
    
    func fuzzyMatch(_ query: String) -> Bool {
        let distance = self.lowercased().levenshteinDistance(to: query.lowercased())
        let threshold = 1 // Adjust the threshold to make matching more or less strict
        return distance <= threshold
    }
}


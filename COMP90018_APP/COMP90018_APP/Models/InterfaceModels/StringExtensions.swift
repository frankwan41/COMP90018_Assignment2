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
            let lowercasedSelf = self.lowercased()
            let lowercasedQuery = query.lowercased()
            
            //check the string is contained
            if lowercasedSelf.contains(lowercasedQuery) {
                return true
            }
            
            //if not, use Levenshtein do fuzzy search
            let distance = lowercasedSelf.levenshteinDistance(to: lowercasedQuery)
            let threshold = 1 // Can be modified
            return distance <= threshold
        }
    }

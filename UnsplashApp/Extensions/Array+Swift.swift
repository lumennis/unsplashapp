//
//  Array+Swift.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

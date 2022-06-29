//
//  DL.swift
//  BCForwardChallenge
//
//  Created by developer on 6/23/22.
//

import Foundation
protocol Loadable {
    func getPriceTypes() -> [PriceType?]?
    func getProducts() -> [Product?]?
}

struct DataRequest: Loadable {
    var data: String
    init(data: String) {
        self.data = data
    }
    
    func getPriceTypes() -> [PriceType?]? {
        parseLinesBy(prefix: .priceType).map { PriceTypeParser($0) }
    }
    
    func getProducts() -> [Product?]? {
        parseLinesBy(prefix: .product).map { ProductParser($0) }
    }
    
    func parseLinesBy(prefix: InputName) -> [String] {
        let lines: [String]
        switch prefix {
        case .priceType:
            lines = data.components(separatedBy: "\n")
        case .product:
            lines = data.components(separatedBy: "\n").reversed()
        }
        var result = Array<String>()
        for line in lines {
            if line.hasPrefix(prefix.rawValue) {
                result.append(line)
            } else if line.count > 0 {
                break
            }
        }
        return result
    }
}

enum InputName: String {
    case priceType = "Type"
    case product = "Product"
}

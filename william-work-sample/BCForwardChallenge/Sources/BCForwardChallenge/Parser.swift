//
//  Parser.swift
//  BCForwardChallenge
//
//  Created by developer on 6/23/22.
//

import Foundation

let ProductParser: (String) -> Product? = {
    data in
    let columns = data.components(separatedBy: ",")
    if columns.count == 5 {
        return Product(normalPrice: Double(columns[1]), clearancePrice: Double(columns[2]), quantity: Int(columns[3]), priceInCart: Bool(columns[4]))
    }
    return nil
}

let PriceTypeParser: (String) -> PriceType? = {
    data in
    let columns = data.components(separatedBy: ",")
    if columns.count == 3 {
        return PriceType(priceCategory: (columns[1], columns[2]))
    }
    return nil
}

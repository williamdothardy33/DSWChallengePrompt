//
//  BL.swift
//  BCForwardChallenge
//
//  Created by developer on 6/23/22.
//

import Foundation
struct Report {
    var dataRequest: Loadable
    init(dataRequest: Loadable) {
        self.dataRequest = dataRequest
    }
    
    func isClearance(product: Product?) -> Bool {
        let result = product?.normalPrice.flatMap {
            normalPrice in
            product?.clearancePrice.map {
                clearancePrice in
                clearancePrice < normalPrice
            }
        }
        if let result = result {
            return result
        }
        return false
    }
    
    func isNormal(product: Product?) -> Bool {
        let result = product?.normalPrice.flatMap {
            normalPrice in
            product?.clearancePrice.map {
                clearancePrice in
                clearancePrice == normalPrice
            }
        }
        if let result = result {
            return result
        }
        return false
    }
    
    func isPriceInCart(product: Product?) -> Bool {
        return product?.priceInCart ?? false
    }
    
    func minMax(products: [Product?]?, filteredValue: (Product?) -> Double?) -> (Double, Double)? {
        guard let products = products  else { return nil }
        
        let nonNilProduct: [Product] = products.compactMap { $0 }
        if nonNilProduct.isEmpty {
            return nil
        }
        
        let productFilteredValues: [Double] = nonNilProduct.compactMap {
            filteredValue($0)
        }
        if productFilteredValues.isEmpty {
            return nil
        }
        
        guard let initialValue = productFilteredValues.first else { return nil }
        
        let initialMinMax: (min: Double, max: Double) = (initialValue, initialValue)
        
        return productFilteredValues.reduce(initialMinMax) {
            result, next in
            return (min(next, result.min), max(next, result.max))
        }
    }
    
    func partitionProducts(products: [Product?]?, predicate: (Product?) -> Bool) -> Array<Product>.SubSequence? {
        guard let products = products  else { return nil }
        
        var nonNilProduct: [Product] = products.compactMap { $0 }
        if nonNilProduct.isEmpty {
            return nil
        }
        let pivotIndex = nonNilProduct.partition(by: {
            product in
            predicate(product)
        })
        let binnedProducts = nonNilProduct[pivotIndex...]
        return binnedProducts
    }
    
    func reportHelper(binned: ([Product]?, (Product?) -> Double?, String)) -> String {
        guard let product = binned.0 else {return ""}
        let binLabel = binned.2
        let minMax = minMax(products: product, filteredValue: binned.1)
        let min = minMax?.0
        let max = minMax?.1
        var minMaxString: String
        if min == nil && max == nil {
            minMaxString = ""
        } else if min == max {
            minMaxString = "$\(min!)"
        } else {
            minMaxString = "$\(min!)-$\(max!)"
        }
        let count = binned.0?.count ?? 0
        let productDescription = (count != 1) ? "products" : "product"
        if count == 0 {
            return "\(binLabel): \(count) \(productDescription)"
        }
        
        let priceRangePrefix = (count != 0) ? "@" : ""
        return "\(binLabel): \(count) \(productDescription) \(priceRangePrefix) \(minMaxString)"
    }
    
    func generateCategories() -> [((Product?) -> Bool, (Product?) -> Double?, String)] {
        let types: [PriceType?]? = dataRequest.getPriceTypes()
        
        let normalMinMax: (Product?) -> Double? = {
            product in
            product?.normalPrice
        }
        
        let clearanceMinMax: (Product?) -> Double? = {
            product in
            product?.clearancePrice
        }
        
        let priceInCartMinMax: (Product?) -> Double? = {
            product in
            product?.clearancePrice
        }
        
        guard let types = types else { return [] }
        
        let categories: [((Product?) -> Bool, (Product?) -> Double?, String)] = types.map {
            type in
            let priceCategory = type?.priceCategory?.catagory
            let priceDisplayName = type?.priceCategory?.displayName
            if let priceCategory = priceCategory, let priceDisplayName = priceDisplayName {
                switch (priceCategory.uppercased()) {
                case "NORMAL":
                    return (isNormal, normalMinMax, priceDisplayName)
                case "CLEARANCE":
                    return (isClearance, clearanceMinMax, priceDisplayName)
                case "PRICE_IN_CART":
                    return (isPriceInCart, priceInCartMinMax, priceDisplayName)
                default:
                    return ({ _ in false }, { _ in 0.0 }, "")
                }
            }
            return ({ _ in false }, { _ in 0.0 }, "")
            
        }
        return categories
    }
    
    func generateReport(products: [Product?]?, categories: [(binPredicate: (Product?) -> Bool, minMaxType: (Product?) -> Double?, binLabel: String)]) -> String {
        return categories.map {
            category in
            (partitionProducts(products: products, predicate: category.binPredicate)?.filter {
                $0.quantity ?? 0 > 3
            }, category.minMaxType, category.binLabel)
        }.sorted(by: {
            binnedProducts, nextBinnedProducts in
            (binnedProducts.0 ?? []).count > (nextBinnedProducts.0 ?? []).count
        }).enumerated().reduce("") {
            result, next in
            if next.offset != categories.count - 1 {
                return result + reportHelper(binned: next.element) + "\n"
            }else {
                return result + reportHelper(binned: next.element)
            }
        }
    }
    
    func test() {
        let products = dataRequest.getProducts()
        let categories = generateCategories()
        print(generateReport(products: products, categories: categories))
    }
}

//
//  CollectionStats.swift
//  IndexServiceStatCollector
//
//  Created by Martin Agersted Jarl on 01/11/2016.
//  Copyright © 2016 Martin Agersted Jarl. All rights reserved.
//

import Foundation

struct CollectionStats {
    var collectionId: String
    var processing: Int
    var indexed: Int
    var removed: Int
    var error: Int
    var dropped: Int
    var timestamp: Double
    
    static let headers = [
        "collectionId",
        "processing",
        "indexed",
        "removed",
        "error",
        "dropped",
        "timestamp"
    ]
    
    
    init(collectionId: String, processing: Int, indexed: Int, removed: Int, error: Int, dropped: Int, timestamp: Double) {
        self.collectionId = collectionId
        self.processing = processing
        self.indexed = indexed
        self.removed = removed
        self.error = error
        self.dropped = dropped
        self.timestamp = timestamp
    }
    
    init?(data: Data) {
        guard
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDict = jsonObj as? [String : Any],
            let collectionId = jsonDict["collectionId"] as? String,
            let docStatsDict = jsonDict["documentStatusCounts"] as? [String : Any],
            let processing = docStatsDict["PROCESSING"] as? Int,
            let indexed = docStatsDict["INDEXED"] as? Int,
            let removed = docStatsDict["REMOVED"] as? Int,
            let error = docStatsDict["ERROR"] as? Int,
            let dropped = docStatsDict["DROPPED"] as? Int
            else {
                print("Error: Not able to init with data.")
                return nil
        }
        
        self.collectionId = collectionId
        self.processing = processing
        self.indexed = indexed
        self.removed = removed
        self.error = error
        self.dropped = dropped
        self.timestamp = Date().timeIntervalSince1970
    }
    
    
    var humanDate: Date {
        return Date(timeIntervalSince1970: self.timestamp)
    }
    
    var description: String {
        return "collectionId:\n\(collectionId)\nprocessing: \(processing)\nindexed: \(indexed)\nerror: \(error)\ntime: \(humanDate)"
    }
    
    var onlineDesc: String {
        return "\(collectionId) : t = \(humanDate) p = \(processing), i = \(indexed), r = \(removed), e = \(error)"
    }
    
    static public func csvHeaders(delimiter: String) -> String {
        var out: String = ""
        for (index, header) in CollectionStats.headers.enumerated() {
            out += header
            if index < CollectionStats.headers.count-1 {
                out += "\(delimiter) "
            }
        }
        return out + "\n"
    }
    
    public func csvValues(delimiter: String) -> String {
        return "\(collectionId)\(delimiter) \(humanDate)\(delimiter) \(processing)\(delimiter) \(indexed)\(delimiter) \(removed)\(delimiter) \(error)\n"
    }
    
    
    
    
}



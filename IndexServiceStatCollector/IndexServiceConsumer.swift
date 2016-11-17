//
//  IndexServiceConsumer.swift
//  IndexServiceStatCollector
//
//  Created by Martin Agersted Jarl on 29/09/2016.
//  Copyright © 2016 Martin Agersted Jarl. All rights reserved.
//

import Foundation


// See: https://talk.objc.io/episodes/S01E01-networking
// See: http://allkfw02:8080/rest/docweb_documents/summary.json

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A? // We might not have something, hence optional
}

class IndexServiceConsumer {
    
    let summaryResource: Resource<Data>!
    
    
    init(indexServiceUrl: URL) {
        self.summaryResource = Resource<Data>(url: indexServiceUrl) { data in
            return data }
    }
    
    
    
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { (data, _, _) in // Need ( )?
            if let data = data {
                completion(resource.parse(data))
            } else {
                completion(nil)
            }
        }.resume() // Starting to get
    }
    
    
    
    
    
}












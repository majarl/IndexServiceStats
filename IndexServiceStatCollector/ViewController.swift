//
//  ViewController.swift
//  IndexServiceStatCollector
//
//  Created by Martin Agersted Jarl on 29/09/2016.
//  Copyright © 2016 Martin Agersted Jarl. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    
    var statSerie: [CollectionStats] = [CollectionStats]() {
        didSet {
            print("\(#function): didSet")
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var endpointUrl: NSTextField! {
        didSet {
            print("Setting")
        }
    }
    
    
    @IBAction func indexServiceEndpointUrlCanged(_ sender: Any) {
        print("\(#function): \(self.endpointUrl.stringValue)")
    }

    
    private struct DefaultEndpoints {
        static let nirasEndPoint02_docweb = "http://allkfw02:8080/rest/docweb_documents/summary.json"
        static let nirasEndPoint03_docweb = "http://allkfw03:8080/rest/docweb_documents/summary.json"
        static let localhost_docweb = "http://localhost:8080/rest/docweb_documents/summary.json"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.endpointUrl.stringValue = DefaultEndpoints.nirasEndPoint02_docweb
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    var repeater: Timer?
    var counter = 0
    
    @IBAction func startReadStatsLoop(_ sender: Any) {
        print("startReadStatsLoop")
        retrieveStats()
        
        if self.repeater != nil {
            self.repeater?.invalidate()
            counter = 0
        }
        
        self.repeater = Timer(timeInterval: 10, repeats: true, block: { (timer) in
            self.counter += 1
            self.retrieveStats()
        })
        
        let rl: RunLoop = RunLoop.current
        rl.add(self.repeater!, forMode: RunLoopMode.defaultRunLoopMode)
    }

    
    @IBAction func readStatsAction(_ sender: NSButton) {
        retrieveStats()
    }
    
    
    
    private func retrieveStats() {
        if let url: URL = URL(string: self.endpointUrl.stringValue) {
            let isc = IndexServiceConsumer(indexServiceUrl: url)
            
            isc.load(resource: isc.summaryResource) { (result) in
                if let r = result {
                    if let collectionStat = CollectionStats(data: r) {
                        print("CollectionStat: \(collectionStat.onlineDesc)")
                        self.statSerie.append(collectionStat)
                    }
                }
            }
        }
        
    }
    
    
    // MARK: - Table view
    
    @IBOutlet weak var mainTableView: NSTableView!
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("\(#function)")
        return self.statSerie.count
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("\(#function): Identifier: \(tableColumn?.identifier)")

        let value: CollectionStats = self.statSerie[row]

        if let colIdent = tableColumn?.identifier {
            let cellIdent : String = {
                switch colIdent {
                case "COL_TIME": return "CELL_TIME"
                case "COL_PROCESSING": return "CELL_PROCESSING"
                case "COL_INDEXED": return "CELL_INDEXED"
                case "COL_REMOVED": return "CELL_REMOVED"
                case "COL_ERROR": return "CELL_ERROR"
                default: return ""
                }
            }()
            
            if let cell = tableView.make(withIdentifier: cellIdent, owner: self) as? NSTableCellView {
                cell.textField?.stringValue = "Noget"
                return cell
            }
        }
        

        return nil
    }
    
    

    
    


}

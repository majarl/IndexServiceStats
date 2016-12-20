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
                if self.numberOfRows(in: self.mainTableView) > 0 {
                    self.mainTableView.scrollRowToVisible(self.numberOfRows(in: self.mainTableView) - 1)
                }
            }
        }
    }
    
    
    private func mockStatData() {
        self.statSerie.append(CollectionStats(collectionId: "TestCollection", processing: 2, indexed: 2, removed: 2, error: 2, dropped: 2, timestamp: 2.3))
        self.statSerie.append(CollectionStats(collectionId: "TestCollection", processing: 12, indexed: 2, removed: 2, error: 2, dropped: 2, timestamp: 2.5))
        self.statSerie.append(CollectionStats(collectionId: "TestCollection", processing: 45, indexed: 2, removed: 2, error: 2, dropped: 2, timestamp: 2.8))
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
        // self.mockStatData()
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
        if let c = tableView.make(withIdentifier: "C_time", owner: nil) as? NSTableCellView,
            let tc = tableColumn {

            let cs = self.statSerie[row]
            let val: String = {
                switch tc.identifier {
                case "COL_time": return "\(cs.humanDate)"
                case "COL_processing": return "\(cs.processing)"
                case "COL_indexed": return "\(cs.indexed)"
                case "COL_removed": return "\(cs.removed)"
                case "COL_error": return "\(cs.error)"
                default: return "Nada"
                }
            }()
            
            c.textField?.stringValue = val
            return c
        }
        
        return nil
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tview: NSTableView = notification.object as? NSTableView {
            let itemsSelected = tview.selectedRowIndexes.count
            if itemsSelected > 0 {
                putRowsToPasteboard(selectedRows: tview.selectedRowIndexes)
            }
        }
    }
    
    

    // MARK: - Copying and Selecting
    
    func putRowsToPasteboard(selectedRows: IndexSet) {
        var pbText: String = CollectionStats.csvHeaders(delimiter: ";")
        for idx in selectedRows {
            pbText += self.statSerie[idx].csvValues(delimiter: ";")
            print(pbText)
        }

        let pboard = NSPasteboard.general()
        pboard.declareTypes([NSStringPboardType], owner: nil)
        if pboard.writeObjects([pbText as NSPasteboardWriting]) {
            print("\(#function) : \(#line) - Copied to PasteBoard")
        } else {
            print("\(#function) : \(#line) - Warning: No copying")
        }
    }
    
    
    func copy(_ sender: AnyObject?) {
        print("\(#function): \(#line) - ")
        print("    \(sender)")
        
    }
    
    
    
    


}

//
//  TableViewController.swift
//  HowToUseDataSource
//
//  Created by 1amageek on 2019/08/21.
//  Copyright © 2019 Stamp. All rights reserved.
//

import UIKit
import Firebase
import Ballcap

class TableViewController: UITableViewController {

    var dataSource: DataSource<Document<Item>>?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))

        self.dataSource = Document<Item>.query
        .order(by: "updatedAt", descending: true)
        .limit(to: 3)
        .dataSource()
        .retrieve(from: { (snapshot, documentSnapshot, done) in
            let document: Document<Item> = Document(documentSnapshot.reference)
            document.get { (item, error) in
                done(item!)
            }
        })
        .onChanged({ (snapshot, dataSourceSnapshot) in
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: dataSourceSnapshot.changes.insertions.map { IndexPath(item: dataSourceSnapshot.after.firstIndex(of: $0)!, section: 0)}, with: .automatic)
                self.tableView.deleteRows(at: dataSourceSnapshot.changes.deletions.map { IndexPath(item: dataSourceSnapshot.before.firstIndex(of: $0)!, section: 0)}, with: .automatic)
                self.tableView.reloadRows(at: dataSourceSnapshot.changes.modifications.map { IndexPath(item: dataSourceSnapshot.after.firstIndex(of: $0)!, section: 0)}, with: .automatic)
            }, completion: nil)
        })
        .listen()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "UITableViewCell")
        cell.textLabel?.text = self.dataSource?[indexPath.item].data?.name
        return cell
    }

    @objc func add() {
        let item: Document<Item> = Document()
        item.data?.name = "\(Date())"
        item.save()
    }
}

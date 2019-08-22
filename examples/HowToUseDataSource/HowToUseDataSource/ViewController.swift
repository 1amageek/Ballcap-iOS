//
//  ViewController.swift
//  HowToUseDataSource
//
//  Created by 1amageek on 2019/08/19.
//  Copyright © 2019 Stamp. All rights reserved.
//

import UIKit
import Ballcap
import Firebase

struct DocumentProxy<Model: Modelable & Codable>: Hashable {

    var id: String {
        document.id
    }

    var createdAt: Timestamp {
        document.createdAt
    }

    var updatedAt: Timestamp {
        document.updatedAt
    }

    var document: Document<Model>

    init(document: Document<Model>) {
        self.document = document
    }

}

class ViewController: UIViewController {

    enum Section: CaseIterable {
        case main
    }

    @IBOutlet weak var tableView: UITableView!

    var dataSource: DataSource<Document<Item>>?

    var tableViewDataSource: UITableViewDiffableDataSource<Section, DocumentProxy<Item>>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextPage)),
            UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
        ]
        
        self.tableViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in

            let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell.textLabel?.text = self.dataSource?[indexPath.item].data?.name
            return cell
        })

        var snapshot: NSDiffableDataSourceSnapshot<Section, DocumentProxy<Item>> = NSDiffableDataSourceSnapshot()
        snapshot.appendSections([.main])
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true)

        self.dataSource = Document<Item>.query
            .order(by: "updatedAt", descending: true)
            .limit(to: 3)
            .dataSource()
            .sorted(by: {$0.createdAt < $1.createdAt})
            .retrieve(from: { (snapshot, documentSnapshot, done) in
                let document: Document<Item> = Document(documentSnapshot.reference)
                document.get { (item, error) in
                    done(item!)
                }
            })
            .onChanged({ (snapshot, dataSourceSnapshot) in
                var snapshot: NSDiffableDataSourceSnapshot<Section, DocumentProxy<Item>> = self.tableViewDataSource.snapshot()
                snapshot.deleteItems(dataSourceSnapshot.before.map { DocumentProxy(document: $0)})
                snapshot.appendItems(dataSourceSnapshot.after.map { DocumentProxy(document: $0)})
//                snapshot.appendItems(dataSourceSnapshot.changes.insertions.map { DocumentProxy(document: $0)})
//                snapshot.deleteItems(dataSourceSnapshot.changes.deletions.map { DocumentProxy(document: $0)})
//                snapshot.reloadItems(dataSourceSnapshot.changes.modifications.map { DocumentProxy(document: $0)})
                self.tableViewDataSource.apply(snapshot, animatingDifferences: true)
            })
            .listen()
    }

    var index: Int = 0

    @objc func add() {
        let item: Document<Item> = Document()
        item.data?.name = "\(index)"
        item.save()
        index += 1
    }

    @objc func nextPage() {
        self.dataSource?.next()
    }

    @objc func reload() {
        self.tableView.reloadData()
    }
}


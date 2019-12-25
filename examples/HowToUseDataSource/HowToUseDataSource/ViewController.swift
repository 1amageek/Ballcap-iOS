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

class ViewController: UIViewController, UITableViewDelegate {

    enum Section: CaseIterable {
        case main
    }

    @IBOutlet weak var tableView: UITableView!

    var dataSource: DataSource<Document<Item>>?

    var tableViewDataSource: UITableViewDiffableDataSource<Section, Document<Item>>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
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

        var snapshot: NSDiffableDataSourceSnapshot<Section, Document<Item>> = NSDiffableDataSourceSnapshot()
        snapshot.appendSections([.main])
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true)

        self.dataSource = Document<Item>.query
            .order(by: "updatedAt", descending: true)
            .limit(to: 10)
            .dataSource()
            .sorted(by: {$0.updatedAt < $1.updatedAt})
            .onChanged({ (snapshot, dataSourceSnapshot) in
                var snapshot: NSDiffableDataSourceSnapshot<Section, Document<Item>> = self.tableViewDataSource.snapshot()
                snapshot.deleteItems(dataSourceSnapshot.before.map { $0 })
                snapshot.appendItems(dataSourceSnapshot.after.map { $0 })
                self.tableViewDataSource.apply(snapshot, animatingDifferences: true)
            })
            .listen()
    }

    var index: Int = 0
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item: Document<Item> = self.dataSource?[indexPath.item] else { return }
        item.update()
    }

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


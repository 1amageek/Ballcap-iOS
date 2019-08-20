//
//  ViewController.swift
//  HowToUseDataSource
//
//  Created by 1amageek on 2019/08/19.
//  Copyright © 2019 Stamp. All rights reserved.
//

import UIKit
import Ballcap

class Obj: Hashable {

    static func == (lhs: Obj, rhs: Obj) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    var id: String = UUID().uuidString

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class ViewController: UIViewController {

    enum Section: CaseIterable {
        case main
    }

    @IBOutlet weak var tableView: UITableView!

    var dataSource: DataSource<Document<Item>>?

    var tableViewDataSource: UITableViewDiffableDataSource<Section, Obj>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))

        self.tableViewDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in

            let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell.textLabel?.text = item.id
            return cell
        })

        let docs: [Obj] = [Obj(), Obj(), Obj()]

        var snapshot: NSDiffableDataSourceSnapshot<Section, Obj> = NSDiffableDataSourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(docs)
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true)


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
            .onChanged({ (snapshot, changes) in
//                var snapshot: NSDiffableDataSourceSnapshot<Section, Document<Item>> = self.tableViewDataSource.snapshot()
////                snapshot.deleteAllItems()
////                snapshot.appendSections([.main])
////                snapshot.appendItems(self.dataSource!.documents)
//
//                print(snapshot.itemIdentifiers(inSection: .main).map { $0.hashValue })
//                print("insertions", changes.insertions.map { $0.hashValue })
//                print("modifications", changes.modifications.map { $0.hashValue })
////
//                snapshot.appendItems(changes.insertions)
////                snapshot.deleteItems(changes.deletions)
//                snapshot.reloadItems(changes.modifications)
//
//                self.tableViewDataSource.apply(snapshot, animatingDifferences: true)
            })
//            .onCompleted({ [weak self] (snapshot, items) in
//                print(snapshot?.documents)
//                print(snapshot?.documentChanges)
//                let snapshot: NSDiffableDataSourceSnapshot<Section, Document<Item>> = NSDiffableDataSourceSnapshot()
//                snapshot.appendSections([.main])
//                snapshot.appendItems(items)
//                self?.tableViewDataSource.apply(snapshot, animatingDifferences: true)
//            })
            .listen()


    }

    @objc func add() {
//        let item: Document<Item> = Document()
//        item.data?.name = "\(Date())"
//        item.save()

        var snapshot: NSDiffableDataSourceSnapshot<Section, Obj> = self.tableViewDataSource.snapshot()
//        let doc = snapshot.itemIdentifiers(inSection: .main).first!
//        print(doc.documentReference.path, doc.hashValue)
//        let document: Document<Item> = Document(doc.documentReference)
//        print(document.documentReference.path, document.hashValue)
//        snapshot.reloadItems([document])


        let obj = snapshot.itemIdentifiers(inSection: .main).first!
        var reloadObj = Obj()
        reloadObj.id = obj.id

        print(reloadObj.hashValue, obj.hashValue)
        snapshot.reloadItems([reloadObj])
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true)
    }
}


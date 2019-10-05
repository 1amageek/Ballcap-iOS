//
//  FileCacheable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/10/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import Foundation

public protocol FileCacheable {

}

public extension FileCacheable where Self: DataRepresentable, Self: Object {

    func load(keyPath: WritableKeyPath<Model, File?>) {
        if let file: File = self.data?[keyPath: keyPath] {
            if file.data == nil {
                if file.downloadTask == nil {
                    file.getData { (data, error) in
                        self[keyPath] = file
                    }
                }
            } else {
                self[keyPath] = file
            }
        }
    }

    func cancel(_ keyPath: WritableKeyPath<Model, File?>) {
        if let file: File = self.data?[keyPath: keyPath] {
            file.downloadTask?.cancel()
        }
    }
}

//
//  File+View.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/10/04.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI
import Ballcap

extension File: View {

    public var body: FileView {
        FileView(file: self)
    }
}

public class FileLoader: FileRepresentable, ObservableObject {

    @Published public var file: File

    init(_ file: File) {
        self.file = file
        if file.data == nil {
            self.load()
        }
    }
}

public struct FileView: View {

    @ObservedObject public var fileLoader: FileLoader

    init(file: File) {
        self.fileLoader = FileLoader(file)
    }

    var configurations: [(Image) -> Image] = []

    public var body: some View {
        print("body")
        let image: Image
        if fileLoader.file.data != nil {
            print("wwwww")
            image = Image(uiImage: UIImage(data: fileLoader.file.data!)!)
        } else {
            print("aaaaa")
            image = Image(uiImage: UIImage())
        }
        return configurations.reduce(image) { (previous, configuration) in
                configuration(previous)
            }
            .onDisappear {
                self.fileLoader.cancel()
        }

    }
}

extension File {
    /// Configurate this view's image with the specified cap insets and options.
    /// - Parameter capInsets: The values to use for the cap insets.
    /// - Parameter resizingMode: The resizing mode
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> FileView
    {
        return self.body.resizable(capInsets: capInsets, resizingMode: resizingMode)
    }

    /// Configurate this view's rendering mode.
    /// - Parameter renderingMode: The resizing mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> FileView {
        return self.body.renderingMode(renderingMode)
    }
}

extension FileView {

    func configure(_ block: @escaping (Image) -> Image) -> FileView {
        var result = self
        result.configurations.append(block)
        return result
    }

    /// Configurate this view's image with the specified cap insets and options.
    /// - Parameter capInsets: The values to use for the cap insets.
    /// - Parameter resizingMode: The resizing mode
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> FileView
    {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    /// Configurate this view's rendering mode.
    /// - Parameter renderingMode: The resizing mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> FileView {
        configure { $0.renderingMode(renderingMode) }
    }

    /// Configurate this view's image interpolation quality
    /// - Parameter interpolation: The interpolation quality
    public func interpolation(_ interpolation: Image.Interpolation) -> FileView {
        configure { $0.interpolation(interpolation) }
    }

    /// Configurate this view's image antialiasing
    /// - Parameter isAntialiased: Whether or not to allow antialiasing
    public func antialiased(_ isAntialiased: Bool) -> FileView {
        configure { $0.antialiased(isAntialiased) }
    }
}

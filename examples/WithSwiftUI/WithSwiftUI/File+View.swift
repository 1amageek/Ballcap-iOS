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

public struct FileView: View, FileRepresentable {

    @State public var file: File

    var configurations: [(Image) -> Image] = []

    public var body: some View {
        let image: Image
        if file.data != nil {
            image = Image(uiImage: UIImage(data: file.data!)!)
        } else {
            image = Image(uiImage: UIImage())
        }
        return configurations.reduce(image) { (previous, configuration) in
            configuration(previous)
        }
        .onAppear {
            self.load { (_, _) in

            }
        }
        .onDisappear {
            self.cancel()
        }
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

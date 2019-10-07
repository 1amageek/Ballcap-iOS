//
//  File+View.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/10/04.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI
import Ballcap
import Combine

extension File: View, ObservableObject {

    public var body: Image {
        if self.cache != nil {
            return Image(uiImage: UIImage(data: self.cache!)!)
        } else if self.data != nil {
            return Image(uiImage: UIImage(data: self.data!)!)
        } else {
            return Image(uiImage: UIImage())
        }
    }

    public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> Image {
        self.body.resizable(capInsets: capInsets, resizingMode: resizingMode)
    }

    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Image {
        self.body.renderingMode(renderingMode)
    }
}

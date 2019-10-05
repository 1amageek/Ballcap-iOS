//
//  ImagePicker.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/10/04.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI
import Ballcap

struct ImagePicker: UIViewControllerRepresentable {

    var completion: (Data) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }

    func updateUIViewController(_ pageViewController: UIImagePickerController, context: Context) {

    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker?

        init(_ controller: ImagePicker) {
            self.parent = controller
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            let imageData: Data = image.jpegData(compressionQuality: 0.3)!
            picker.dismiss(animated: true, completion: nil)
            self.parent?.completion(imageData)
            self.parent = nil
        }

    }
}


struct ImagePicker_Previews: PreviewProvider {

    static var previews: some View {
        ImagePicker { data in

        }
    }
}

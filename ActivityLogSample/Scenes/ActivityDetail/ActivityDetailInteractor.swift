//
//  ActivityDetailInteractor.swift
//  ActivityLogSample
//
//  Created by Simon Kim on 7/11/20.
//  Copyright © 2020 KineMaster Crop. All rights reserved.
//

import UIKit

protocol ActivityDetailView: AnyObject {
    func update(with model: Activity)
}

enum ActivityDetailAction {
    case loadInitialData
    case pickPhoto
    case changeTitle(String)
    case changeProgress(Double)
    case changeNote(String)
    case save
}

class ActivityDetailInteractor {
    private weak var view: ActivityDetailView?
    var model = Activity()

    var computeAIColorSchemeFrom: (_ image: UIImage) -> ColorScheme = { _ in
        let colorPairs = [
            ColorScheme(.rgb(249, 42, 130), .rgb(126, 183, 127)),
            ColorScheme(.rgb(44, 19, 32), .rgb(86, 102, 122)),
        ]
        
        return colorPairs.randomElement()!
    }

    var saveData: (_ model: Activity ) -> Void = { model in
        print("title: \(String(describing: model.title))")
        print("progress: \(model.progress)")
        print("photo: \(String(describing: model.photo))")
        print("note: \(String(describing: model.note))")
    }
    
    init(view: ActivityDetailView) {
        self.view = view
    }
    
    func send(_ action: ActivityDetailAction) {
        switch(action) {
        case .loadInitialData:
            present()
            
        case .changeTitle(let title):
            model.title = title
            present()
            
        case .pickPhoto:
            pickPhoto { image in
                guard let image = image else {
                    return
                }
                model.photo = image
                model.colorScheme = computeAIColorSchemeFrom(image)
                present()
            }

        case .changeProgress(let progress):
            model.progress = progress

        case .changeNote(let note):
            model.note = note
            
        case .save:
            guard model.isValidForSaving else {
                return
            }
            saveData(model)
        }
    }
    
    private func present() {
        view?.update(with: model)
    }

    private func pickPhoto(completion: (_ image: UIImage?) -> Void) {
        // mock photo picker
        let pickedImageURL = URL(string: "https://via.placeholder.com/90x90.png?text=I+Did+It")!
        do {
            let data = try Data(contentsOf: pickedImageURL)
            completion(UIImage(data: data))
        } catch _ {
            completion(nil)
        }
    }

}

//
//  ActivityDetailViewController.swift
//  ActivityLogSample
//
//  Created by Simon Kim on 7/10/20.
//  Copyright © 2020 KineMaster Crop. All rights reserved.
//

import UIKit

// Photo = "Place holder"
// Title = "Just Did!"
//  - Progress      Slider      %
// Note = "(optional)
// 1. Input: Photo, Title, Progress, Note
// 2. Allow Save: (Photo, TItle) are entered
class ActivityDetailViewController: UITableViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    lazy var cancelButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel(_:)))
    }()
    
    lazy var saveButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(_:)))
        item.isEnabled = false
        return item
    }()

    
    var isPhotoSet = false
    
    override func viewDidLoad() {
        title = "Activity Detail"
        
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = saveButtonItem
        
        photoView.contentMode = .center
        photoView.image = UIImage(systemName: "plus.square.fill")?
            .resizing(CGSize(width: 20, height: 20))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto(_:)))
        photoView.addGestureRecognizer(tap)
        
    }
    
    @objc
    func didTapPhoto(_ sender: UIImageView) {
        
        pickPhoto { image in
            guard let image = image else {
                return
            }
            photoView.image = image
            photoView.contentMode = .scaleAspectFit

            isPhotoSet = true
            updateBackButton()
        }
    }
        
    @IBAction func didEditTitle(_ sender: Any) {
        updateBackButton()
    }
    
    @IBAction func didChangeProgress(_ sender: UISlider) {
        valueLabel.text = "\(round(sender.value * 100)) %"
    }
    
    @objc func didTapCancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSave(_ sender: UIBarButtonItem) {
        guard isPhotoSet && (titleTextField.text?.count ?? 0) > 0 else {
            return
        }
        saveData()
        navigationController?.popViewController(animated: true)
    }
    
    private func updateBackButton() {
        saveButtonItem.isEnabled = isPhotoSet && (titleTextField.text?.count ?? 0) > 0
    }
        
    private func saveData() {
        print("title: \(String(describing: titleTextField.text))")
        print("progress: \(String(describing: valueLabel.text))")
        print("photo: \(String(describing: photoView.image))")
        print("note: \(String(describing: noteTextView.text))")
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

extension UIImage {
    func resizing(_ size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: rect)
        }
    }
}

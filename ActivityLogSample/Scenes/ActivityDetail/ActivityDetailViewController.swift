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
struct Activity {
    var title: String = ""
    var photo: UIImage?
    var progress: Double = 0
    var note: String?
    var colorScheme: ColorScheme?
    
    var isPhotoSet: Bool { photo != nil }
    var isValidForSaving: Bool { isPhotoSet && title.count > 0 }
}

struct ColorScheme {
    let foreground: UIColor
    let background: UIColor
    
    init(_ foreground: UIColor, _ background: UIColor) {
        self.foreground = foreground
        self.background = background
    }
}

extension UIColor {
    static func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
}

class ActivityDetailViewController: UITableViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var labelNote: UILabel!
    
    var model = Activity()
    
    lazy var cancelButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel(_:)))
    }()
    
    lazy var saveButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(_:)))
        item.isEnabled = false
        return item
    }()
    
    var computeAIColorSchemeFrom: (_ image: UIImage) -> ColorScheme = { _ in
        let colorPairs = [
            ColorScheme(.rgb(249, 42, 130), .rgb(126, 183, 127)),
            ColorScheme(.rgb(44, 19, 32), .rgb(86, 102, 122)),
        ]
        
        return colorPairs.randomElement()!
    }

    override func viewDidLoad() {
        title = "Activity Detail"
        
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = saveButtonItem
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto(_:)))
        photoView.addGestureRecognizer(tap)
        
        updateView()
    }
        
    @objc
    func didTapPhoto(_ sender: UIImageView) {
        
        pickPhoto { image in
            guard let image = image else {
                return
            }
            model.photo = image
            model.colorScheme = computeAIColorSchemeFrom(image)
            updateView()
        }
    }
        
    @IBAction func didEditTitle(_ sender: UITextField) {
        model.title = sender.text ?? ""
        updateView()
    }
    
    @IBAction func didChangeProgress(_ sender: UISlider) {
        model.progress = Double(sender.value)
        updateView()
    }
    
    @objc func didTapCancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSave(_ sender: UIBarButtonItem) {
        model.note = noteTextView.text
        
        guard model.isValidForSaving else {
            return
        }
        saveData()
        navigationController?.popViewController(animated: true)
    }
    
    private func updateView() {
        titleTextField.text = model.title
        if let photo = model.photo {
            photoView.image = photo
            photoView.contentMode = .scaleAspectFit
            
        } else {
            photoView.image = UIImage(systemName: "plus.square.fill")?
                .resizing(CGSize(width: 20, height: 20))
            photoView.contentMode = .center
        }
        valueSlider.value = Float(model.progress)
        valueLabel.text = "\(round(model.progress * 100)) %"
        noteTextView.text = model.note
        
        if let scheme = model.colorScheme {
            titleTextField.textColor = scheme.foreground
            titleTextField.backgroundColor = scheme.background
            
            valueLabel.textColor = scheme.foreground
            labelProgress.textColor = scheme.foreground
            labelNote.textColor = scheme.foreground
            
            valueSlider.backgroundColor = scheme.background
            noteTextView.backgroundColor = scheme.background
            for row in 0..<tableView.numberOfRows(inSection: 0) {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
                cell?.backgroundColor = scheme.background
            }
            view.backgroundColor = scheme.background
        }
        
        updateBackButton()
    }
        
    private func updateBackButton() {
        saveButtonItem.isEnabled = model.isPhotoSet && (model.title.count > 0)
    }
    
    private func saveData() {
        print("title: \(String(describing: model.title))")
        print("progress: \(model.progress)")
        print("photo: \(String(describing: model.photo))")
        print("note: \(String(describing: model.note))")
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

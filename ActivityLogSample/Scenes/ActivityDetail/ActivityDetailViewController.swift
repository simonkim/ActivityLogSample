//
//  ActivityDetailViewController.swift
//  ActivityLogSample
//
//  Created by Simon Kim on 7/10/20.
//  Copyright © 2020 KineMaster Crop. All rights reserved.
//

import UIKit

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

extension ActivityDetailViewController: ActivityDetailView {
    
}

class ActivityDetailViewController: UITableViewController {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var labelNote: UILabel!
    
    lazy var cancelButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel(_:)))
    }()
    
    lazy var saveButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave(_:)))
        item.isEnabled = false
        return item
    }()
    
    var interactor: ActivityDetailInteractor!
    override func awakeFromNib() {
        interactor = ActivityDetailInteractor(view: self)
    }
    
    override func viewDidLoad() {
        title = "Activity Detail"
        
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = saveButtonItem
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto(_:)))
        photoView.addGestureRecognizer(tap)
        noteTextView.delegate = self
        interactor.send(.loadInitialData)
    }
        
    @objc
    func didTapPhoto(_ sender: UIImageView) {
         interactor.send(.pickPhoto)
    }
        
    @IBAction func didEditTitle(_ sender: UITextField) {
        interactor.send(.changeTitle(sender.text ?? ""))
    }
    
    @IBAction func didChangeProgress(_ sender: UISlider) {
        interactor.send(.changeProgress(Double(sender.value)))
    }
    
    func textViewDidChange(_ textView: UITextView) {
        interactor.send(.changeNote(textView.text))
    }

    @objc func didTapCancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapSave(_ sender: UIBarButtonItem) {
        interactor.send(.save)

        navigationController?.popViewController(animated: true)
    }
    
    func update(with model: Activity) {
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
        
        saveButtonItem.isEnabled = model.isValidForSaving
    }
        
}

extension ActivityDetailViewController: UITextViewDelegate {
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

//
//  EventTableViewCell.swift
//  tableExample
//
//  Created by Sonder2ULVCF on 26/11/19.
//  Copyright © 2019 Sonder2ULVCF. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EventTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var envetTextField: UITextField!
    
    // Create delegate for the table cell
    weak var delegate: EventTableViewCellDelegate?
    
    let disposeBag = DisposeBag()
    
override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupTextFieldChanging()
        handleResponder()
    
        // Tap and hold gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapAndHold))
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.delegate = self
        self.contentView.addGestureRecognizer(longPressGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // use rx.controlEvent([.editingDidEnd])to replace UITextFieldDelegate func textFieldDidEndEditing
    func setupTextFieldChanging() {
        envetTextField
        .rx
        .controlEvent([.editingDidEnd])
        .asObservable()
        .subscribe(onNext: { [weak self] _ in
            guard let this = self else { return }
            if this.envetTextField.text == "" {
                this.delegate?.removeFromTableView(cell: this)
            } else {
                this.delegate?.textChagedForCell(cell: this, text: this.envetTextField.text!)
            }
        })
        .disposed(by: disposeBag)
    }
    
    // use rx.controlEvent([.editingDidEndOnExit])to replace UITextFieldDelegate func textFieldShouldReturn
    func handleResponder() {
        envetTextField
            .rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: {_ in
                self.envetTextField.resignFirstResponder()
            })
        .disposed(by: disposeBag)
        
        envetTextField
            .rx
            .controlEvent(.editingDidBegin)
            .subscribe({_ in
                self.envetTextField.becomeFirstResponder()
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: Actions
    @objc func tapAndHold(longPressGesture: UILongPressGestureRecognizer) {
           delegate?.longPressForCell(cell: self, gesture: longPressGesture)
       }

//    MARK: UITextFieldDelegate
//    // Deprecated, it is replaced by rx handleResponder()
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    // Deprecated, it is replaced by rx setupTextFieldChanging()
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        delegate?.textChagedForCell(cell: self, text: textField.text!)
//        if textField.text == "" {
//            delegate?.removeFromTableView(cell: self)
//        } else {
//            delegate?.textChagedForCell(cell: self, text: textField.text!)
//        }
//    }
    
}


// MARK: - EventTableViewCellDelegate Protocol
protocol EventTableViewCellDelegate: class {
    func removeFromTableView(cell: EventTableViewCell)
    func textChagedForCell(cell: EventTableViewCell, text: String)
    func longPressForCell(cell: EventTableViewCell, gesture: UILongPressGestureRecognizer)
}

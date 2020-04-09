//
//  ItemTableViewController.swift
//  tableExample
//
//  Created by Sonder2ULVCF on 26/11/19.
//  Copyright © 2019 Sonder2ULVCF. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ItemTableViewController: UIViewController, EventTableViewCellDelegate {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var testTextView: UITextView!
    
    var eventModel = EventViewModel()
    let disposeBag = DisposeBag()
    
    var draggingIndexPath: IndexPath?
    var draggableView: UIView?
    var touchStartingPoint: CGPoint?
    var draggableViewStartingPoint: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventModel.loadSampleEvents()
        setupCellConfiguration()
        setupCellTapHandling()
        
        let attributedString = NSMutableAttributedString(string: "Want to learn iOS? You should visit the best source of free iOS tutorials!")
        attributedString.addAttribute(.link, value: "https://hl.staging.sondersafe.com/?apn=com.sonder.wip.member.android.dev&isi=1436263196&ibi=com.sonder.member.dev&st=Set%2520your%2520password&sd=Create%2520your%2520account%2520with%2520Sonder%2520by%2520setting%2520your%2520password.%2520Keep%2520the%2520checkbox%2520below%2520selected%2520to%2520go%2520straight%2520to%2520the%2520Set%2520Password%2520page.&link=https://memberportal.dev.sondersafe.com/send-sms?email%3Dvicky@sondersafe.com%26token%3D245Iv2YrO_o&iPadFallbackURL=memberportal.dev.sondersafe.com/send-sms?email%3Dvicky@sondersafe.com%26token%3D245Iv2YrO_o", range: NSRange(location: 19, length: 55))

        testTextView.attributedText = attributedString
        
       
    }
    
    // MARK: Actions
    @IBAction func addEvent(_ sender: UIButton) {
        self.eventModel.addItem()
    }
//    // Deprected
//    @IBAction func addEvent(_ sender: UIButton) {
//
//           let indexPath: IndexPath = [0, eventModel.events.value.count]
//
//           tableView(tableView, commit: .insert, forRowAt: indexPath)
//
//           tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//
//           let eventCell = tableView.cellForRow(at: indexPath) as? EventTableViewCell
//           eventCell?.envetTextField.becomeFirstResponder()
//       }
    
    //Set up the table cell, equals to table data source func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func setupCellConfiguration() {
        let cellIdentifier = "ItemTableViewCell"
        eventModel.events.asObservable()
          .bind(to: tableView
            .rx
            .items(cellIdentifier: cellIdentifier,
                   cellType: EventTableViewCell.self)) {
                    row, event, cell in
                    cell.itemLabel.text = "Item \(row + 1)"
                    cell.envetTextField.text = event.name
                    cell.delegate = self
          }
          .disposed(by: disposeBag)
    }
    
    // Row manipulation
    func setupCellTapHandling() {
      tableView
        .rx
        .itemDeleted
        .subscribe(onNext: { [unowned self] indexPath in
            self.eventModel.removeItem(at: indexPath.row)
        })
        .disposed(by: disposeBag)
    }
    
    
    // MARK: EventTableViewCellDelegate
    func textChagedForCell(cell: EventTableViewCell, text: String) {
        let indexPath: IndexPath = tableView.indexPath(for: cell)!
        eventModel.changeCellText(at: indexPath.row, with: text)
    }
    
    func removeFromTableView(cell: EventTableViewCell) {
        let indexPath: IndexPath = tableView.indexPath(for: cell)!
        eventModel.removeItem(at: indexPath.row)
    }
    
    func longPressForCell(cell: EventTableViewCell, gesture: UILongPressGestureRecognizer) {
        
        /* TOUCH START */
        if (gesture.state == .began) {
            
            // Freeze the interface while dragging
            self.view.isUserInteractionEnabled = false
            
            draggingIndexPath = tableView.indexPath(for: cell)!
            
            // Add the draggable view as a snapshot of the cell
            let cellFrame = view.convert(cell.bounds, from: cell)
            draggableView = cell.snapshotView(afterScreenUpdates: false)
            draggableView!.frame = cellFrame
            self.view.addSubview(draggableView!)
            
            cell.isHidden = true
            
            // Save the points for reference
            touchStartingPoint = gesture.location(in: self.view)
            draggableViewStartingPoint = draggableView!.center
        }
        
        /* TOUCH MOVE */
        else if (gesture.state == .changed) {
            
            // Move the view and handle changes
            let point = gesture.location(in: self.view)
            moveViewRelativeToPoint(newPoint: point)
        }
        
        /* TOUCH END */
        else if (gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed) {
            
            // Animate cell back into place
            let cellFrame = view.convert(cell.bounds, from: cell)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.draggableView!.frame = cellFrame
            }) { (finished) in
                cell.isHidden = false
                self.draggableView!.removeFromSuperview()
                self.draggableView = nil
                
                // Reset the interface
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func moveViewRelativeToPoint(newPoint: CGPoint) {
        
        // Move the draggable view
        var center: CGPoint = draggableViewStartingPoint!
        center.y += (newPoint.y - touchStartingPoint!.y)
        draggableView!.center = center
        
        // Check if overlapping cells should change places
        let newIndexPath: IndexPath? = checkForOverlappingCells()
        if (newIndexPath != nil) {
            
            // Swap the places
            eventModel.swapItems(moveRowAt: draggingIndexPath!.row, to: newIndexPath!.row)
            
            draggingIndexPath = newIndexPath
        }
    }
    
    func checkForOverlappingCells() -> IndexPath? {
        
        var newIndexPath: IndexPath?
        
        let center: CGPoint = tableView.convert(draggableView!.center, from: self.view)
        
        for cell in tableView.visibleCells {
            if (cell.frame.contains(center)) {
                let cellIndexPath: IndexPath = tableView.indexPath(for: cell)!
                let isTheFromCell = (cellIndexPath == draggingIndexPath)
                if (!isTheFromCell) {
                    let dragFrame: CGRect = tableView.convert(draggableView!.frame, from: self.view)
                    
                    let dragHeight: CGFloat = dragFrame.size.height // - (SHADOW * 2))
                    
                    if (cell.frame.size.height > dragHeight) {
                        
                        /*
                         Evaluate using a smaller inner rect the size of the dragging
                         cell so the cells don't switch more than once (necessary because
                         of the variable height of the cells)...
                         */
                        let innerRect: CGRect = CGRect(x: cell.frame.origin.x,
                                                       y: cell.center.y - (dragHeight / 2),
                                                       width: cell.frame.size.width,
                                                       height: dragHeight)
                        
                        if (innerRect.contains(center)) {
                            newIndexPath = cellIndexPath;
                            break;
                        }
                    } else {
                        newIndexPath = cellIndexPath;
                        break;
                    }
                }
            }
        }
        
        return newIndexPath
    }
    
    
//     MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return eventModel.events.value.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellIdentifier = "ItemTableViewCell"
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EventTableViewCell else {
//            fatalError("The dequeued cell is not an instance of EventTableViewCell.")
//        }
//
//        let event = eventModel.events.value[indexPath.row]
//
//        cell.itemLabel.text = "Item \(indexPath.row + 1)"
//        cell.envetTextField.text = event.name
//        cell.delegate = self
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .insert) {
//            let newEvent:Event = Event(name: "")
//            eventModel.events.insert(newEvent, at: indexPath.row)
//            tableView.insertRows(at: [indexPath], with: .fade)
//        }
//        else if (editingStyle == .delete) {
//            eventModel.events.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
//
//    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        eventModel.events.swapAt(sourceIndexPath.row, destinationIndexPath.row)
//        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
//    }

}

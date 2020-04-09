//
//  EventViewModel.swift
//  tableExample
//
//  Created by Sonder2ULVCF on 2/12/19.
//  Copyright © 2019 Sonder2ULVCF. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EventViewModel {
    
    // Create BehaviorRelay to make envets observable
    var events: BehaviorRelay<[Event]> = BehaviorRelay(value: [])
    
    // Create a array with sample events, use accept() to modify events, because it is immutable
    func loadSampleEvents() {
        let event1 = Event(name:"lol")
        let event2 = Event(name:"working")
        let event3 = Event(name:"having fun")
        let event4 = Event(name:"traveling")

        let newEvents = events.value + [event1, event2, event3, event4]
        events.accept(newEvents)
    }
    
    func changeCellText(at index: Int, with text: String) {
        events.value[index].name = text
    }
    
    func removeItem(at index: Int) {
        var newEvents = events.value
        newEvents.remove(at: index)
        events.accept(newEvents)
    }
    
    func addItem() {
        let newEvent = Event(name:"")
        let newEvents = events.value + [newEvent]
        events.accept(newEvents)
    }
    
    func swapItems(moveRowAt index: Int, to newIndex: Int) {
        var newEvents = events.value
        let temp = newEvents[index]
        newEvents[index] = newEvents[newIndex]
        newEvents[newIndex] = temp
        events.accept(newEvents)
    }
}

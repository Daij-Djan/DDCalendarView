//
//  EventView.swift
//  Demos
//
//  Created by Dominik Pich on 13/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

import UIKit
import EventKit

class EventView: DDCalendarEventView {
    override var active : Bool {
        didSet {
            var c = UIColor.red
            if let ek = self.event.userInfo["event"] as? EKEvent {
                c = UIColor(cgColor: ek.calendar.cgColor)
            }

            if(active) {
                self.backgroundColor = c.withAlphaComponent(0.8)
                self.layer.borderColor = c.cgColor
                self.layer.borderWidth = 1
            }
            else {
                self.backgroundColor = c.withAlphaComponent(0.5)
                self.layer.borderColor = nil
                self.layer.borderWidth = 0
            }
        }
    }
}

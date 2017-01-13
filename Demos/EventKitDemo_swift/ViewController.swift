//
//  ViewController.swift
//  EventKitDemo_swift
//
//  Created by Dominik Pich on 13/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UIViewController, DDCalendarViewDelegate, DDCalendarViewDataSource, EKEventViewDelegate {
    @IBOutlet var dayLabel: UILabel!;
    @IBOutlet var calendarView: DDCalendarView!;

    var dict = Dictionary<Int, [DDCalendarEvent]>()
    var mgr = EventManager()
    
    override func viewDidLoad() {
        self.calendarView.scrollDateToVisible(Date(), animated: false)
    }
    
    // MARK: delegate
    
    func calendarView(_ view: DDCalendarView, focussedOnDay date: Date) {
        dayLabel.text = (date as NSDate).stringWithDateOnly()
        
        let days = (date as NSDate).days(from: Date())
        self.loadCachedEvents(days) { (events) -> Void in
            self.loadCachedEvents(days-1) { (events) -> Void in
                self.loadCachedEvents(days+1) { (events) -> Void in
                    self.calendarView.reloadData()
                }
            }
        }
        
    }
    
    func calendarView(_ view: DDCalendarView, didSelect event: DDCalendarEvent) {
        let ekEvent = event.userInfo["event"] as! EKEvent
        
        let vc = EKEventViewController()
        vc.delegate = self;
        vc.event = ekEvent
        let nav = UINavigationController(rootViewController: vc)

        self.present(nav, animated: true, completion: nil)
    }

    func calendarView(_ view: DDCalendarView, allowEditing event: DDCalendarEvent) -> Bool {
        //NOTE some check could be here, we just say true :D
        let ekEvent = event.userInfo["event"] as! EKEvent
        let ekCal = ekEvent.calendarItemIdentifier
        print(ekCal)
        
        return true
    }

    func calendarView(_ view: DDCalendarView, commitEdit event: DDCalendarEvent) {
        //NOTE we dont actually save anything because this demo doesnt wanna mess with your calendar :)
    }
    
    // MARK: dataSource
    
    public func calendarView(_ view: DDCalendarView, eventsForDay date: Date) -> [Any]? {
        let daysModifier = (date as NSDate).days(from: Date())
        return dict[daysModifier]
    }
    
    public func calendarView(_ view: DDCalendarView, viewFor event: DDCalendarEvent) -> DDCalendarEventView? {
        return EventView(event: event)
    }
    
    // MARK: helper
    
    func loadCachedEvents(_ day:Int, handler:@escaping ([DDCalendarEvent])->Void) {
        let events = dict[day]
        if(events == nil) {
            mgr.getEvents(day, calendars: nil, handler: { (newEvents) -> Void in
                //make DDEvents
                var ddEvents = [DDCalendarEvent]()
                for ekEvent in newEvents {
                    if ekEvent.isAllDay == false {
                        let ddEvent = DDCalendarEvent()
                        ddEvent.title = ekEvent.title
                        ddEvent.dateBegin = ekEvent.startDate
                        ddEvent.dateEnd = ekEvent.endDate
                        ddEvent.userInfo = ["event":ekEvent]
                        ddEvents.append(ddEvent)
                    }
                }
                self.dict[day] = ddEvents
                handler(ddEvents)
            })
        }
        else {
            handler(events!)
        }
    }

    // MARK: delegate
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        self.dismiss(animated: true, completion: nil)
    }
}


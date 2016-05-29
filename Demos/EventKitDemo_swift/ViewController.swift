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
        self.calendarView.scrollDateToVisible(NSDate(), animated: false)
    }
    
    // MARK: delegate
    
    func calendarView(view: DDCalendarView, focussedOnDay date: NSDate) {
        dayLabel.text = date.stringWithDateOnly()
        
        let days = date.daysFromDate(NSDate())
        self.loadCachedEvents(days) { (events) -> Void in
            self.loadCachedEvents(days-1) { (events) -> Void in
                self.loadCachedEvents(days+1) { (events) -> Void in
                    self.calendarView.reloadData()
                }
            }
        }
        
    }
    
    func calendarView(view: DDCalendarView, didSelectEvent event: DDCalendarEvent) {
        let ekEvent = event.userInfo["event"] as! EKEvent
        
        let vc = EKEventViewController()
        vc.delegate = self;
        vc.event = ekEvent
        let nav = UINavigationController(rootViewController: vc)

        self.presentViewController(nav, animated: true, completion: nil)
    }

    func calendarView(view: DDCalendarView, allowEditingEvent event: DDCalendarEvent) -> Bool {
        //NOTE some check could be here, we just say true :D
        let ekEvent = event.userInfo["event"] as! EKEvent
        let ekCal = ekEvent.calendarItemIdentifier
        print(ekCal)
        
        return true
    }

    func calendarView(view: DDCalendarView, commitEditEvent event: DDCalendarEvent) {
        //NOTE we dont actually save anything because this demo doesnt wanna mess with your calendar :)
    }
    
    // MARK: dataSource
    
    func calendarView(view: DDCalendarView, eventsForDay date: NSDate) -> [AnyObject]? {
        let daysModifier = date.daysFromDate(NSDate())
        return dict[daysModifier]
    }
    
    func calendarView(view: DDCalendarView, viewForEvent event: DDCalendarEvent) -> DDCalendarEventView? {
        return EventView(event: event)
    }
    
    // MARK: helper
    
    func loadCachedEvents(day:Int, handler:([DDCalendarEvent])->Void) {
        let events = dict[day]
        if(events == nil) {
            mgr.getEvents(day, calendars: nil, handler: { (newEvents) -> Void in
                //make DDEvents
                var ddEvents = [DDCalendarEvent]()
                for ekEvent in newEvents {
                    if ekEvent.allDay == false {
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
    
    func eventViewController(controller: EKEventViewController, didCompleteWithAction action: EKEventViewAction) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


//
//  EventManager.swift
//  Demos
//
//  Created by Dominik Pich on 13/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

import UIKit
import EventKit

public typealias EventManagerLoadCalendersCompletionHandler = ([EKCalendar]) -> Void
public typealias EventManagerCalenderCreatedCompletionHandler = (EKCalendar) -> Void
public typealias EventManagerLoadEventsCompletionHandler = ([EKEvent]) -> Void
public typealias EventManagerEventCreatedCompletionHandler = (EKEvent) -> Void

open class EventManager: NSObject {
    let eventStore = EKEventStore()
    
    //reading
    
    open func getEventCalendars(_ handler:@escaping EventManagerLoadCalendersCompletionHandler) {
        assertAuthorization() {
            DispatchQueue.global().async {
                let allCalendars = self.eventStore.calendars(for: .event)
                
                DispatchQueue.main.async {
                    handler(allCalendars)
                }
            }
        }
    }

    open func getEvents(_ daysModifier:Int,calendars:[EKCalendar]?, handler:@escaping EventManagerLoadEventsCompletionHandler) {
        assertAuthorization() {
            DispatchQueue.global().async {
                let calendar = Calendar.current
                let units = NSCalendar.Unit.day.union(NSCalendar.Unit.month).union(NSCalendar.Unit.year).union(NSCalendar.Unit.weekday).union(NSCalendar.Unit.weekOfMonth).union(NSCalendar.Unit.hour).union(NSCalendar.Unit.minute)
                var nowComps = (calendar as NSCalendar).components(units, from: Date())
                
                nowComps.day = daysModifier + (nowComps.day ?? 0);
                nowComps.hour = 0;
                nowComps.minute = 0;
                let from = calendar.date(from: nowComps)

                nowComps.hour = 23;
                nowComps.minute = 59;
                let to = calendar.date(from: nowComps)
                
                assert(from != nil);
                assert(to != nil);
                
                // Create the predicate from the event store's instance method
                let predicate = self.eventStore.predicateForEvents(withStart: from!, end: to!, calendars: calendars)
                
                // Fetch all events that match the predicate
                let events = self.eventStore.events(matching: predicate)
                
                DispatchQueue.main.async {
                    handler(events)
                }
            }
        }
    }
    
    // MARK: writing
    
    open func createUnsavedEventCalendar(_ name:String, handler:@escaping EventManagerCalenderCreatedCompletionHandler) {
        assertAuthorization() {
            // create new calendar.
            let calendar = EKCalendar(for: .event, eventStore: self.eventStore)
            calendar.title = name
            handler(calendar)
        }
    }
    
    open func createUnsavedEvent(_ title:String, calendar:EKCalendar, handler:@escaping EventManagerEventCreatedCompletionHandler) {
        assertAuthorization() {
            // create new event
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.calendar = calendar
            handler(event)
        }
    }
    
    // MARK: auth helper
    
    fileprivate func assertAuthorization(_ handler:@escaping (()->Void)) {
        if EKEventStore.authorizationStatus(for: .event) != .authorized {
            eventStore.requestAccess(to: .event, completion: { (newAuth, error) -> Void in
                //get it
                handler()
            })
        }
        else {
            //get it
            handler()
        }
    }
}

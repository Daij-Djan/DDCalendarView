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

public class EventManager: NSObject {
    let eventStore = EKEventStore()
    
    //reading
    
    public func getEventCalendars(handler:EventManagerLoadCalendersCompletionHandler) {
        assertAuthorization() {
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                let allCalendars = self.eventStore.calendarsForEntityType(.Event)
                
                dispatch_async(dispatch_get_main_queue()) {
                    handler(allCalendars)
                }
            }
        }
    }

    public func getEvents(daysModifier:Int,calendars:[EKCalendar]?, handler:EventManagerLoadEventsCompletionHandler) {
        assertAuthorization() {
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                let calendar = NSCalendar.currentCalendar()
                let units = NSCalendarUnit.Day.union(NSCalendarUnit.Month).union(NSCalendarUnit.Year).union(NSCalendarUnit.Weekday).union(NSCalendarUnit.WeekOfMonth).union(NSCalendarUnit.Hour).union(NSCalendarUnit.Minute)
                let nowComps = calendar.components(units, fromDate: NSDate())
                
                nowComps.day += daysModifier;
                nowComps.hour = 0;
                nowComps.minute = 0;
                let from = calendar.dateFromComponents(nowComps)

                nowComps.hour = 23;
                nowComps.minute = 59;
                let to = calendar.dateFromComponents(nowComps)
                
                assert(from != nil);
                assert(to != nil);
                
                // Create the predicate from the event store's instance method
                let predicate = self.eventStore.predicateForEventsWithStartDate(from!, endDate: to!, calendars: calendars)
                
                // Fetch all events that match the predicate
                let events = self.eventStore.eventsMatchingPredicate(predicate)
                
                dispatch_async(dispatch_get_main_queue()) {
                    handler(events)
                }
            }
        }
    }
    
    // MARK: writing
    
    public func createUnsavedEventCalendar(name:String, handler:EventManagerCalenderCreatedCompletionHandler) {
        assertAuthorization() {
            // create new calendar.
            let calendar = EKCalendar(forEntityType: .Event, eventStore: self.eventStore)
            calendar.title = name
            handler(calendar)
        }
    }
    
    public func createUnsavedEvent(title:String, calendar:EKCalendar, handler:EventManagerEventCreatedCompletionHandler) {
        assertAuthorization() {
            // create new event
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.calendar = calendar
            handler(event)
        }
    }
    
    // MARK: auth helper
    
    private func assertAuthorization(handler:(()->Void)) {
        if EKEventStore.authorizationStatusForEntityType(.Event) != .Authorized {
            eventStore.requestAccessToEntityType(.Event, completion: { (newAuth, error) -> Void in
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

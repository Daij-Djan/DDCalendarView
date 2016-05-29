//
//  ViewController.m
//  CalendarDemo_objc
//
//  Created by Dominik Pich on 06/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "ViewController.h"
#import "DDCalendarEvent.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarView.h"
#import "EventView.h"

@interface ViewController () <DDCalendarViewDataSource, DDCalendarViewDelegate>

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.calendarView scrollDateToVisible:[NSDate date] animated:animated];
    });
}

- (NSArray *)eventsForDay:(NSInteger)dayMod {
    DDCalendarEvent *event2 = [DDCalendarEvent new];
    [event2 setTitle: @"Demo Event 3"];
    [event2 setDateBegin:[NSDate dateWithHour:3 min:15 inDays:dayMod]];
    [event2 setDateEnd:[NSDate dateWithHour:4 min:0 inDays:dayMod]];
    [event2 setUserInfo:@{@"color":[UIColor yellowColor]}];
    
    DDCalendarEvent *event3 = [DDCalendarEvent new];
    [event3 setTitle: @"Demo Event 1"];
    [event3 setDateBegin:[NSDate dateWithHour:1 min:00 inDays:dayMod]];
    [event3 setDateEnd:[NSDate dateWithHour:2 min:10 inDays:dayMod]];
    
    DDCalendarEvent *event4 = [DDCalendarEvent new];
    [event4 setTitle: @"Demo Event 5"];
    [event4 setDateBegin:[NSDate dateWithHour:5 min:39 inDays:dayMod]];
    [event4 setDateEnd:[NSDate dateWithHour:6 min:13 inDays:dayMod]];
    [event4 setUserInfo:@{@"color":[UIColor yellowColor]}];
    
    DDCalendarEvent *event1 = [DDCalendarEvent new];
    [event1 setTitle: @"Demo Event 7"];
    [event1 setDateBegin:[NSDate dateWithHour:7 min:00 inDays:dayMod]];
    [event1 setDateEnd:[NSDate dateWithHour:10 min:13 inDays:dayMod]];

    DDCalendarEvent *event5 = [DDCalendarEvent new];
    [event5 setTitle: @"Demo Event 13"];
    [event5 setDateBegin:[NSDate dateWithHour:12 min:00 inDays:dayMod]];
    [event5 setDateEnd:[NSDate dateWithHour:14 min:13 inDays:dayMod]];
    
    DDCalendarEvent *event7 = [DDCalendarEvent new];
    [event7 setTitle: @"Demo Event 15"];
    [event7 setDateBegin:[NSDate dateWithHour:17 min:30 inDays:dayMod]];
    [event7 setDateEnd:[NSDate dateWithHour:17 min:45 inDays:dayMod]];
    [event7 setUserInfo:@{@"color":[UIColor greenColor]}];
    
    DDCalendarEvent *event8 = [DDCalendarEvent new];
    [event8 setTitle: @"Demo Event 17"];
    [event8 setDateBegin:[NSDate dateWithHour:18 min:40 inDays:dayMod]];
    [event8 setDateEnd:[NSDate dateWithHour:21 min:30 inDays:dayMod]];
    
    DDCalendarEvent *event9 = [DDCalendarEvent new];
    [event9 setTitle: @"Demo Event 22"];
    [event9 setDateBegin:[NSDate dateWithHour:22 min:00 inDays:dayMod]];
    [event9 setDateEnd:[NSDate dateWithHour:23 min:30 inDays:dayMod]];
    
    if(dayMod % 2 != 0)
        return @[event1, event2, event3, event4, event5, event7, event8, event9];
    else
        return @[event2, event4, event8];
}

#pragma mark DDCalendarViewDelegate

- (void)calendarView:(DDCalendarView* _Nonnull)view focussedOnDay:(NSDate* _Nonnull)date {
    if(view.numberOfDays > 1) {
        NSDate *toDate = [date dateByAddingTimeInterval:(view.numberOfDays-1) * (60*60*24)];
        self.dayLabel.text = [NSString stringWithFormat:@"%@ - %@", date.stringWithDateOnly, toDate.stringWithDateOnly];
    }
    else {
        self.dayLabel.text = date.stringWithDateOnly;
    }
}

- (void)calendarView:(DDCalendarView* _Nonnull)view didSelectEvent:(DDCalendarEvent* _Nonnull)event {
    NSLog(@"%@", event);
}

- (BOOL)calendarView:(DDCalendarView* _Nonnull)view allowEditingEvent:(DDCalendarEvent* _Nonnull)event {
    return YES;
}

- (void)calendarView:(DDCalendarView* _Nonnull)view commitEditEvent:(DDCalendarEvent* _Nonnull)event {
    NSLog(@"%@", event);
    //should do conflic validation and maybe save ;) or revert :P
}

#pragma mark DDCalendarViewDataSource

- (NSArray *)calendarView:(DDCalendarView *)view eventsForDay:(NSDate *)date {
    //should come from db ;) NOW using testdata
    NSInteger daysMod = [date daysFromDate:[NSDate date]];
    NSArray *newE = [self eventsForDay:daysMod]; //always today ;)
    
    NSMutableArray *dates = [NSMutableArray array];
    for (DDCalendarEvent *e in newE) {
        if([e.dateBegin isEqualDay:date] ||
           [e.dateEnd isEqualDay:date]) {
            [dates addObject:e];
        }
    }
    return dates;
}

//optionally provide a view
- (DDCalendarEventView *)calendarView:(DDCalendarView *)view viewForEvent:(DDCalendarEvent *)event {
    return [[EventView alloc] initWithEvent:event];
}
@end

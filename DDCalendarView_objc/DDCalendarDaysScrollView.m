//
//  DDCalendarDaysScrollView.m
//  Demos
//
//  Created by Dominik Pich on 5/28/16.
//  Copyright © 2016 Dominik Pich. All rights reserved.
//

#import "DDCalendarDaysScrollView.h"
#import "DDCalendarSingleDayView.h"
#import "DDCalendarViewConstants.h"
#import "NSDate+DDCalendar.h"

@interface DDCalendarSingleDayView (private)
- (CGPoint)pointForDate:(NSDate*)date;
@end

@implementation DDCalendarDaysScrollView {
    NSMutableArray *_calendars;
}

- (void)addSubview:(UIView *)view {
    if([view isKindOfClass:[DDCalendarSingleDayView class]]) {
        if(!_calendars) {
            _calendars = [NSMutableArray array];
        }
        [_calendars addObject:view];
    }
    [super addSubview:view];
}

- (NSArray *)calendars {
    return _calendars;
}

- (void)scrollTimeToVisible:(NSDate *)date animated:(BOOL)animated {
    NSDateComponents *comps = date.currentCalendarDateComponents;
    NSInteger hours = comps.hour;
    NSInteger mins = comps.minute;
    
    hours = MAX(0, hours-1);
    
    NSDate *tempDate = [NSDate todayDateWithHour:hours min:mins];
    CGPoint offset = [self.calendars[0] pointForDate:tempDate];
    CGRect rect = CGRectMake(0, offset.y, 10, 10);
    rect.size = self.bounds.size;
    
    [self scrollRectToVisible:rect animated:animated];
}

- (void)prepareCalendars:(NSUInteger)count {
    CGRect f = self.bounds;
    
    //create new ones if needed
    while(self.calendars.count < count) {
        [self addNewCalendar];
    }
    
    //remove old ones if needed
    while(self.calendars.count > count) {
        DDCalendarSingleDayView *cal = self.calendars.lastObject;
        [cal removeFromSuperview];
    }
    
    //reposition them
    f.origin = CGPointZero;
    f.size.width = (f.size.width - TIME_LABEL_WIDTH) / count;
    
    BOOL firstOnly = YES;
    for (DDCalendarSingleDayView *dv in self.calendars) {
        if(firstOnly) {
            f.size.width += TIME_LABEL_WIDTH;
        }
        
        dv.frame = f;
        dv.showsTimeLabels = firstOnly;
        
        f.origin.x += f.size.width;
        if(firstOnly) {
            f.size.width -= TIME_LABEL_WIDTH;
        }
        
        firstOnly = NO;
    }
}

//helpers
- (void)addNewCalendar {
    DDCalendarSingleDayView *newCalendar = [[DDCalendarSingleDayView alloc] initWithFrame:self.bounds];
    [self addSubview:newCalendar];
}

@end

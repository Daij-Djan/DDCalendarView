//
//  DDCalendarView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarSingleDayView.h"
#import "DDCalendarView.h"
#import "FFViewWithHourLines.h"
#import "DDCalendarEvent.h"
#import "DDCalendarEventView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarViewConstants.h"
#import "OBDragDrop.h"

@interface DDCalendarSingleDayView () <OBOvumSource, OBDropZone>
@property(nonatomic,weak) FFViewWithHourLines *bg;
@property(nonatomic,weak) UIView *container;
@property(nonatomic,strong) NSArray *eventViews;
@property(nonatomic,weak) DDCalendarEventView *activeEventView;
@property(nonatomic, weak) UIView *timeMarkerLine;
@end

@interface DDCalendarEventView (private)
@property(nonatomic, weak) DDCalendarSingleDayView *calendar;
@end

@implementation DDCalendarSingleDayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        //add our hours view that draws the background
        FFViewWithHourLines *hourLines = [[FFViewWithHourLines alloc] initWithFrame:self.bounds];
        [hourLines setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [hourLines sizeToFit];
        [self addSubview:hourLines];
        self.bg = hourLines;
        
        //add a container for the events
        CGRect f = CGRectInset(hourLines.frame, 15, 15);
        f.origin.x += TIME_LABEL_WIDTH;
        f.size.width -= TIME_LABEL_WIDTH;
        UIView *container = [[UIView alloc] initWithFrame:f];
        [container setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.bg addSubview:container];
        self.container = container;
        
        [self setShowsTomorrow:NO];
//        [self setDate:[NSDate date]];
        
        self.dropZoneHandler = self;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    OBDragDropManager *manager = [OBDragDropManager sharedManager];
    [manager prepareOverlayWindowUsingMainWindow:self.window];
}

- (void)setEvents:(NSArray * _Nullable)events {
    _events = events;
    
    //rm all events
    for (UIView *v in self.eventViews) {
        [v removeFromSuperview];
    }
    self.eventViews = nil;
    
    id ds = self.calendar.dataSource;

    CGFloat maxX = 0;
    
    if(events.count) {
        //add event view for all events from left to right.
        NSMutableArray *newEventViews = [NSMutableArray array];
        for (DDCalendarEvent *e in events) {
            CGRect f = [self frameForEvent:e];
            f = [self adjustAvoidOverlapForFrame:f forPastEvents:newEventViews];
            
            DDCalendarEventView *ev = nil;
            
            if([ds respondsToSelector:@selector(calendarView:viewForEvent:)]) {
                ev = [ds calendarView:self.calendar viewForEvent:e];
            }
            
            if(!ev) {
                ev = [[DDCalendarEventView alloc] initWithEvent:e];
            }
            
            ev.frame = f;
            ev.calendar = self;
            [self.container addSubview:ev];
            [newEventViews addObject:ev];

            //get taps and pressed
            UIGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEvent:)];
            [ev addGestureRecognizer:g];

            // Drag drop with long press gesture
            OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
            UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
            [ev addGestureRecognizer:recognizer];
            
            //get the rightmost coordinate
            maxX = MAX(maxX, CGRectGetMaxX(f));
        }
        self.eventViews = newEventViews;
    }

    //check if gotta scale to fit on screen
    if(maxX > self.container.frame.size.width) {
        CGFloat factor = self.container.frame.size.width/maxX;
//        if(self.eventMinimumWidthFactor > factor) {
//            factor = MIN(self.eventMinimumWidthFactor, 1);
//        }
        
        [self compressAllEventViewsByFactor:factor];
        
//        maxX *= factor;
    }

    //update content size with maxX
//    CGSize s = self.bg.frame.size;
//    s.width = 15 + TIME_TIME_LABEL_WIDTH + maxX + 15;
//    
//    [self setContentSize:s];
}

- (void)setDate:(NSDate * _Nonnull)date {
    _date = date;
    [self setEvents:self.events];
}

- (void)setShowsTomorrow:(BOOL)showsTomorrow {
    _showsTomorrow = showsTomorrow;
    
    CGFloat height = self.bg.frame.size.height;
    if(!_showsTomorrow) {
        height /= 2;
    }
    self.contentSize = CGSizeMake(self.bounds.size.width, height);        
}

- (void)scrollTimeToVisible:(NSDate *)date animated:(BOOL)animated {
    NSDateComponents *comps = date.currentCalendarDateComponents;
    NSInteger hours = comps.hour;
    NSInteger mins = comps.minute;
    
    hours = MAX(0, hours-1);
    
    NSDate *tempDate = [NSDate todayDateWithHour:hours min:mins];
    CGPoint offset = [self pointForDate:tempDate];
    CGRect rect = CGRectMake(0, offset.y, 10, 10);
    rect.size = self.bounds.size;
    [self scrollRectToVisible:rect animated:animated];
}

- (void)setShowsTimeMarker:(BOOL)showsTimeMarker {
    _showsTimeMarker = showsTimeMarker;
    
    if(_showsTimeMarker) {
        if(!self.timeMarkerLine) {
            UIView *timeMarkerLine = [[UIView alloc] initWithFrame:CGRectZero];
            timeMarkerLine.backgroundColor = [UIColor redColor];
            [self insertSubview:timeMarkerLine aboveSubview:self.container];
            self.timeMarkerLine = timeMarkerLine;
        }
        
        NSDateComponents *now = [NSDate date].currentCalendarDateComponents;
        NSInteger days = [self.date daysFromDate:[NSDate date]];
        NSDate *date = [NSDate dateWithHour:now.hour min:now.minute inDays:days];
        CGPoint datePoint = [self pointForDate:date];
        datePoint.y += HEIGHT_CELL_MIN/2;
        datePoint.y += 2; //;)
        
        CGRect f = self.bounds;
        f.origin.y = datePoint.y;
        f.size.height = 2;
        self.timeMarkerLine.frame = f;
    }
    else {
        [self.timeMarkerLine removeFromSuperview];
    }
}

#pragma mark event frame helpers

- (CGRect)frameForEvent:(DDCalendarEvent*)event {
    CGFloat yBegin = [self pointForDate:event.dateBegin].y;
    CGFloat yEnd = [self pointForDate:event.dateEnd].y;
    
    return CGRectMake(0, yBegin, self.container.frame.size.width, yEnd - yBegin);
}

- (CGRect)adjustAvoidOverlapForFrame:(CGRect)frame forPastEvents:(NSArray*)eventViews {
    BOOL satisified;
    
    do {
        satisified = YES;
        
        for (DDCalendarEventView *ev in eventViews) {
            if(CGRectIntersectsRect(frame, ev.frame)) {
                //if it intersects, move it and retry!
                frame.origin.x += self.container.frame.size.width+15;
                satisified = NO;
            }
        }
    } while (!satisified);
    
    return frame;
}

- (void)compressAllEventViewsByFactor:(CGFloat)factor {
    for (DDCalendarEventView *ev in self.eventViews) {
        CGRect f = ev.frame;
        f.origin.x *= factor;
        f.size.width *= factor;
        ev.frame = f;
    }
}

#pragma mark convert points <> dates

- (CGPoint)pointForDate:(NSDate*)date {
    NSDateComponents *compsNow = self.date.currentCalendarDateComponents;
    NSDateComponents *compsOfBegin = date.currentCalendarDateComponents;
    
    //hours
    NSInteger beginInHoursSinceMidnightToday = compsOfBegin.hour;
    
    //we only encompass prev and next day.. we dont care about 2 or more days
    if(compsOfBegin.day > compsNow.day) beginInHoursSinceMidnightToday += 24;
    else if(compsOfBegin.day < compsNow.day) beginInHoursSinceMidnightToday -= 24;
    
    //pixels
    CGFloat yBegin = beginInHoursSinceMidnightToday * HEIGHT_CELL_HOUR;
    yBegin += compsOfBegin.minute * PIXELS_PER_MIN;
    
    yBegin -= 2;// ;)
    
    return CGPointMake(0, yBegin);
}

- (NSDate*)dateForPoint:(CGPoint)pt {
    CGFloat y = pt.y; //we only care about y
    
    y -= HEIGHT_CELL_MIN/2; //  ;)
    
    //determine how many hours fit
    int beginInHoursSinceMidnightToday = floor(pt.y / HEIGHT_CELL_HOUR);
    y = y - (beginInHoursSinceMidnightToday * HEIGHT_CELL_HOUR);
    assert(y < HEIGHT_CELL_HOUR);
    int minutesSinceLastHour = floor(y / PIXELS_PER_MIN);
    
    NSInteger daysMod = [self.date daysFromDate:[NSDate date]];
    NSDate *date = [NSDate dateWithHour:beginInHoursSinceMidnightToday min:minutesSinceLastHour inDays:daysMod];
    
    return date;
}

#pragma mark tap recognizer

- (void)handleTapOnEvent:(UIGestureRecognizer*)gestureRecognizer {
    DDCalendarEventView *activeEV = self.activeEventView;
    DDCalendarEventView *ev = (DDCalendarEventView*)gestureRecognizer.view;
    
    if(activeEV != ev) {
        ev.active = YES;

        id<DDCalendarViewDelegate> delegate = self.calendar.delegate;
        
        //tell click to delegate
        if([delegate respondsToSelector:@selector(calendarView:didSelectEvent:)]) {
            [delegate calendarView:self.calendar didSelectEvent:ev.event];
        }
    }
    else if(activeEV==ev) {
        activeEV.active = NO;
        self.activeEventView = nil;
    }
}

#pragma mark d&d

-(BOOL) shouldCreateOvumFromView:(UIView*)sourceView {
    BOOL editable = NO;
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    DDCalendarEventView *ev = (DDCalendarEventView*)sourceView;
    
    if([del respondsToSelector:@selector(calendarView:allowEditingEvent:)]) {
        editable = [del calendarView:self.calendar allowEditingEvent:ev.event];
    }
    
    if(editable) {
        //activate it
        ev.active = YES;
        self.activeEventView = ev;
    }
    return editable;
}

-(OBOvum *) createOvumFromView:(UIView*)sourceView {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);
    
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = ((DDCalendarEventView*)sourceView).event;
    ovum.isCentered = YES;
    return ovum;
}

-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)overlay {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);

    UIView *dragView = [(DDCalendarEventView*)sourceView draggableView];
    
    // Create a view that represents this source. It will be place on
    // the overlay window and hence the coordinates conversion to make
    // sure user doesn't see a jump in object location
    CGRect f = dragView.frame;
    f = [self.container convertRect:f toView:self.window];
    f = [self.window convertRect:f toView:overlay];
    dragView.frame = f;
    
    return dragView;
}

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    return OBDropActionMove;
}

- (void)ovumExited:(OBOvum *)ovum inView:(UIView *)view atLocation:(CGPoint)location {
    //noop
}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    //to get the top of the event
    location.y -= CGRectGetHeight(ovum.dragView.frame)/2;
    
    // Handle the drop action
    DDCalendarEvent *event = ovum.dataObject;
    NSTimeInterval duration = [event.dateEnd timeIntervalSinceDate:event.dateBegin];

    NSDate *newStartDate = [self dateForPoint:location];
    NSDate *newEndDate = [newStartDate dateByAddingTimeInterval:duration];
    
    event.dateBegin = newStartDate;
    event.dateEnd  = newEndDate;
    
    self.events = self.events; //refresh ourself
    
    //commit it
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    if([del respondsToSelector:@selector(calendarView:commitEditEvent:)]) {
        [del calendarView:self.calendar commitEditEvent:event];
    }
}

@end

//
//  DDCalendarView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarSingleDayView.h"
#import "DDCalendarView.h"
#import "DDCalendarHourLinesView.h"
#import "DDCalendarEvent.h"
#import "DDCalendarEventView.h"
#import "DDCalendarHeaderView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarViewConstants.h"
#import "OBDragDrop.h"

@interface DDCalendarSingleDayView () <OBOvumSource, OBDropZone>
@property(nonatomic,weak) DDCalendarHourLinesView *bg;
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
        DDCalendarHourLinesView *hourLines = [[DDCalendarHourLinesView alloc] initWithFrame:self.bounds];
        [hourLines setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [hourLines sizeToFit];
        [self addSubview:hourLines];
        self.bg = hourLines;
        
        //add a container for the events
        CGRect f = CGRectInset(hourLines.frame, 5, 5);
        f.origin.x += TIME_LABEL_WIDTH;
        f.size.width -= TIME_LABEL_WIDTH;
        UIView *container = [[UIView alloc] initWithFrame:f];
        [container setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.bg addSubview:container];
        self.bg.gridColor = self.gridColor;
        self.bg.textColor = self.textColor;
        
        self.container = container;
        
        _showsTimeLabels = YES;
        [self setShowsDayHeader:YES];
        
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
        [self compressAllEventViewsByFactor:factor];
    }
}

- (void)setDate:(NSDate * _Nonnull)date {
    _date = date;
    [self setEvents:self.events];
}

- (void)setShowsDayHeader:(BOOL)showsDayHeader {
    _showsDayHeader = showsDayHeader;
    
    CGRect f = self.bg.frame;

    DDCalendarHeaderView *label = (DDCalendarHeaderView*)[self viewWithTag:HEADER_LABEL_TAG];
    if(_showsDayHeader) {
        CGRect r = self.bounds;
        r.size.height = HEADER_LABEL_HEIGHT;

        if(!label) {
            label = [[DDCalendarHeaderView alloc] initWithFrame:r calendar:self];
            label.tag = HEADER_LABEL_TAG;
            
            [self addSubview:label];
        }
        else {
            label.calendar = self;
            label.frame = r;
        }
        
        f.origin.y = HEADER_LABEL_HEIGHT;
    }
    else {
        [label removeFromSuperview];
        
        f.origin.y = 0;
    }

    self.bg.frame = f;
}

- (void)setBorderOnRight:(BOOL)borderOnRight {
    _borderOnRight = borderOnRight;
    
    UILabel *label = (UILabel*)[self viewWithTag:RIGHT_BORDER_LABEL_TAG];
    if(_borderOnRight) {
        CGRect r = self.bounds;
        r.origin.x += r.size.width - 1;
        r.size.width = 1;
        if(!label) {
            label = [[UILabel alloc] initWithFrame:r];
            label.tag = RIGHT_BORDER_LABEL_TAG;
            label.backgroundColor = self.gridColor ? self.gridColor : [UIColor blackColor];
            
            [self addSubview:label];
        }
        else {
            label.frame = r;
        }
    }
    else {
        [label removeFromSuperview];
    }
    
    DDCalendarHeaderView *dayLabel = (DDCalendarHeaderView*)[self viewWithTag:HEADER_LABEL_TAG];
    [dayLabel setNeedsDisplay];
}

- (void)setGridColor:(UIColor *)gridColor {
    _gridColor = gridColor;
    self.bg.gridColor = _gridColor ? _gridColor : [UIColor blackColor];

    UILabel *label = (UILabel*)[self viewWithTag:RIGHT_BORDER_LABEL_TAG];
    label.backgroundColor = _gridColor ? _gridColor : [UIColor blackColor];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    self.bg.textColor = _textColor ? _textColor : [UIColor blackColor];
    DDCalendarHeaderView *label = (DDCalendarHeaderView*)[self viewWithTag:HEADER_LABEL_TAG];
    [label setNeedsDisplay];
}

- (void)setMarkerColor:(UIColor *)markerColor {
    _markerColor = markerColor;
    
    self.timeMarkerLine.backgroundColor = _markerColor ? _markerColor : [UIColor blackColor];
    [self.timeMarkerLine setNeedsDisplay];
}

- (void)setShowsTomorrow:(BOOL)showsTomorrow {
    _showsTomorrow = showsTomorrow;
    
    CGFloat height = self.bg.frame.size.height;
    if(!_showsTomorrow) {
        height /= 2;
    }
    
    CGRect f = self.frame;
    f.size = CGSizeMake(self.bounds.size.width, height);
    self.frame = f;
}

- (void)setShowsTimeLabels:(BOOL)showsTimeLabels {
    _showsTimeLabels = showsTimeLabels;
    
    CGRect f = CGRectInset(self.bg.frame, 5, 5);
    if(_showsTimeLabels) {
        f.origin.x += TIME_LABEL_WIDTH;
        f.size.width -= TIME_LABEL_WIDTH;
    }
    self.container.frame = f;
    self.bg.showTimeLabels = _showsTimeLabels;
}

- (void)setShowsTimeMarker:(BOOL)showsTimeMarker {
    _showsTimeMarker = showsTimeMarker;
    
    if(_showsTimeMarker) {
        if(!self.timeMarkerLine) {
            UIView *timeMarkerLine = [[UIView alloc] initWithFrame:CGRectZero];
            timeMarkerLine.backgroundColor = self.markerColor ? self.markerColor : [UIColor blackColor];
            
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
                frame.origin.x += self.container.frame.size.width+5;
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
    yBegin += HEIGHT_CELL_MIN/2;
    
    if(self.showsDayHeader)
        yBegin -= HEADER_LABEL_HEIGHT;
    
    yBegin -= 5;// ;)
    
    return CGPointMake(0, yBegin);
}

- (NSDate*)dateForPoint:(CGPoint)pt {
    CGFloat y = pt.y; //we only care about y
    y -= HEIGHT_CELL_MIN/2;
    
    if(self.showsDayHeader)
        y -= HEADER_LABEL_HEIGHT;

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
        activeEV.active = NO;
        ev.active = YES;
        self.activeEventView = ev;

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
        self.activeEventView.active = NO;
        ev.active = YES;
        self.activeEventView = ev;
    }
    return editable;
}

-(OBOvum *) createOvumFromView:(UIView*)sourceView {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);
    
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = @{@"event": ((DDCalendarEventView*)sourceView).event, @"calendar": ((DDCalendarEventView*)sourceView).calendar};
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
    assert(view == self);

    // Handle the drop action
    NSDictionary *dict = ovum.dataObject;
    DDCalendarEvent *event = dict[@"event"];
    DDCalendarSingleDayView *oldCalendar = dict[@"calendar"];
    
    //to get the top of the event
    location.y -= CGRectGetHeight(ovum.dragView.frame)/2;
    
    //the new time
    NSTimeInterval duration = [event.dateEnd timeIntervalSinceDate:event.dateBegin];
    NSDate *newStartDate = [self dateForPoint:location];
    NSDate *newEndDate = [newStartDate dateByAddingTimeInterval:duration];
    event.dateBegin = newStartDate;
    event.dateEnd  = newEndDate;
    
    // if we moved between cals, we need to move the event between arrays
    // else we only need to trigger ONE redraw
    if(oldCalendar != self) {
        NSMutableArray *newOldEvents = [oldCalendar->_events mutableCopy];
        [newOldEvents removeObject:event];
        
        NSMutableArray *newNewEvents = [_events mutableCopy];
        [newNewEvents addObject:event];

        oldCalendar.events = newOldEvents;
        self.events = newNewEvents;
    }
    else {
        self.events = self.events;
    }
    
    //commit it
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    if([del respondsToSelector:@selector(calendarView:commitEditEvent:)]) {
        [del calendarView:self.calendar commitEditEvent:event];
    }
}

@end

//
//  DDCalendarView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarView.h"
#import "DDCalendarSingleDayView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarEvent.h"
#import "DDCalendarDaysScrollView.h"
#import "DDCalendarViewConstants.h"

@interface DDCalendarView () <UIScrollViewDelegate>
@property(nonatomic, strong) IBInspectable NSString * _Nonnull dateString;

@property(nonatomic, weak) UIScrollView *pagingView;
@property(nonatomic, weak) DDCalendarDaysScrollView *leftScrollView;
@property(nonatomic, weak) DDCalendarDaysScrollView *centerScrollView;
@property(nonatomic, weak) DDCalendarDaysScrollView *rightScrollView;
@end

@implementation DDCalendarView {
    int _selectedPageIndex;
    BOOL _mockMode;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    //defaults
    self.showsDayName = YES;
    self.showsTimeMarker = YES;
    self.showsTomorrow = NO;
    self.numberOfDays = 1;
    
    self.date = [NSDate date];

    UIScrollView *pagingView = [[UIScrollView alloc] initWithFrame:self.bounds];
    pagingView.pagingEnabled = YES;
    pagingView.directionalLockEnabled = YES;
    pagingView.delegate = self;
    [pagingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:pagingView];
    self.pagingView = pagingView;
    
    DDCalendarDaysScrollView *leftScrollView = [[DDCalendarDaysScrollView alloc] initWithFrame:self.bounds];
    leftScrollView.delegate = self;
    [leftScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    DDCalendarDaysScrollView *centerScrollView = [[DDCalendarDaysScrollView alloc] initWithFrame:self.bounds];
    centerScrollView.delegate = self;
    [centerScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    DDCalendarDaysScrollView *rightScrollView = [[DDCalendarDaysScrollView alloc] initWithFrame:self.bounds];
    rightScrollView.delegate = self;
    [rightScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    [pagingView addSubview:leftScrollView];
    [pagingView addSubview:centerScrollView];
    [pagingView addSubview:rightScrollView];
    self.leftScrollView = leftScrollView;
    self.centerScrollView = centerScrollView;
    self.rightScrollView = rightScrollView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect f = self.pagingView.bounds;
    CGSize s = self.pagingView.contentSize;
    if(s.width != f.size.width * 3) {
        self.date = self.date;
    }
}

- (void)resizeContainersAndCenterPagingView {
    //make us as big as needed
    CGSize s = self.frame.size;
    s.width *= 3;
    self.pagingView.contentSize = s;
    
    //go to center
    CGFloat left = 0;
    for (UIView *calView in self.leftScrollView.calendars) {
        left += calView.frame.size.width;
    }
    self.pagingView.contentOffset = CGPointMake(left,0);
    _selectedPageIndex = 1;
    
    if(!CGSizeEqualToSize([self.leftScrollView.calendars[0] frame].size, self.leftScrollView.contentSize)) {
        CGRect f = self.bounds;
        self.leftScrollView.frame = f;
        self.leftScrollView.contentSize = [self.leftScrollView.calendars[0] frame].size;
        f.origin.x += f.size.width;
        
        self.centerScrollView.frame = f;
        self.centerScrollView.contentSize = [self.centerScrollView.calendars[0] frame].size;
        f.origin.x += f.size.width;
        
        self.rightScrollView.frame = f;
        self.rightScrollView.contentSize = [self.rightScrollView.calendars[0] frame].size;
    }
}

- (void)setShowsTomorrow:(BOOL)showsTomorrow {
    _showsTomorrow = showsTomorrow;
    
    if(!self.date)
        return;

    //tell our single days
    for (DDCalendarSingleDayView *dv in self.leftScrollView.calendars) {
        dv.showsTomorrow = showsTomorrow;
    }
    for (DDCalendarSingleDayView *dv in self.centerScrollView.calendars) {
        dv.showsTomorrow = showsTomorrow;
    }
    for (DDCalendarSingleDayView *dv in self.rightScrollView.calendars) {
        dv.showsTomorrow = showsTomorrow;
    }

    [self resizeContainersAndCenterPagingView];
}

- (void)setShowsTimeMarker:(BOOL)showsTimeMarker {
    _showsTimeMarker = showsTimeMarker;
    
    if(!self.date)
        return;

    //tell our single days
    for (DDCalendarSingleDayView *dv in self.leftScrollView.calendars) {
        dv.showsTimeMarker = showsTimeMarker;
    }
    for (DDCalendarSingleDayView *dv in self.centerScrollView.calendars) {
        dv.showsTimeMarker = showsTimeMarker;
    }
    for (DDCalendarSingleDayView *dv in self.rightScrollView.calendars) {
        dv.showsTimeMarker = showsTimeMarker;
    }
}

- (void)setShowsDayName:(BOOL)showsDayname {
    _showsDayName = showsDayname;
    
    if(!self.date)
        return;
    
    //tell our single days
    for (DDCalendarSingleDayView *dv in self.leftScrollView.calendars) {
        dv.showsDayHeader = showsDayname;
    }
    for (DDCalendarSingleDayView *dv in self.centerScrollView.calendars) {
        dv.showsDayHeader = showsDayname;
    }
    for (DDCalendarSingleDayView *dv in self.rightScrollView.calendars) {
        dv.showsDayHeader = showsDayname;
    }
}

- (void)setNumberOfDays:(NSUInteger)numberOfDays {
    _numberOfDays = numberOfDays;
    
    if(!self.date)
        return;
    
    self.date = self.date;
}

- (void)setDate:(NSDate *)date {
    if(!date) {
        date = [NSDate date];
    }
    NSParameterAssert(date);
    
    BOOL dateDiffer = ![_date isEqualToDate:date];
    _date = date;
    
    if(self.pagingView) {
        //create the needed amount of calendars
        [self.leftScrollView prepareCalendars:self.numberOfDays];
        [self.centerScrollView prepareCalendars:self.numberOfDays];
        [self.rightScrollView prepareCalendars:self.numberOfDays];
        
        //set dates AND get data
        NSInteger dayModifier = -_numberOfDays;
        for (DDCalendarSingleDayView *dv in self.leftScrollView.calendars) {
            [self reloadCalendar:dv dayModifier:dayModifier++];
        }
        for (DDCalendarSingleDayView *dv in self.centerScrollView.calendars) {
            [self reloadCalendar:dv dayModifier:dayModifier++];
        }
        for (DDCalendarSingleDayView *dv in self.rightScrollView.calendars) {
            [self reloadCalendar:dv dayModifier:dayModifier++];
        }
        
        //fix our contentOffset & size
        self.showsTomorrow = self.showsTomorrow;
    }
    
    //tell delegate
    if(dateDiffer) {
        id<DDCalendarViewDelegate> delegate = self.delegate;
        if([delegate respondsToSelector:@selector(calendarView:focussedOnDay:)]) {
            [delegate calendarView:self focussedOnDay:_date];
        }
    }
}

- (void)setDateString:(NSString *)dateString {
    self.date = [NSDate dateWithDateString:dateString];
}

- (NSString *)dateString {
    return [self.date stringWithDateOnly];
}

- (void)setDelegate:(id<DDCalendarViewDelegate>)delegate {
    if(delegate != _delegate) {
        _delegate = delegate;
        
        id<DDCalendarViewDelegate> delegate = _delegate;
        if([delegate respondsToSelector:@selector(calendarView:focussedOnDay:)]) {
            [delegate calendarView:self focussedOnDay:_date];
        }
    }
}

- (void)setDataSource:(id<DDCalendarViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.date = self.date;
}

- (void)reloadData {
    self.date = self.date;
}

- (void)scrollDateToVisible:(NSDate *)date animated:(BOOL)animated {
    if(![date isEqualDay:self.date]) {
        self.date = date;
    }
    [self.leftScrollView scrollTimeToVisible:date animated:animated];
    [self.centerScrollView scrollTimeToVisible:date animated:animated];
    [self.rightScrollView scrollTimeToVisible:date animated:animated];
}

//paging view
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    if(sender == self.pagingView) {
        // Switch when more than 50% of the previous/next page is visible
        CGFloat pageWidth = CGRectGetWidth(self.frame);
        int page = floor((self.pagingView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (page != _selectedPageIndex) {
            //if the page changed, go and refocus our view to allow for infinite scrolling
            NSDate *newDate;
            if(page == 0) {
                newDate = [self.date dateByAddingDays:-self.numberOfDays];
            }
            else if(page == 2) {
                newDate = [self.date dateByAddingDays:self.numberOfDays];
            }
            
            assert(newDate);
            self.date = newDate;
        }
    }
}

//calenders
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //sync the views
    if(scrollView == self.leftScrollView ||
       scrollView == self.centerScrollView ||
       scrollView == self.rightScrollView) {
        self.leftScrollView.contentOffset = scrollView.contentOffset;
        self.centerScrollView.contentOffset = scrollView.contentOffset;
        self.rightScrollView.contentOffset = scrollView.contentOffset;
    }
}

- (void)reloadCalendar:(DDCalendarSingleDayView*)dv dayModifier:(NSInteger)dayModifier {
    dv.date = [self.date dateByAddingDays:dayModifier];
    dv.showsDayHeader = self.showsDayName;
    dv.showsTomorrow = self.showsTomorrow;
    dv.showsTimeMarker = self.showsTimeMarker;
    dv.calendar = self;
    
    if(_mockMode) {
        dv.events = [self eventsForDay:dayModifier];
    }
    else {
        dv.events = [_dataSource calendarView:self eventsForDay:dv.date];
    }
}

#pragma mark IB

- (void)prepareForInterfaceBuilder {
    _mockMode = YES;
}

- (NSArray *)eventsForDay:(NSInteger)dayMod {
    DDCalendarEvent *event2 = [DDCalendarEvent new];
    [event2 setTitle: @"Mock Event B"];
    [event2 setDateBegin:[NSDate dateWithHour:3 min:15 inDays:dayMod]];
    [event2 setDateEnd:[NSDate dateWithHour:4 min:0 inDays:dayMod]];
    
    DDCalendarEvent *event3 = [DDCalendarEvent new];
    [event3 setTitle: @"Mock Event C"];
    [event3 setDateBegin:[NSDate dateWithHour:1 min:00 inDays:dayMod]];
    [event3 setDateEnd:[NSDate dateWithHour:2 min:10 inDays:dayMod]];
    
    DDCalendarEvent *event4 = [DDCalendarEvent new];
    [event4 setTitle: @"Mock Event D"];
    [event4 setDateBegin:[NSDate dateWithHour:5 min:39 inDays:dayMod]];
    [event4 setDateEnd:[NSDate dateWithHour:6 min:13 inDays:dayMod]];
    
    DDCalendarEvent *event5 = [DDCalendarEvent new];
    [event5 setTitle: @"Mock Event E"];
    [event5 setDateBegin:[NSDate dateWithHour:21 min:00 inDays:dayMod]];
    [event5 setDateEnd:[NSDate dateWithHour:22 min:13 inDays:dayMod]];
    
    DDCalendarEvent *event7 = [DDCalendarEvent new];
    [event7 setTitle: @"Mock Event G"];
    [event7 setDateBegin:[NSDate dateWithHour:10 min:30 inDays:dayMod]];
    [event7 setDateEnd:[NSDate dateWithHour:11 min:30 inDays:dayMod]];
    
    DDCalendarEvent *event8 = [DDCalendarEvent new];
    [event8 setTitle: @"Mock Event H"];
    [event8 setDateBegin:[NSDate dateWithHour:11 min:00 inDays:dayMod]];
    [event8 setDateEnd:[NSDate dateWithHour:14 min:30 inDays:dayMod]];
    
    DDCalendarEvent *event9 = [DDCalendarEvent new];
    [event9 setTitle: @"Mock Event I"];
    [event9 setDateBegin:[NSDate dateWithHour:9 min:00 inDays:dayMod]];
    [event9 setDateEnd:[NSDate dateWithHour:10 min:30 inDays:dayMod]];
    
    if(dayMod % 2 != 0)
        return @[event2, event3, event4, event5, event7, event8, event9];
    else
        return @[event3, event5, event7, event9];
}

@end

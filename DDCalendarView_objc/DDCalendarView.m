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

@interface DDCalendarView () <UIScrollViewDelegate>
@property(nonatomic, strong) IBInspectable NSString * _Nonnull dateString;

@property(nonatomic, weak) UIScrollView *pagingView;
@property(nonatomic, weak) DDCalendarSingleDayView *leftCal;
@property(nonatomic, weak) DDCalendarSingleDayView *centerCal;
@property(nonatomic, weak) DDCalendarSingleDayView *rightCal;
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
    self.date = [NSDate date];
    self.showsTimeMarker = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if(!self.pagingView) {
        UIScrollView *pagingView = [[UIScrollView alloc] initWithFrame:self.bounds];
        pagingView.pagingEnabled = YES;
        pagingView.directionalLockEnabled = YES;
        pagingView.delegate = self;
        [pagingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:pagingView];
        self.pagingView = pagingView;
    }
    
    CGRect f = self.pagingView.bounds;
    CGSize s = self.pagingView.contentSize;
    if(s.width != f.size.width * 3) {
        self.date = self.date;
    }
}
- (void)setShowsTomorrow:(BOOL)showsTomorrow {
    CGPoint offset = self.leftCal.contentOffset;

    _showsTomorrow = showsTomorrow;

    //tell our single days
    self.leftCal.showsTomorrow = _showsTomorrow;
    self.centerCal.showsTomorrow = _showsTomorrow;
    self.rightCal.showsTomorrow = _showsTomorrow;
    
    //make us as big as needed
    CGSize s = self.frame.size;
    s.width *= 3;
    self.pagingView.contentSize = s;
    
    self.pagingView.contentOffset = CGPointMake(self.leftCal.frame.size.width,0);
    self.leftCal.contentOffset = offset;
    _selectedPageIndex = 1;
}

- (void)setShowsTimeMarker:(BOOL)showsTimeMarker {
    _showsTimeMarker = showsTimeMarker;

    //tell our single days
    self.leftCal.showsTimeMarker = _showsTimeMarker;
    self.centerCal.showsTimeMarker = _showsTimeMarker;
    self.rightCal.showsTimeMarker = _showsTimeMarker;
}

- (void)setDate:(NSDate *)date {
    if(!date) {
        date = [NSDate date];
    }
    NSParameterAssert(date);
    
    BOOL dateDiffer = ![_date isEqualToDate:date];
    _date = date;
    
    if(self.pagingView) {
        //create cals if not there yet
        if(!self.leftCal) {
            CGRect f = self.bounds;
            f.origin.x = 0;
            DDCalendarSingleDayView *leftCal = [[DDCalendarSingleDayView alloc] initWithFrame:f];
            f.origin.x += f.size.width;
            DDCalendarSingleDayView *centerCal = [[DDCalendarSingleDayView alloc] initWithFrame:f];
            f.origin.x += f.size.width;
            DDCalendarSingleDayView *rightCal = [[DDCalendarSingleDayView alloc] initWithFrame:f];
            
            leftCal.delegate = self;
            centerCal.delegate = self;
            rightCal.delegate = self;
            leftCal.calendar = self;
            centerCal.calendar = self;
            rightCal.calendar = self;
            
            UIScrollView *pagingView = self.pagingView;
            [pagingView addSubview:leftCal];
            [pagingView addSubview:centerCal];
            [pagingView addSubview:rightCal];
            self.leftCal = leftCal;
            self.centerCal = centerCal;
            self.rightCal = rightCal;
            
        }
        else {
            CGRect f = self.bounds;
            f.origin.x = 0;
            self.leftCal.frame = f;
            f.origin.x += f.size.width;
            self.centerCal.frame = f;
            f.origin.x += f.size.width;
            self.rightCal.frame = f;
        }
        
        //set dates
        self.leftCal.date = [_date dateByAddingTimeInterval:-(60*60*24)];
        self.centerCal.date = _date;
        self.rightCal.date = [_date dateByAddingTimeInterval:(60*60*24)];
        
        //get events
        if(_mockMode) {
            self.leftCal.events = [self eventsForDay:-1];
            self.centerCal.events = [self eventsForDay:0];
            self.rightCal.events = [self eventsForDay:-1];
        }
        else {
            id<DDCalendarViewDataSource> ds = _dataSource;
            if(ds) {
                self.leftCal.events = [ds calendarView:self eventsForDay:self.leftCal.date];
                self.centerCal.events = [ds calendarView:self eventsForDay:self.centerCal.date];
                self.rightCal.events = [ds calendarView:self eventsForDay:self.rightCal.date];
            }
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

- (void)scrollDateToVisible:(NSDate* _Nonnull)date animated:(BOOL)animated {
    if(![date isEqualDay:self.date]) {
        self.date = date;
    }
    [self.centerCal scrollTimeToVisible:date animated:animated];
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
                newDate = [self.date dateByAddingTimeInterval:-(60*60*24)];
            }
            else if(page == 2) {
                newDate = [self.date dateByAddingTimeInterval:(60*60*24)];
            }
            
            assert(newDate);
            self.date = newDate;
        }
    }
}

//calenders
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.leftCal || scrollView == self.centerCal || scrollView == self.rightCal) {
        CGPoint offset = scrollView.contentOffset;
        self.leftCal.contentOffset = offset;
        self.centerCal.contentOffset = offset;
        self.rightCal.contentOffset = offset;
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
    
    return @[event2, event3, event4, event5, event7, event8, event9];
}

@end

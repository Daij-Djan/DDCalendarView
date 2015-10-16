//
//  DDCalendarView.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DDCalendarViewDelegate;
@protocol DDCalendarViewDataSource;
@class DDCalendarEvent;
@class DDCalendarEventView;

IB_DESIGNABLE
@interface DDCalendarView : UIView

@property(nonatomic, strong) NSDate * _Nonnull date; //note, causes a reloadData
@property(nonatomic, assign) IBInspectable BOOL showsTomorrow;
@property(nonatomic, assign) IBInspectable BOOL showsTimeMarker;

@property(nonatomic, weak) IBOutlet id<DDCalendarViewDelegate> delegate;
@property(nonatomic, weak) IBOutlet id<DDCalendarViewDataSource> dataSource; //note, causes a reloadData

- (void)reloadData;
- (void)scrollDateToVisible:(NSDate* _Nonnull)date animated:(BOOL)animated;

@end

@protocol DDCalendarViewDelegate <NSObject>

@optional
- (void)calendarView:(DDCalendarView* _Nonnull)view focussedOnDay:(NSDate* _Nonnull)date;
- (void)calendarView:(DDCalendarView* _Nonnull)view didSelectEvent:(DDCalendarEvent* _Nonnull)event;
- (BOOL)calendarView:(DDCalendarView* _Nonnull)view allowEditingEvent:(DDCalendarEvent* _Nonnull)event;
- (void)calendarView:(DDCalendarView* _Nonnull)view commitEditEvent:(DDCalendarEvent* _Nonnull)event; //if allow editing returns yes, this is mandatory

@end

@protocol DDCalendarViewDataSource <NSObject>

- (NSArray* _Nullable)calendarView:(DDCalendarView* _Nonnull)view eventsForDay:(NSDate* _Nonnull)date;

@optional
- (DDCalendarEventView* _Nullable)calendarView:(DDCalendarView* _Nonnull)view viewForEvent:(DDCalendarEvent* _Nonnull)event; //if not implemented / returns nil, default views are used

@end
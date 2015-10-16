//
//  DDCalendarView.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCalendarView;

@interface DDCalendarSingleDayView : UIScrollView

@property(nonatomic, strong) NSDate * _Nonnull date;
@property(nonatomic, assign) BOOL showsTomorrow;
@property(nonatomic, assign) BOOL showsTimeMarker;

@property(nonatomic, strong) NSArray * _Nullable events;
@property(nonatomic, weak) DDCalendarView * _Nullable calendar;

- (void)scrollTimeToVisible:(NSDate* _Nonnull)date animated:(BOOL)animated;

@end

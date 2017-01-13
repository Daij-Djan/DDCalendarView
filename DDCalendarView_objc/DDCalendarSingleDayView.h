//
//  DDCalendarView.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCalendarView;

@interface DDCalendarSingleDayView : UIView

@property(nonatomic, strong) NSDate * _Nonnull date;
@property(nonatomic, assign) BOOL showsTomorrow;
@property(nonatomic, assign) BOOL showsTimeMarker;
@property(nonatomic, assign) BOOL showsTimeLabels;
@property(nonatomic, assign) BOOL showsDayHeader;

@property(nonatomic, assign) BOOL borderOnRight;

@property(nonatomic, strong) IBInspectable UIColor * _Nullable gridColor;
@property(nonatomic, strong) IBInspectable UIColor * _Nullable textColor;
@property(nonatomic, strong) IBInspectable UIColor * _Nullable markerColor;

@property(nonatomic, strong) NSArray * _Nullable events;
@property(nonatomic, weak) DDCalendarView * _Nullable calendar;

@end

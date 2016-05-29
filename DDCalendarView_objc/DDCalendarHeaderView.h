//
//  DDCalendarHeaderView.h
//  Demos
//
//  Created by Dominik Pich on 5/29/16.
//  Copyright © 2016 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCalendarSingleDayView;

@interface DDCalendarHeaderView : UIView

@property(nonatomic, weak) DDCalendarSingleDayView *calendar;
- (instancetype)initWithFrame:(CGRect)frame calendar:(DDCalendarSingleDayView *)calendar;

@end

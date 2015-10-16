//
//  DDCalendarEventView.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCalendarSingleDayView;
@class DDCalendarEvent;

@interface DDCalendarEventView : UIView

- (id)initWithEvent:(DDCalendarEvent*)event;

@property(nonatomic, strong, readonly) DDCalendarEvent *event;
@property(nonatomic, assign) BOOL active;

- (UIView *)draggableView;

@end

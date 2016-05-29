//
//  DDCalendarDaysScrollView.h
//  Demos
//
//  Created by Dominik Pich on 5/28/16.
//  Copyright © 2016 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDCalendarDaysScrollView : UIScrollView

@property(readonly) NSArray *calendars; //add new cals via addSubview
- (void)prepareCalendars:(NSUInteger)count;

- (void)scrollTimeToVisible:(NSDate *)date animated:(BOOL)animated;

@end

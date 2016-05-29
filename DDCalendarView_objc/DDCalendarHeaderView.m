//
//  DDCalendarHeaderView.m
//  Demos
//
//  Created by Dominik Pich on 5/29/16.
//  Copyright © 2016 Dominik Pich. All rights reserved.
//

#import "DDCalendarHeaderView.h"
#import "DDCalendarSingleDayView.h"
#import "DDCalendarViewConstants.h"
#import "NSDate+DDCalendar.h"

@implementation DDCalendarHeaderView

- (instancetype)initWithFrame:(CGRect)frame calendar:(DDCalendarSingleDayView *)calendar {
    self = [super initWithFrame:frame];
    if(self) {
        _calendar = calendar;
    }
    return self;
}

- (void)setCalendar:(DDCalendarSingleDayView *)calendar {
    _calendar = calendar;
    [self setNeedsDisplay];
}

- (BOOL)isOpaque {
    return NO;
}

- (void)drawRect:(CGRect)rect {
    rect = self.bounds;
    
    BOOL usePadding = self.calendar.showsTimeLabels;
    CGFloat padding = usePadding ? TIME_LABEL_WIDTH : 0;
        
    //draw a line in the center of the box
    CGRect line = CGRectMake(padding, HEIGHT_CELL_MIN-1, rect.size.width-padding, 1);
    UIRectFill(line);
        
        //draw text if useful
    CGRect label = CGRectMake(padding, 0, rect.size.width-padding, rect.size.height);
    
    NSString *string = self.calendar.date.stringWithShortDayName;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]], NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    CGSize size = [string sizeWithAttributes:attributes];
    
    CGRect r = CGRectMake(label.origin.x,
                          label.origin.y + (label.size.height - size.height)/2.0,
                          label.size.width,
                          size.height);
    
    
    [string drawInRect:r withAttributes:attributes];
}

@end

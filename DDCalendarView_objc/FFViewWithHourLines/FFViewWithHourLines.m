//
//  FFViewWithHourLines.m
//  FFCalendar
//
//  Created by Fernanda G. Geraissate on 2/21/14.
//  Copyright (c) 2014 Fernanda G. Geraissate. All rights reserved.
//
//  http://fernandasportfolio.tumblr.com
//

#import "FFViewWithHourLines.h"
#import "FFHourAndMinLabel.h"
#import "NSDate+DDCalendar.h"
#import "UILabel+FFCustomMethods.h"
#import "DDCalendarViewConstants.h"

@interface FFViewWithHourLines ()
@property (strong) NSMutableArray *arrayLabelsHourAndMin;
@property (assign) CGFloat totalHeight;
@end

@implementation FFViewWithHourLines

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.arrayLabelsHourAndMin = [NSMutableArray new];
        
        CGFloat y = 0;
        
        //add today
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                
                FFHourAndMinLabel *labelHourMin = [[FFHourAndMinLabel alloc] initWithFrame:CGRectMake(10, y, self.frame.size.width-10, HEIGHT_CELL_MIN) date:[NSDate todayDateWithHour:hour min:min]];
                [labelHourMin setTextColor:[UIColor grayColor]];
                if (min == 0) {
                    [labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x+width, HEIGHT_CELL_MIN/2., self.frame.size.width-labelHourMin.frame.origin.x-width, 1.)];
                    [view setBackgroundColor:[UIColor lightGrayColor]];
                    [labelHourMin addSubview:view];
                }
                [self addSubview:labelHourMin];
                [self.arrayLabelsHourAndMin addObject:labelHourMin];
                
                y += HEIGHT_CELL_MIN;
            }
        }

        //add tommorrow (hc)
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                
                FFHourAndMinLabel *labelHourMin = [[FFHourAndMinLabel alloc] initWithFrame:CGRectMake(10, y, self.frame.size.width-10, HEIGHT_CELL_MIN) date:[NSDate tomorrowDateWithHour:hour min:min]];
                [labelHourMin setTextColor:[UIColor grayColor]];
                if (min == 0) {
                    [labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x+width, HEIGHT_CELL_MIN/2., self.frame.size.width-labelHourMin.frame.origin.x-width, 1.)];
                    [view setBackgroundColor:[UIColor lightGrayColor]];
                    [labelHourMin addSubview:view];
                }
                [self addSubview:labelHourMin];
                [self.arrayLabelsHourAndMin addObject:labelHourMin];
                
                y += HEIGHT_CELL_MIN;
            }
        }
        
        self.totalHeight = y;
    }
    return self;
}

- (void)sizeToFit {
    CGRect f = self.frame;
    f.size.height = self.totalHeight;
    self.frame = f;
}
@end

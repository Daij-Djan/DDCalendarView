//
//  DDCalendarHourLinesView.h
//  DDCalendar
//
//  Created by Dominik Pich 2016
//

#import "DDCalendarHourLinesView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarViewConstants.h"

@interface DDCalendarHourLinesView ()
@property (strong) NSMutableArray *dates;
@property (assign) CGFloat totalHeight;
@end

@implementation DDCalendarHourLinesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dates = [NSMutableArray new];
        
        CGFloat y = 0;
        
        //add today
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                [self.dates addObject:[NSDate todayDateWithHour:hour min:min]];
                y += HEIGHT_CELL_MIN;
            }
        }

        //add tommorrow (hc)
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                [self.dates addObject:[NSDate tomorrowDateWithHour:hour min:min]];
                y += HEIGHT_CELL_MIN;
            }
        }
        
        self.totalHeight = y;
        self.showTimeLabels = YES;
    }
    return self;
}

- (void)sizeToFit {
    CGRect f = self.frame;
    f.size.height = self.totalHeight;
    self.frame = f;
}

- (void)setShowTimeLabels:(BOOL)showTimeLabels {
    _showTimeLabels = showTimeLabels;
    [self setNeedsDisplay];
}

- (BOOL)isOpaque {
    return NO;
}

- (void)drawRect:(CGRect)rect {
    rect = self.bounds;

    CGFloat y = 0;
    [[UIColor lightGrayColor] set];

    //draw lines
    NSUInteger i = 60; //one hour
    assert(self.dates.count);
    
    BOOL usePadding = self.showTimeLabels;
    for (NSDate *date in self.dates) {
        BOOL showTime = usePadding && i%60==0;
        CGFloat padding = usePadding ? TIME_LABEL_WIDTH : 0;
            
        //draw a line in the center of the box
        CGRect line = CGRectMake(padding, y+HEIGHT_CELL_MIN/2, rect.size.width-padding, 1);
        UIRectFill(line);
            
        //draw text if useful
        if(showTime) {
            CGRect label = CGRectMake(0, y, padding, HEIGHT_CELL_MIN);
            
            NSString *string = date.stringWithTimeOnly;
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]], NSForegroundColorAttributeName: [UIColor lightGrayColor]};
            CGSize size = [string sizeWithAttributes:attributes];
            
            CGRect r = CGRectMake(label.origin.x,
                                  label.origin.y + (label.size.height - size.height)/2.0,
                                  label.size.width,
                                  size.height);
            
            
            [string drawInRect:r withAttributes:attributes];
        }
        
        //advance
        y += HEIGHT_CELL_MIN;
        i += MINUTES_PER_LABEL;
    }
}

@end

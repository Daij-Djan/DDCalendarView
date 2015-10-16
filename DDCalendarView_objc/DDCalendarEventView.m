//
//  DDCalendarEventView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarEventView.h"
#import "DDCalendarEvent.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarSingleDayView.h"

@interface DDCalendarEventView ()
@property(nonatomic, strong) DDCalendarEvent *event;
@property(nonatomic, weak) DDCalendarSingleDayView *calendar;

@property(nonatomic, weak) UILabel *label;
@end

@interface DDCalendarSingleDayView (private)
- (CGRect)frameForEvent:(DDCalendarEvent*)event;
@end

@implementation DDCalendarEventView

- (id)initWithEvent:(DDCalendarEvent*)event {
    self = [super initWithFrame:CGRectMake(10, 10, 10, 10)];
    if(self) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label = label;
        self.label.numberOfLines = 0;
        [self addSubview:self.label];

        self.event = event;
        self.active = NO;
    }
    return self;
}

- (void)layoutSubviews {
    self.label.frame = self.bounds;
}

- (void)setEvent:(DDCalendarEvent *)event {
    _event = event;
    
    assert(event.title.length);
    assert(event.dateBegin);
    assert(event.dateEnd);
    
    self.label.text = [NSString stringWithFormat:@"%@\n\n%@\n%@", event.title, event.dateBegin.stringWithTimeOnly, event.dateEnd.stringWithTimeOnly];
    [self.label sizeToFit];
}

- (void)setActive:(BOOL)active {
    _active = active;
    
    UIColor *c = [UIColor redColor];
        
    if(_active) {
        self.backgroundColor = [c colorWithAlphaComponent:0.8];
        self.layer.borderColor = c.CGColor;
        self.layer.borderWidth = 1;
    }
    else {
        self.backgroundColor = [c colorWithAlphaComponent:0.5];
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0;
    }
}

- (UIView *)draggableView {
    BOOL oldActive = self.active;
    self.active = YES;
    CGRect oldFrame = self.frame;
    self.frame = [self.calendar frameForEvent:self.event];

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView * imageViewForAnimation = [[UIImageView alloc] initWithImage:image];
    imageViewForAnimation.backgroundColor = [UIColor clearColor];

    self.active = oldActive;
    self.frame = oldFrame;
    
    return imageViewForAnimation;
}

@end

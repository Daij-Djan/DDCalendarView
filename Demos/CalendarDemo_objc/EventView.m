//
//  EventView.m
//  CalendarDemo_objc
//
//  Created by Dominik Pich on 11/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "EventView.h"
#import "DDCalendarEvent.h"

@implementation EventView

- (void)setActive:(BOOL)active {
    super.active = active;
    
    UIColor *c = [UIColor redColor];
    if(self.event.userInfo[@"color"]) {
        c = self.event.userInfo[@"color"];
    }
    
    if(super.active) {
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

@end

//
//  DDCalendarEvent.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarEvent.h"

@implementation DDCalendarEvent

- (NSString *)description {
    id userStr = self.userInfo ? self.userInfo.description : @"{no user info}";
    return [NSString stringWithFormat:@"(%@ <%@, %@-%@>, %@", NSStringFromClass(self.class), self.title, self.dateBegin, self.dateEnd, userStr];
}

@end

//
//  DDCalendarEvent.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDCalendarEvent : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *dateBegin;
@property (nonatomic, strong) NSDate *dateEnd;

@property (nonatomic, strong) NSDictionary *userInfo;

@end

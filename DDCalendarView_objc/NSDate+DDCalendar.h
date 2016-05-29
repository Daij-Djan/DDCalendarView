//
//  NSDate+DDCalendar.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//
//  Based FFCalendar  by Felipe Rocha on 14/02/14.
//

#import <Foundation/Foundation.h>

@interface NSDate (DDCalendar)

//get all the date components
- (NSDateComponents *)currentCalendarDateComponents;

//days between
- (NSInteger)daysFromDate:(NSDate*)toDateTime;
- (NSDate *)dateByAddingDays:(NSInteger)daysModifier;

//comparison helpers
- (BOOL)isEqualDay:(NSDate*)date;
- (BOOL)isEqualTime:(NSDate*)date;

//convenience formatter
- (NSString*)stringWithShortDayName;
- (NSString *)stringWithDateOnly;
- (NSString *)stringWithTimeOnly;

//helpers to create dates quickly
+ (NSDate *)todayDateWithHour:(NSInteger)hour min:(NSInteger)min;
+ (NSDate *)tomorrowDateWithHour:(NSInteger)hour min:(NSInteger)min;
+ (NSDate *)yesterdayDateWithHour:(NSInteger)hour min:(NSInteger)min;
+ (NSDate *)dateWithHour:(NSInteger)hour min:(NSInteger)min inDays:(NSInteger)daysModifier;
+ (NSDate *)dateWithDateString:(NSString*)dateString;
+ (NSDate *)dateWithTimeString:(NSString*)timeString;

@end

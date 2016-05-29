//
//  NSDate+DDCalendar.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//
//  Based FFCalendar  by Felipe Rocha on 14/02/14.
//

#import "NSDate+DDCalendar.h"

@implementation NSDate (DDCalendar)

#pragma mark get all the date components

- (NSDateComponents *)currentCalendarDateComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    return [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSCalendarUnitHour |
            NSCalendarUnitMinute fromDate:self];
}

#pragma mark days between

- (NSInteger)daysFromDate:(NSDate*)toDateTime {
    NSDate *fromDateTime = self;
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day] * -1;
}

- (NSDate *)dateByAddingDays:(NSInteger)daysModifier {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = self.currentCalendarDateComponents;
    [components setDay:components.day+daysModifier];
    
    return [calendar dateFromComponents:components];
}

#pragma mark convenience formatter

- (NSString*)stringWithShortDayName {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEE"];
    });
    return [df stringFromDate:self];
}

- (NSString *)stringWithTimeOnly {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterNoStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
    });
    return [df stringFromDate:self];
}

- (NSString *)stringWithDateOnly {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterNoStyle];
    });
    return [df stringFromDate:self];
}

#pragma mark comparison helpers

- (BOOL)isEqualDay:(NSDate *)date {
    NSDateComponents *compA = self.currentCalendarDateComponents;
    NSDateComponents *compB = date.currentCalendarDateComponents;
    return ([compA day]==[compB day] && [compA month]==[compB month ]&& [compA year]==[compB year]);
}

- (BOOL)isEqualTime:(NSDate *)date {
    NSDateComponents *compA = self.currentCalendarDateComponents;
    NSDateComponents *compB = date.currentCalendarDateComponents;
    return ([compA hour]==[compB hour] && [compA minute]==[compB minute]);
}

#pragma mark helpers to create dates quickly

+ (NSDate *)todayDateWithHour:(NSInteger)hour min:(NSInteger)min {
    return [self dateWithHour:hour min:min inDays:0];
    
}

+ (NSDate *)tomorrowDateWithHour:(NSInteger)hour min:(NSInteger)min {
    return [self dateWithHour:hour min:min inDays:1];
    
}

+ (NSDate *)yesterdayDateWithHour:(NSInteger)hour min:(NSInteger)min {
    return [self dateWithHour:hour min:min inDays:-1];
    
}

+ (NSDate *)dateWithHour:(NSInteger)hour min:(NSInteger)min inDays:(NSInteger)daysModifier {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDate date].currentCalendarDateComponents;
    [components setDay:components.day+daysModifier];
    [components setHour:hour];
    [components setMinute:min];
    
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateWithDateString:(NSString *)dateString {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterNoStyle];
    });
    return [df dateFromString:dateString];
}

+ (NSDate *)dateWithTimeString:(NSString *)timeString {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterNoStyle];
        [df setTimeStyle:NSDateFormatterMediumStyle];
    });
    return [df dateFromString:timeString];
}

@end

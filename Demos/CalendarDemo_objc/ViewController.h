//
//  ViewController.h
//  CalendarDemo_objc
//
//  Created by Dominik Pich on 06/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDCalendarView;

@interface ViewController : UIViewController

@property(nonatomic, weak) IBOutlet UILabel *dayLabel;
@property(nonatomic, weak) IBOutlet DDCalendarView *calendarView;

@end


//
//  DDCalendarHourLinesView.h
//  DDCalendar
//
//  Created by Dominik Pich 2016
//

#import <UIKit/UIKit.h>

@interface DDCalendarHourLinesView : UIView

@property(nonatomic, strong) IBInspectable UIColor * _Nonnull gridColor;
@property(nonatomic, strong) IBInspectable UIColor * _Nonnull textColor;
@property (nonatomic, assign) BOOL showTimeLabels;
@property (readonly) CGFloat totalHeight;

@end

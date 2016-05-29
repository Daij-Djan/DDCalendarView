//
//  DDCalendarViewConstants.h
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//
//  Based on FFCalendar by Felipe Rocha on 14/02/14.
//

#import <UIKit/UIKit.h>

#define MINUTES_INTERVAL 4.
#define HEIGHT_CELL_HOUR 100.
#define HEIGHT_CELL_MIN (HEIGHT_CELL_HOUR/MINUTES_INTERVAL)
#define MINUTES_PER_LABEL (60./MINUTES_INTERVAL)

#define PIXELS_PER_MIN (HEIGHT_CELL_HOUR/60.)
#define TIME_LABEL_WIDTH 64
#define HEADER_LABEL_HEIGHT 24

#define HEADER_LABEL_TAG 555
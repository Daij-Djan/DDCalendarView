//
//  UIView+OBDropTarget.h
//  OBUserInterface
//
//  Created by Zai Chang on 3/1/12.
//  Copyright (c) 2012 Oblong Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBDragDropManager.h"


@interface UIView (OBDropZone)

// Adds the ability for a UIView to forward drag/drop
@property (nonatomic, assign) id<OBDropZone> dropZoneHandler;

-(BOOL) hasParentView:(UIView*)parentView;

@end

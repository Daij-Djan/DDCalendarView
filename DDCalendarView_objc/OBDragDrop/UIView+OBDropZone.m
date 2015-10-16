//
//  UIView+OBDropZone.m
//  OBUserInterface
//
//  Created by Zai Chang on 3/1/12.
//  Copyright (c) 2012 Oblong Industries. All rights reserved.
//

#import "UIView+OBDropZone.h"
#import <objc/runtime.h>


static NSString *kDropZoneHandlerKey = @"DropZoneHandlerKey";


@implementation UIView (OBDragDropManager)

-(id<OBDropZone>) dropZoneHandler
{
  id<OBDropZone> handler = (id<OBDropZone>) objc_getAssociatedObject(self, (__bridge const void *)(kDropZoneHandlerKey));
  return handler;
}


-(void) setDropZoneHandler:(id<OBDropZone>)handler
{
  objc_setAssociatedObject (self,
                            (__bridge const void *)(kDropZoneHandlerKey),
                            handler,
                            OBJC_ASSOCIATION_ASSIGN
                            );
}


-(BOOL) hasParentView:(UIView*)parentView
{
  UIView *superview = [self superview];
  if (superview)
  {
    if (superview == parentView)
      return YES;
    else
      return [superview hasParentView:parentView];
  }
  
  return NO;
}

@end

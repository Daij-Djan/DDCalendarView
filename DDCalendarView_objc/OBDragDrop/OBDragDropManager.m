//
//  OBDragDropManager.m
//  OBUserInterface
//
//  Created by Zai Chang on 2/23/12.
//  Copyright (c) 2012 Oblong Industries. All rights reserved.
//

#import "OBDragDropManager.h"
#import "UIView+OBDropZone.h"
#import "UIGestureRecognizer+OBDragDrop.h"
#import "OBLongPressDragDropGestureRecognizer.h"


@implementation OBOvum

@synthesize source;
@synthesize dataObject;
@synthesize tag;
@synthesize dropAction;
@synthesize currentDropHandlingView;

@synthesize dragView;
@synthesize dragViewInitialCenter;
@synthesize dragViewInitialSize;

@synthesize isCentered;
@synthesize shouldScale;

@synthesize offsetOvumAndTouch;
@synthesize shiftPinchCentroid;
@synthesize scale;

- (id)init
{
  self = [super init];
  if (self) {
    self.isCentered = YES;
    self.shouldScale = NO;
  }
  return self;
}

-(void) dealloc
{
  self.source = nil;

}

@end



@interface OBDragDropManager (Private)

-(void) handleApplicationOrientationChange:(NSNotification*)notification;
-(void) cleanupOvum:(OBOvum*)ovum;
-(CGFloat) distanceFrom:(CGPoint)point1 to:(CGPoint)point2;

@end



@implementation OBDragDropManager

@synthesize overlayWindow;
@synthesize currentLocationInHostWindow;
@synthesize currentLocationInOverlayWindow;

+(OBDragDropManager *) sharedManager
{
  static OBDragDropManager *_sharedManager = nil;
  if (_sharedManager == nil)
  {
    _sharedManager = [[OBDragDropManager alloc] init];
  }
  return _sharedManager;
}


-(id) init
{
  self = [super init];
  if (self)
  {
    __weak id __self = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification
                                                      object:[UIApplication sharedApplication]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notification) {
                                                    [__self handleApplicationOrientationChange:notification];
                                                  }];
  }
  return self;
}


-(void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];

}


// Utility function from http://stackoverflow.com/questions/6697605/iphone-uiwindow-rotating-depending-on-current-orientation
//
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
  switch (orientation)
  {
    case UIInterfaceOrientationLandscapeLeft:
      return CGAffineTransformMakeRotation(-90.0 * M_PI / 180);
    case UIInterfaceOrientationLandscapeRight:
      return CGAffineTransformMakeRotation(90.0 * M_PI / 180);
    case UIInterfaceOrientationPortraitUpsideDown:
      return CGAffineTransformMakeRotation(M_PI);
    case UIInterfaceOrientationPortrait:
    default:
      return CGAffineTransformIdentity;
  }
}

-(void) handleApplicationOrientationChange:(NSNotification*)notification
{
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  self.overlayWindow.transform = [self transformForOrientation:orientation]; //self.mainWindow.transform;
}


-(void) prepareOverlayWindowUsingMainWindow:(UIWindow*)mainWindow
{
  if (self.overlayWindow)
  {
    [self.overlayWindow removeFromSuperview];
    self.overlayWindow = nil;
  }

  self.overlayWindow = [[UIWindow alloc] initWithFrame:mainWindow.frame];
  self.overlayWindow.windowLevel = UIWindowLevelAlert;
  self.overlayWindow.hidden = YES;
  self.overlayWindow.userInteractionEnabled = NO;
  self.overlayWindow.transform = [self transformForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}



#pragma mark - DropZoneHandler

-(UIView *) findDropTargetHandler:(UIView*)view
{
  if (view.dropZoneHandler)
    return view;

  UIView *superview = [view superview];
  if (superview)
    return [self findDropTargetHandler:superview];

  return nil;
}


-(UIView *) findDropZoneHandlerInView:(UIView*)view atLocation:(CGPoint)locationInView
{
  UIView *furthestView = [view hitTest:locationInView withEvent:nil];
  if (!furthestView)
  {
    return nil;
  }
  
  UIView *handlingView = [self findDropTargetHandler:furthestView];
  return handlingView;
}


-(UIView *) findDropZoneHandlerInWindow:(UIWindow*)window atLocation:(CGPoint)locationInWindow
{
  UIView *furthestView = [window hitTest:locationInWindow withEvent:nil];
  UIView *handlingView = [self findDropTargetHandler:furthestView];
  if (handlingView)
    return handlingView;
  
  // Use the UIWindow's rootViewController if its available.
  // This allows for the usecase of dragging from a UIPopover to a view below, since UIPopover
  // uses the same window and places sibling views above the normal contents, using
  // the rootViewController's view is a method of getting to the user content of the window
  if (window.rootViewController && ![furthestView hasParentView:window.rootViewController.view])
  {
    UIView *containerView = window.rootViewController.view;
    CGPoint locationInContainerView = [containerView convertPoint:locationInWindow fromView:window];
    handlingView = [self findDropZoneHandlerInView:containerView atLocation:locationInContainerView];
  }
  
  return handlingView;
}


#pragma mark - Ovum Handling

-(void) handleOvumMove:(OBOvum*)ovum inWindow:(UIWindow*)window atLocation:(CGPoint)locationInWindow
{
  UIView *handlingView = [self findDropZoneHandlerInWindow:window atLocation:locationInWindow];
  CGPoint locationInView = [window convertPoint:locationInWindow toView:handlingView];

  // Handle change in drop target
  if (ovum.currentDropHandlingView != handlingView)
  {
    if (ovum.currentDropHandlingView)
    {
      CGPoint locationInCurrentView = [window convertPoint:locationInWindow toView:ovum.currentDropHandlingView];
      id<OBDropZone> dropZone = ovum.currentDropHandlingView.dropZoneHandler;
      [dropZone ovumExited:ovum inView:ovum.currentDropHandlingView atLocation:locationInCurrentView];
      ovum.dropAction = OBDropActionNone;
    }

    ovum.currentDropHandlingView = handlingView;

    if (ovum.currentDropHandlingView)
    {
      id<OBDropZone> dropZone = ovum.currentDropHandlingView.dropZoneHandler;
      OBDropAction action = [dropZone ovumEntered:ovum inView:handlingView atLocation:locationInView];
      ovum.dropAction = action;
    }
  }
  else
  {
    id<OBDropZone> dropZone = ovum.currentDropHandlingView.dropZoneHandler;
    if ([dropZone respondsToSelector:@selector(ovumMoved:inView:atLocation:)])
      ovum.dropAction = [dropZone ovumMoved:ovum inView:handlingView atLocation:locationInView];
  }
}


-(void) animateOvumReturningToSource:(OBOvum*)ovum
{
    if([ovum.source respondsToSelector:@selector(handleReturningToSourceAnimationForOvum:completion:)]) {
        
        UIView *dragView = ovum.dragView;
        
        [ovum.source handleReturningToSourceAnimationForOvum:ovum completion:^{
            
            [dragView removeFromSuperview];
            overlayWindow.hidden = YES;
        }];
    }
    else {
        
        CGPoint dragViewInitialCenter = ovum.dragViewInitialCenter;
        UIView *dragView = ovum.dragView;
        
        [UIView animateWithDuration:0.25 animations:^{
            dragView.center = dragViewInitialCenter;
            //dragView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            dragView.transform = CGAffineTransformIdentity;
            //dragView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [dragView removeFromSuperview];
            overlayWindow.hidden = YES;
        }];
    }
    

}


-(void) animateOvumDrop:(OBOvum*)ovum withAnimation:(void (^)()) dropAnimation completion:(void (^)(BOOL completed))completion
{
  if (dropAnimation == nil)
    return;

  UIView *dragView = ovum.dragView;

  [UIView animateWithDuration:0.25
                   animations:dropAnimation
                   completion:^(BOOL finished) {
                     if (completion)
                       completion(finished);

                     [dragView removeFromSuperview];
                     overlayWindow.hidden = YES;
                   }];
}


#pragma mark - Gesture Recognizer Handling

-(OBLongPressDragDropGestureRecognizer*) createLongPressDragDropGestureRecognizerWithSource:(id<OBOvumSource>)source
{
  return (OBLongPressDragDropGestureRecognizer *)[self createDragDropGestureRecognizerWithClass:[OBLongPressDragDropGestureRecognizer class] source:source];
}


-(UIGestureRecognizer *) createDragDropGestureRecognizerWithClass:(Class)recognizerClass source:(id<OBOvumSource>)source
{
  if ([recognizerClass isSubclassOfClass:[UIGestureRecognizer class]])
  {
    UIGestureRecognizer *recognizer = [[recognizerClass alloc] initWithTarget:self action:@selector(handleOvumGesture:)];
    recognizer.ovumSource = source;
    return recognizer;
  }
  return nil;
}


-(void) handleOvumGesture:(UIGestureRecognizer <OBDragDropGestureRecognizer>*)recognizer
{
    if (![self ovumRecognizerShouldHandleTouch:recognizer]) {
        return;
    }
    
    
  UIWindow *hostWindow = recognizer.view.window;
  CGPoint locationInHostWindow = [recognizer locationInView:hostWindow];
  CGPoint locationInOverlayWindow = [recognizer locationInView:overlayWindow];
  currentLocationInHostWindow = locationInHostWindow;
  currentLocationInOverlayWindow = locationInOverlayWindow;

  if (recognizer.state == UIGestureRecognizerStateBegan)
  {
    UIView *sourceView = recognizer.view;
    UIView *dragView = nil;
    id<OBOvumSource> ovumSource = recognizer.ovumSource;

    recognizer.ovum = [ovumSource createOvumFromView:sourceView];
    if (recognizer.ovum == nil) { // the source said this shouldn't be dragged at this moment
        return;
    }
    recognizer.ovum.source = ovumSource;
    recognizer.ovum.currentDropHandlingView = sourceView;

    if ([ovumSource respondsToSelector:@selector(createDragRepresentationOfSourceView:inWindow:)])
    {
      dragView = [ovumSource createDragRepresentationOfSourceView:recognizer.view inWindow:overlayWindow];
    }
    else
    {
      CGRect frameInOriginalWindow = [sourceView convertRect:sourceView.bounds toView:sourceView.window];
      CGRect frameInOverlayWindow = [overlayWindow convertRect:frameInOriginalWindow fromWindow:sourceView.window];
      dragView = [[UIView alloc] initWithFrame:frameInOverlayWindow];
      dragView.opaque = NO;
      dragView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.33];
    }

    overlayWindow.hidden = NO;
    [overlayWindow addSubview:dragView];
    recognizer.ovum.dragView = dragView;
    recognizer.ovum.dragViewInitialCenter = dragView.center;
    recognizer.ovum.dragViewInitialSize = dragView.frame.size;

    if (!recognizer.ovum.isCentered)
    {
      CGPoint offset;
      offset.x = locationInOverlayWindow.x - dragView.center.x;
      offset.y = locationInOverlayWindow.y - dragView.center.y;
      recognizer.ovum.offsetOvumAndTouch = offset;
    }
    
    if (recognizer.ovum.shouldScale)
    {
      recognizer.ovum.shiftPinchCentroid = CGPointMake(0, 0);
      prevPinchCentroid = locationInOverlayWindow;
      prevNumberOfTouches = recognizer.numberOfTouches;
      initialFrame = dragView.frame;
      
      // Noticed in some cases on iOS 7 beta 6 that using index 0 will cause a crash
      // even though the gesture has 'began' ... smells like a bug
      // '-[UIPanGestureRecognizer locationOfTouch:inView:]: index (0) beyond bounds (0).'
      if (recognizer.numberOfTouches > 0)
      {
        CGPoint firstTouchLocation = [recognizer locationOfTouch:0 inView:hostWindow];
        initialDistance = [self distanceFrom:locationInHostWindow to:firstTouchLocation]; // = 0 on 1-finger gesture.
      }
    }
    
    recognizer.ovum.scale = 1.0;

    // Give the ovum source a change to manipulate or animate the drag view
    if ([ovumSource respondsToSelector:@selector(dragViewWillAppear:inWindow:atLocation:)])
      [ovumSource dragViewWillAppear:dragView inWindow:overlayWindow atLocation:(recognizer.ovum.isCentered) ? locationInOverlayWindow:dragView.center];

    if ([ovumSource respondsToSelector:@selector(ovumDragWillBegin:)])
      [ovumSource ovumDragWillBegin:recognizer.ovum];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              recognizer.ovum, OBOvumDictionaryKey,
                              recognizer, OBGestureRecognizerDictionaryKey,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:OBDragDropManagerWillBeginDragNotification object:self userInfo:userInfo];
  } else if (recognizer.state == UIGestureRecognizerStateChanged)
  {
    OBOvum *ovum = recognizer.ovum;
    UIView *dragView = ovum.dragView;

    // New center point for drag view without any modification because of the scale of initial offsets between touch and drag view center.
    CGPoint newCenter = [self applyRecenteringTo:locationInOverlayWindow withRecognizer:recognizer];
    dragView.center = newCenter;

    [self handleOvumMove:ovum inWindow:hostWindow atLocation:locationInHostWindow];

  }
  else if (recognizer.state == UIGestureRecognizerStateEnded && recognizer.ovum.currentDropHandlingView)
  {
    // Handle the case that the ovum was dropped successfully onto a drop target
    OBOvum *ovum = recognizer.ovum;

    // Handle ovum movement since its location can be different than the last
    // UIGestureRecognizerStateChanged event
    [self handleOvumMove:ovum inWindow:hostWindow atLocation:locationInHostWindow];

    id<OBDropZone> dropZone = recognizer.ovum.currentDropHandlingView.dropZoneHandler;

    if (ovum.dropAction != OBDropActionNone && dropZone)
    {
      // Drop action is possible and drop zone is available
      UIView *handlingView = [self findDropZoneHandlerInWindow:hostWindow atLocation:locationInHostWindow];
      CGPoint locationInView = [hostWindow convertPoint:locationInHostWindow toView:handlingView];

      CGPoint newCenter = [self applyRecenteringTo:locationInOverlayWindow withRecognizer:recognizer];

      // For use in blocks below
      UIView *dragView = ovum.dragView;
      dragView.center = newCenter;

      [dropZone ovumDropped:ovum inView:handlingView atLocation:locationInView];

      if ([dropZone respondsToSelector:@selector(handleDropAnimationForOvum:withDragView:dragDropManager:)])
      {
        [dropZone handleDropAnimationForOvum:ovum withDragView:dragView dragDropManager:self];
      }
      else
      {
        [self animateOvumDrop:ovum withAnimation:^{
          dragView.transform = CGAffineTransformMakeScale(0.01, 0.01);
          dragView.alpha = 0.0;
        } completion:nil];
      }

      // Inform the OBOvumSource that an ovum originating from it has been dropped successfully
      if ([ovum.source respondsToSelector:@selector(ovumWasDropped:withDropAction:)])
        [ovum.source ovumWasDropped:ovum withDropAction:ovum.dropAction];
    }
    else
    {
      // Ovum dropped in an non-active area or was rejected by the view, so time to do some cleanup
      UIView *handlingView = ovum.currentDropHandlingView;
      CGPoint locationInView = [hostWindow convertPoint:locationInHostWindow toView:handlingView];
      [dropZone ovumExited:ovum inView:handlingView atLocation:locationInView];

      // Drop is rejected, return the ovum to its source
      [self animateOvumReturningToSource:ovum];
    }

    [self cleanupOvum:ovum];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              recognizer.ovum, OBOvumDictionaryKey,
                              recognizer, OBGestureRecognizerDictionaryKey,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:OBDragDropManagerDidEndDragNotification object:self userInfo:userInfo];
    
    // Reset the ovum recognizer
    recognizer.ovum = nil;
  }
  else if (recognizer.state == UIGestureRecognizerStateCancelled ||
           recognizer.state == UIGestureRecognizerStateEnded)
  {
    // Handle the case where an ovum isn't dropped on a drop target
    OBOvum *ovum = recognizer.ovum;
    
    // The gesture can be canceled while the ovum is on top of a target (user taps the home or power button during the drag).
    // In which case the correct action is OBDropActionNone as the gesture wasn't completed.
    if (ovum.dropAction != OBDropActionNone)
      ovum.dropAction = OBDropActionNone;
    
    UIView *handlingView = ovum.currentDropHandlingView;
    CGPoint locationInView = [hostWindow convertPoint:locationInHostWindow toView:handlingView];

    // Tell current drop target to reset itself
    id<OBDropZone> dropZone = handlingView.dropZoneHandler;
    [dropZone ovumExited:ovum inView:handlingView atLocation:locationInView];

    [self animateOvumReturningToSource:ovum];

    [self cleanupOvum:ovum];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              recognizer.ovum, OBOvumDictionaryKey,
                              recognizer, OBGestureRecognizerDictionaryKey,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:OBDragDropManagerDidEndDragNotification object:self userInfo:userInfo];
    
    // Reset the ovum recognizer
    recognizer.ovum = nil;
  }
}


-(CGPoint) applyRecenteringTo:(CGPoint)location withRecognizer:(UIGestureRecognizer *)recognizer
{
  CGPoint newCenter = location;
  UIView *dragView = recognizer.ovum.dragView;

  if (!recognizer.ovum.isCentered)
  {
    // If chosen apply initial offset to the new location.
    newCenter.x = newCenter.x - recognizer.ovum.offsetOvumAndTouch.x * recognizer.ovum.scale;
    newCenter.y = newCenter.y - recognizer.ovum.offsetOvumAndTouch.y * recognizer.ovum.scale;
  }

  if (recognizer.ovum.shouldScale)
  {
    // This is the average location of the location of all touches in the gesture.
    CGPoint newCentroid = location;
    NSUInteger numberOfTouches = recognizer.numberOfTouches;

    // If number of touches changes we need to recalculate the shift between the last
    // gesture centroid and the new gesture one to avoid the image being recentered.
    if (prevNumberOfTouches != numberOfTouches)
    {
      recognizer.ovum.shiftPinchCentroid = CGPointMake(prevPinchCentroid.x - newCentroid.x + recognizer.ovum.shiftPinchCentroid.x * recognizer.ovum.scale,
                                                       prevPinchCentroid.y - newCentroid.y + recognizer.ovum.shiftPinchCentroid.y * recognizer.ovum.scale);
      recognizer.ovum.offsetOvumAndTouch = CGPointMake(recognizer.ovum.offsetOvumAndTouch.x * recognizer.ovum.scale,
                                                       recognizer.ovum.offsetOvumAndTouch.y * recognizer.ovum.scale);

      if (numberOfTouches == 1)
      { // If the gestures continues with one finger all the scale variables are reseted.
        initialDistance = 0;
        initialFrame = dragView.frame;
        recognizer.ovum.scale = 1.0;
      }
    }

    // And update the current state for the next iteration check
    prevPinchCentroid = newCentroid;
    prevNumberOfTouches = numberOfTouches;

    // This is the transformation for rescaling the image and it needs two fingers at least.
    if (numberOfTouches > 1)
    {
      CGPoint firstTouchLocation = [recognizer locationOfTouch:0 inView:overlayWindow];
      CGFloat newDistance = [self distanceFrom:newCentroid to:firstTouchLocation];

      if (initialDistance == 0)
        initialDistance = newDistance;

      CGFloat aScale = newDistance / initialDistance;
      recognizer.ovum.scale = aScale;

      CGAffineTransform transform = CGAffineTransformIdentity;
      transform = CGAffineTransformScale(transform, recognizer.ovum.scale, recognizer.ovum.scale);
      dragView.frame = CGRectApplyAffineTransform(initialFrame, transform);
    }

    // And finally recentered depending on the shifting touch and the original offset.
    newCenter.x = newCenter.x + recognizer.ovum.shiftPinchCentroid.x * recognizer.ovum.scale;
    newCenter.y = newCenter.y + recognizer.ovum.shiftPinchCentroid.y * recognizer.ovum.scale;
  }

  return newCenter;
}


-(BOOL) ovumRecognizerShouldHandleTouch:(UIGestureRecognizer <OBDragDropGestureRecognizer>*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        id<OBOvumSource> ovumSource = recognizer.ovumSource;
        
        if ([ovumSource respondsToSelector:@selector(shouldCreateOvumFromView:)] &&
            ![ovumSource shouldCreateOvumFromView:recognizer.view])
        {
            // Workaround to cancel the gesture recognizer
            recognizer.enabled = NO;
            recognizer.enabled = YES;
            return NO;
        }
        return YES;
    }
    
    return recognizer.ovum != nil;
}


-(void) cleanupOvum:(OBOvum*)ovum
{
  if (ovum.source)
  {
    if ([ovum.source respondsToSelector:@selector(ovumDragEnded:)])
      [ovum.source ovumDragEnded:ovum];
    ovum.source = nil;
  }

  ovum.dragView = nil;
  ovum.currentDropHandlingView = nil;
}


-(CGFloat) distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
  CGFloat xDist = (point2.x - point1.x);
  CGFloat yDist = (point2.y - point1.y);
  return sqrt((xDist * xDist) + (yDist * yDist));
}

#pragma mark - Ovum External Updates

-(void) updateOvum:(OBOvum *)ovum withZoom:(CGFloat)zoom
{
  if (!ovum)
    return;
  
  // Apply external zoom to different offsets
  if (!ovum.isCentered)
  {
    CGPoint offset = [ovum offsetOvumAndTouch];
    offset.x *= zoom;
    offset.y *= zoom;
    [ovum setOffsetOvumAndTouch:offset];
  }
  
  if (ovum.shouldScale)
  {
    CGPoint offset = [ovum shiftPinchCentroid];
    offset.x *= zoom;
    offset.y *= zoom;
    [ovum setShiftPinchCentroid:offset];    
  }
  
  // Then recalculate the new center of the drag view using the 
  // current (or very last) location and the just scaled offset
  CGPoint newCenter = currentLocationInOverlayWindow;
  
  if (!ovum.isCentered)
  {
    newCenter.x = newCenter.x - ovum.offsetOvumAndTouch.x * ovum.scale;
    newCenter.y = newCenter.y - ovum.offsetOvumAndTouch.y * ovum.scale;
  }
  
  if (ovum.shouldScale)
  {
    newCenter.x = newCenter.x + ovum.shiftPinchCentroid.x * ovum.scale;
    newCenter.y = newCenter.y + ovum.shiftPinchCentroid.y * ovum.scale;
  }
  
  // Finally apply to the ovum's dragged view the zoom on its size and
  // using the new values, find its new origin. 
  UIView *draggedView = ovum.dragView;
  CGRect frame = draggedView.frame;

  frame.size.height *= zoom;
  frame.size.width *= zoom;
  
  frame.origin.x = newCenter.x - frame.size.width / 2.0;
  frame.origin.y = newCenter.y - frame.size.height / 2.0;
  
  [draggedView setFrame:frame];
  
  // Simulate a ovumMoved on the last drop zone to update that area, in case its needed.  
  id<OBDropZone> dropZone = ovum.currentDropHandlingView.dropZoneHandler;
  if ([dropZone respondsToSelector:@selector(ovumMoved:inView:atLocation:)])
  {
    CGPoint locationInView = [overlayWindow convertPoint:currentLocationInOverlayWindow toView:ovum.currentDropHandlingView];
    ovum.dropAction = [dropZone ovumMoved:ovum inView:ovum.currentDropHandlingView atLocation:locationInView];
  }
}

@end

//
//  OBDragDropProtocol.h
//  OBUserInterface
//
//  Created by Zai Chang on 3/2/12.
//  Copyright (c) 2012 Oblong Industries. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, OBDropAction)
{
  OBDropActionNone = 0,
  OBDropActionCopy = 1,
  OBDropActionMove = 2,
  OBDropActionDelete = 3,
};


@class OBOvum;
@class OBDragDropManager;
@class OBLongPressDragDropGestureRecognizer;


@protocol OBOvumSource <NSObject>

@required
-(OBOvum *) createOvumFromView:(UIView*)sourceView;

@optional

-(BOOL) shouldCreateOvumFromView:(UIView*)sourceView;

// Create the UIView that will follow a user's touch while it moves around the screen
-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)window;
-(void) dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location;

// In all honesty, the above delegate method could also serve as a 'will begin' message
// but adding this here to be a little more explicit
-(void) ovumDragWillBegin:(OBOvum*)ovum;

// The following allows an ovum source to react appropriate if an ovum that originated from it
// was dropped. For example, if the drag drop action is move, the source can remove the source view
-(void) ovumWasDropped:(OBOvum*)ovum withDropAction:(OBDropAction)dropAction;

// Called regardless of whether the ovum drop was successful or cancelled
-(void) ovumDragEnded:(OBOvum*)ovum;

// If this delegate method is implemented, OBDragDropManager will not automatically animate the returning of the ovum to the source
-(void)handleReturningToSourceAnimationForOvum:(OBOvum*)ovum completion:(void (^)(void))completion;

@end



@protocol OBDropZone <NSObject>

@required
-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location;

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location;
-(void) ovumExited:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location;

@optional
-(OBDropAction) ovumMoved:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location;

// If this delegate method is implemented, OBDragDropManager will not automatically animate the disappearance
// of the ovum's drag view and the delegate is required to call the following method to make sure all the
// necessary cleanup is done:
// -(void) animateOvumDrop:(OBOvum*)ovum withAnimation:(void (^)()) dropAnimation completion:(void (^)(BOOL completed))completion;
-(void) handleDropAnimationForOvum:(OBOvum*)ovum withDragView:(UIView*)dragView dragDropManager:(OBDragDropManager*)dragDropManager;

@end



@protocol OBDragDropGestureRecognizer <NSObject>

@property (nonatomic, strong) OBOvum *ovum;
@property (nonatomic, weak) id<OBOvumSource> ovumSource;

@end



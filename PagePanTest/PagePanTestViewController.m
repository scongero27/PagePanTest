//
//  PagePanTestViewController.m
//  PagePanTest
//
//  Created by Spencer Congero on 9/25/13.
//  Copyright (c) 2013 Spencer Congero. All rights reserved.
//

#import "PagePanTestViewController.h"

@interface PagePanTestViewController ()

@property (strong, nonatomic) UIView *prevView;
@property (strong, nonatomic) UIView *currView;
@property (strong, nonatomic) UIView *nextView;
@property (strong, nonatomic) UIView *aView;

@end

@implementation PagePanTestViewController

- (void)startView:(UIView *)aView
{
    self.aView.frame = [self frameForCurrentViewWithTranslate:0];
}

-(UIView *) prevView
{
    if (!_prevView)
    {
        _prevView = [[UIView alloc] init];
    }
    return _prevView;
}
-(UIView *) currView
{
    if (!_currView)
    {
        _currView = [[UIView alloc] init];
    }
    return _currView;
}
-(UIView *) nextView
{
    if (!_nextView)
    {
        _nextView = [[UIView alloc] init];
    }
    return _nextView;
}

- (CGRect)frameForPreviousViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(-self.view.bounds.size.width + translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForCurrentViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGRect)frameForNextViewWithTranslate:(CGPoint)translate
{
    return CGRectMake(self.view.bounds.size.width + translate.x, translate.y, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    // transform the three views by the amount of the x translation
    
    CGPoint translate = [gesture translationInView:gesture.view];
    translate.y = 0.0; // I'm just doing horizontal scrolling
    
    self.prevView.frame = [self frameForPreviousViewWithTranslate:translate];
    self.currView.frame = [self frameForCurrentViewWithTranslate:translate];
    self.nextView.frame = [self frameForNextViewWithTranslate:translate];
    
    // if we're done with gesture, animate frames to new locations
    
    if (gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed)
    {
        // figure out if we've moved (or flicked) more than 50% the way across
        
        CGPoint velocity = [gesture velocityInView:gesture.view];
        if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (gesture.view.bounds.size.width / 2.0) && self.prevView)
        {
            // moving right (and/or flicked right)
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.prevView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 self.currView.frame = [self frameForNextViewWithTranslate:CGPointZero];
                             }
                             completion:^(BOOL finished) {
                                 // do whatever you want upon completion to reflect that everything has slid to the right
                                 
                                 // this redefines "next" to be the old "current",
                                 // "current" to be the old "previous", and recycles
                                 // the old "next" to be the new "previous" (you'd presumably.
                                 // want to update the content for the new "previous" to reflect whatever should be there
                                 
                                 UIView *tempView = self.nextView;
                                 self.nextView = self.currView;
                                 self.currView = self.prevView;
                                 self.prevView = tempView;
                                 self.prevView.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                             }];
        }
        else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(gesture.view.frame.size.width / 2.0) && self.nextView)
        {
            // moving left (and/or flicked left)
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.nextView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 self.currView.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                             }
                             completion:^(BOOL finished) {
                                 // do whatever you want upon completion to reflect that everything has slid to the left
                                 
                                 // this redefines "previous" to be the old "current",
                                 // "current" to be the old "next", and recycles
                                 // the old "previous" to be the new "next". (You'd presumably.
                                 // want to update the content for the new "next" to reflect whatever should be there
                                 
                                 UIView *tempView = self.prevView;
                                 self.prevView = self.currView;
                                 self.currView = self.nextView;
                                 self.nextView = tempView;
                                 self.nextView.frame = [self frameForNextViewWithTranslate:CGPointZero];
                             }];
        }
        else
        {
            // return to original location
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.prevView.frame = [self frameForPreviousViewWithTranslate:CGPointZero];
                                 self.currView.frame = [self frameForCurrentViewWithTranslate:CGPointZero];
                                 self.nextView.frame = [self frameForNextViewWithTranslate:CGPointZero];
                             }
                             completion:NULL];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

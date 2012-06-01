//
//  SCSFlipsideViewController.h
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCSFlipsideViewController;

@protocol SCSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(SCSFlipsideViewController *)controller;
@end

@interface SCSFlipsideViewController : UIViewController

@property (weak, nonatomic) id <SCSFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end

//
//  SCSMainViewController.h
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSFlipsideViewController.h"

@interface SCSMainViewController : UIViewController <SCSFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end

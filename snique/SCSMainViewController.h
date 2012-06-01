//
//  SCSMainViewController.h
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

@interface SCSMainViewController : UIViewController <UIWebViewDelegate>
{
    BOOL stealthy;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

-(IBAction)threeFingerTap:(id)sender;
@end

//
//  SCSMainViewController.m
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSMainViewController.h"

@interface SCSMainViewController ()
-(void)colourBar;
-(void)updateTitle;
@end

@implementation SCSMainViewController

@synthesize navBar,webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithScheme:@"http" host:@"blog.nomzit.com" path:@"/snique"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)threeFingerTap:(id)sender
{
    stealthy = !stealthy;
    [self updateTitle];
    [self colourBar];
}

-(void)updateTitle
{
    navBar.topItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
    [navBar setNeedsDisplay];
}

-(void)colourBar
{
    if (stealthy)
        navBar.tintColor = [UIColor colorWithRed:204.0/255.0 green:0.0 blue:106.0/255.0 alpha:1.0f];
    else
        navBar.tintColor = [UIColor blackColor];
}

#pragma mark - WebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)_webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end

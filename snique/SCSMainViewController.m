//
//  SCSMainViewController.m
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSMainViewController.h"
#import "SCSCache.h"
#import "SCSSniqueDecoder.h"
#import "SCSSniqueWebViewExtractor.h"
#import "SCSAppDelegate.h"
#import "NSData+SCSSnique.h"

@interface SCSMainViewController ()
-(void)updateBackNextButtons;
-(void)updateTitle;
-(void)updateKVStoreItems:(NSNotification *)note;
@property(readwrite,nonatomic,strong)SCSSniqueDecoder *decoder;
@property(readwrite,nonatomic,strong)SCSSniqueWebViewExtractor *extractor;
@end

NSString * const kSecretKeyKey = @"SCSSniqueSecretKey";

@implementation SCSMainViewController
@synthesize decoder,extractor;
@synthesize navBar,webView,titleLabel,addressField,leftItems;
@synthesize reloadButton,stopButton,backButton,nextButton;

-(void)bookMarksTapped:(id)sender
{
    [webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithScheme:@"http" host:@"blog.nomzit.com" path:@"/snique"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self bookMarksTapped:nil];
    navBar.topItem.leftBarButtonItems = leftItems;
    self.decoder = [[SCSSniqueDecoder alloc] initWithKey:[[NSUserDefaults standardUserDefaults] dataForKey:kSecretKeyKey]];
    self.extractor = [[SCSSniqueWebViewExtractor alloc] init];
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateKVStoreItems:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    [store synchronize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.decoder = nil;
    self.extractor = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)updateTitle
{
    titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
}

-(void)titleTapped:(id)sender
{
    titleLabel.hidden = YES;
    addressField.hidden = NO;
    addressField.text = webView.request.URL.absoluteString;
    [addressField becomeFirstResponder];
}

#pragma mark - TextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *address = textField.text;
    if (address.length > 0)
    {
        if ([address rangeOfString:@"set-key:"].location == 0)
        {
            NSString *hexKey = [address substringFromIndex:8];
            NSData *newKey = [NSData scsHexDataFromString:hexKey];
            if ((newKey.length == 16) || (newKey.length == 32))
            {
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:newKey forKey:kSecretKeyKey];
                [userDefaults synchronize];
                self.decoder = [[SCSSniqueDecoder alloc] initWithKey:newKey];
                [[NSUbiquitousKeyValueStore defaultStore] setData:newKey forKey:kSecretKeyKey];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Invalid Key"
                                            message:@"Key must contain 32 or 64 hexadecimal digits"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                return NO;
            }
        }
        else
        {
            NSURL *url = nil;
            if ([address rangeOfString:@" "].location != NSNotFound)
            {
                url = [[NSURL alloc] initWithScheme:@"http"
                                               host:@"www.google.com"
                                               path:[@"/search?btnG=1&pws=0&q=" stringByAppendingString:[[address stringByReplacingOccurrencesOfString:@" " withString:@"+"]
                                                                                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
            else
                url = [[NSURL alloc] initWithString:address];
            if (!url.scheme.length)
            {
                url = [[NSURL alloc] initWithString:[@"http://" stringByAppendingString:address]];
            }
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.hidden = YES;
    titleLabel.hidden = NO;
}

-(void)updateBackNextButtons
{
    backButton.enabled = webView.canGoBack;
    nextButton.enabled = webView.canGoForward;
}

-(void)updateKVStoreItems:(NSNotification *)note
{
    NSDictionary* userInfo = [note userInfo];
    NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSInteger reason = -1;
    
    if (!reasonForChange)
        return;
    
    reason = [reasonForChange integerValue];
    if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
        (reason == NSUbiquitousKeyValueStoreInitialSyncChange))
    {
        NSArray* changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        for (NSString* key in changedKeys)
        {
            id value = [store objectForKey:key];
            [userDefaults setObject:value forKey:key];
        }
        [userDefaults synchronize];
        self.decoder = [[SCSSniqueDecoder alloc] initWithKey:[[NSUserDefaults standardUserDefaults] dataForKey:kSecretKeyKey]];
    }
}
#pragma mark - WebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)_webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    navBar.topItem.rightBarButtonItem = stopButton;
    [self updateBackNextButtons];
}

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    navBar.topItem.rightBarButtonItem = reloadButton;
    [extractor extractMessageFromWebView:_webView
                             withDecoder:decoder
                           actionIfFound:^(NSString *message)
    {
        UILocalNotification *note = [[UILocalNotification alloc] init];
        note.fireDate = [NSDate date];
        note.alertBody = message;
        [(SCSAppDelegate *)[UIApplication sharedApplication].delegate setIgnoreNextLocalNotification:YES];
        [[UIApplication sharedApplication] presentLocalNotificationNow:note];
    }];
    [self updateTitle];
    [self updateBackNextButtons];
}

@end

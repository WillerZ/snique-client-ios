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

@interface SCSMainViewController ()
-(void)updateBackNextButtons;
-(void)updateTitle;
-(NSData *)hexDataFromString:(NSString *)string;
-(void)updateKVStoreItems:(NSNotification *)note;
@property(readwrite,nonatomic,strong)SCSSniqueDecoder *decoder;
@end

NSString * const kSecretKeyKey = @"SCSSniqueSecretKey";

@implementation SCSMainViewController
@synthesize decoder;
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

-(NSArray *)messageFromWebview:(UIWebView *)_webView
{
    NSMutableArray *message = [[NSMutableArray alloc] init];
    NSString *theHtml = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;"];
    NSRegularExpression *srcRegex = [[NSRegularExpression alloc] initWithPattern:@"src\\s*=\\s*['\"]([^'\"]*)['\"]"
                                                                         options:0
                                                                           error:nil];
    [srcRegex enumerateMatchesInString:theHtml
                               options:0
                                 range:NSMakeRange(0, theHtml.length)
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        NSString *src = [theHtml substringWithRange:[result rangeAtIndex:1]];
        if ([src length])
        {
            NSURL *url = [NSURL URLWithString:src];
            NSString *eTag = [(SCSCache *)[NSURLCache sharedURLCache] etagForResourceAtLocation:url];
            if (eTag)
            {
                NSRange range;
                range.length = eTag.length - 2;
                range.location = 1;
                if (([eTag characterAtIndex:0] == 'W') || ([eTag characterAtIndex:0] == 'w'))
                {
                    range.length -= 1;
                    range.location = 2;
                }
                [message addObject:[self hexDataFromString:[eTag substringWithRange:range]]];
            }
        }
    }];
    return message;
}

-(NSData *)hexDataFromString:(NSString *)string
{
    NSData *hexData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableData *data = [[NSMutableData alloc] initWithLength:1 + hexData.length/2];
    unsigned char *out = data.mutableBytes;
    const unsigned char *in = hexData.bytes;
    NSUInteger hexIndex = 0;
    for (NSUInteger i = 0,j = 0; i < hexData.length; ++i)
    {
        unsigned char half = 0;
        switch (in[i])
        {
            case 'f': case 'F': half = 0xfu; break;
            case 'e': case 'E': half = 0xeu; break;
            case 'd': case 'D': half = 0xdu; break;
            case 'c': case 'C': half = 0xcu; break;
            case 'b': case 'B': half = 0xbu; break;
            case 'a': case 'A': half = 0xau; break;
            case '9': half = 9u; break;
            case '8': half = 8u; break;
            case '7': half = 7u; break;
            case '6': half = 6u; break;
            case '5': half = 5u; break;
            case '4': half = 4u; break;
            case '3': half = 3u; break;
            case '2': half = 2u; break;
            case '1': half = 1u; break;
            case '0': half = 0u; break;
            default:
                continue;
        }
        if (hexIndex & 1)
        {
            out[j] |= half;
            ++j;
        }
        else
        {
            out[j] = half << 4;
        }
        ++hexIndex;
    }
    data.length = hexIndex >>1;
    return data;
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
            NSData *newKey = [self hexDataFromString:hexKey];
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
    NSArray *message = [self messageFromWebview:_webView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *decoded = [decoder decodeMessage:message];
        if (decoded)
        {
            UILocalNotification *note = [[UILocalNotification alloc] init];
            note.fireDate = [NSDate date];
            note.alertBody = decoded;
            [[UIApplication sharedApplication] presentLocalNotificationNow:note];
        }
    });
    [self updateTitle];
    [self updateBackNextButtons];
}

@end

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
-(void)colourBar;
-(void)updateTitle;
-(void)loadPage;
-(NSData *)hexDataFromString:(NSString *)string;
@end

static const unsigned char keyRaw[] =
{
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff
};

@implementation SCSMainViewController

@synthesize navBar,webView;

-(void)loadPage
{
    [webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initWithScheme:@"http" host:@"blog.nomzit.com" path:@"/snique"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    stealthy = YES;
    [self loadPage];
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

-(void)refreshTapped:(id)sender
{
    [self loadPage];
}

-(void)updateTitle
{
    navBar.topItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
}

-(void)colourBar
{
    if (stealthy)
        navBar.tintColor = [UIColor colorWithRed:204.0/255.0 green:0.0 blue:106.0/255.0 alpha:1.0f];
    else
        navBar.tintColor = [UIColor blackColor];
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

#pragma mark - WebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)_webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSArray *message = [self messageFromWebview:_webView];
    NSString *decoded = [[[SCSSniqueDecoder alloc] initWithKey:[NSData dataWithBytesNoCopy:keyRaw length:sizeof(keyRaw) freeWhenDone:NO]] decodeMessage:message];
    if (decoded)
    {
        UILocalNotification *note = [[UILocalNotification alloc] init];
        note.fireDate = [NSDate date];
        note.alertBody = decoded;
        [[UIApplication sharedApplication] scheduleLocalNotification:note];
    }
    [self updateTitle];
}

@end

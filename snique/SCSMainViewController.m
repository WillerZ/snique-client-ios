//
//  SCSMainViewController.m
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSMainViewController.h"
#import "SCSCache.h"
#import <CommonCrypto/CommonCryptor.h>

@interface SCSMainViewController ()
-(void)colourBar;
-(void)updateTitle;
-(void)loadPage;
@end

static const unsigned char keyRaw[] =
{
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff
};
static const unsigned char ivRaw[] =
{
    0xff, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00
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
    stealthy = YES;
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
    NSString *title = nil;
    if (stealthy)
    {
        NSMutableString *codedString = [[NSMutableString alloc] init];
        NSUInteger count = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('pix').childNodes.length"] intValue];
        NSLog(@"Element id pix has %u children",count);
        for (NSUInteger index = 0; index < count; ++index)
        {
            NSString *src = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('pix').childNodes[%u].getAttribute('src')",index]]; 
            if ([src length])
            {
                NSURL *url = [NSURL URLWithString:src];
                NSString *eTag = [(SCSCache *)[NSURLCache sharedURLCache] etagForResourceAtLocation:url];
                if (eTag)
                {
                    NSRange range;
                    range.length = eTag.length - 2;
                    range.location = 1;
                    [codedString appendString:[eTag substringWithRange:range]];
                }
                NSLog(@"SRC %@",src);
                NSLog(@"URL %@ - ETag %@",url,eTag);
            }
        }
        title = [codedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSData *hexData = [title dataUsingEncoding:NSASCIIStringEncoding];
        NSMutableData *data = [[NSMutableData alloc] initWithLength:1 + hexData.length/2];
        unsigned char *out = data.mutableBytes;
        const unsigned char *in = hexData.bytes;
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
                default:
                    break;
            }
            if (i & 1)
            {
                out[j] |= half;
                ++j;
            }
            else
            {
                out[j] = half << 4;
            }
        }
        data.length = hexData.length/2;
        NSMutableData *decoded = [[NSMutableData alloc] initWithLength:data.length + 32];
        size_t decodedLength = 0;
        size_t firstDecodedLength = 0;
        size_t finalBlockLength = 0;
        CCCryptorStatus cs;
        CCCryptorRef cryptor;
        cs = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyRaw, sizeof(keyRaw), ivRaw, &cryptor);
        NSAssert1(cs == kCCSuccess,@"CCCryptorCreate failed %d",cs);
        cs = CCCryptorUpdate(cryptor, [data bytes], 32, decoded.mutableBytes, decoded.length, &firstDecodedLength);
        if (cs == kCCSuccess)
        {
            struct {uint32_t eyecatcher; uint32_t length;} *hdr = decoded.mutableBytes;
            uint32_t eyecatcher = CFSwapInt32BigToHost(hdr->eyecatcher);
            uint32_t length = CFSwapInt32BigToHost(hdr->length);
            if (eyecatcher == 0xFACEF00DU)
            {
                cs = CCCryptorUpdate(cryptor, [data bytes] + 32, [data length] - 32, decoded.mutableBytes + firstDecodedLength, decoded.length - firstDecodedLength, &decodedLength);
                NSAssert1(cs == kCCSuccess,@"CCCryptorUpdate failed %d",cs);
                decodedLength += firstDecodedLength;
                cs = CCCryptorFinal(cryptor, decoded.mutableBytes + decodedLength, decoded.length - decodedLength, &finalBlockLength);
                decodedLength += finalBlockLength;
                decoded.length = decodedLength;
                NSRange messageRange = { 8, length };
                title = [[NSString alloc] initWithData:[decoded subdataWithRange:messageRange] encoding:NSUTF8StringEncoding];
            }
            else 
            {
                title = @"No concealed message here";
            }
        }
    }
    else
    {
        title = [webView stringByEvaluatingJavaScriptFromString:@"document.title;"];
    }
    navBar.topItem.title = title;
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
    [self updateTitle];
}

@end

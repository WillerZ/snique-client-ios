//
//  SCSWebAddressInputAccessoryView.m
//  snique
//
//  Created by Philip Willoughby on 16/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSWebAddressInputAccessoryView.h"

@interface SCSWebAddressInputAccessoryView ()

-(void)playClickAndInsert:(NSString *)string;

-(void)httpButtonTapped:(id)sender;
-(void)httpsButtonTapped:(id)sender;
-(void)dotButtonTapped:(id)sender;
-(void)slashButtonTapped:(id)sender;
-(void)dotcomButtonTapped:(id)sender;

-(void)addBar;
@end

@implementation SCSWebAddressInputAccessoryView
@synthesize target;

-(void)addBar
{
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:self.bounds];
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bar.barStyle = UIBarStyleBlackTranslucent;
    UIBarItem *httpItem = [[UIBarButtonItem alloc] initWithTitle:@"http://"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(httpButtonTapped:)];
    UIBarItem *httpsItem = [[UIBarButtonItem alloc] initWithTitle:@"https://"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(httpsButtonTapped:)];
    UIBarItem *dotItem = [[UIBarButtonItem alloc] initWithTitle:@"."
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(dotButtonTapped:)];
    UIBarItem *slashItem = [[UIBarButtonItem alloc] initWithTitle:@"/"
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(slashButtonTapped:)];
    UIBarItem *dotcomItem = [[UIBarButtonItem alloc] initWithTitle:@".com"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(dotcomButtonTapped:)];
    UIBarItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                     target:nil
                                                                     action:NULL];
    NSArray *barItems = [[NSArray alloc] initWithObjects:httpItem,httpsItem,space,dotItem,slashItem,dotcomItem, nil];
    bar.items = barItems;
    [self addSubview:bar];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self addBar];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self addBar];
    return self;
}

-(BOOL)enableInputClicksWhenVisible
{
    return YES;
}

-(void)httpButtonTapped:(id)sender
{
    [self playClickAndInsert:@"http://"];
}

-(void)httpsButtonTapped:(id)sender
{
    [self playClickAndInsert:@"https://"];
}

-(void)dotButtonTapped:(id)sender
{
    [self playClickAndInsert:@"."];
}

-(void)slashButtonTapped:(id)sender
{
    [self playClickAndInsert:@"/"];
}

-(void)dotcomButtonTapped:(id)sender
{
    [self playClickAndInsert:@".com"];
}

-(void)playClickAndInsert:(NSString *)string
{
    [[UIDevice currentDevice] playInputClick];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    NSArray *items = [pb items];
    pb.string = string;
    [target paste:self];
    pb.items = items;
}

@end

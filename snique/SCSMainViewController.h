//
//  SCSMainViewController.h
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

extern NSString * const kSecretKeyKey;

@interface SCSMainViewController : UIViewController <UIWebViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *addressField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (strong, nonatomic) IBOutlet UIView *urlInputAccessoryView;
@property (strong, nonatomic) IBOutletCollection(UIBarItem)NSArray *leftItems;

-(IBAction)bookMarksTapped:(id)sender;
-(IBAction)titleTapped:(id)sender;
@end

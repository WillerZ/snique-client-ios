//
//  SCSWebAddressInputAccessoryView.h
//  snique
//
//  Created by Philip Willoughby on 16/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCSWebAddressInputAccessoryView : UIView <UIInputViewAudioFeedback>

@property(readwrite,weak,nonatomic)IBOutlet UIResponder *target;
@end

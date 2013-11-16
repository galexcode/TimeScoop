//
//  CustomButton.h


/**
 * Custom uibarbutton creater class.
 */

#import <UIKit/UIKit.h>

@interface CustomButton : UIBarButtonItem

+ (UIBarButtonItem*)createBackButtonWithTitle:(NSString*)title withTarget:(id)targ withSelector:(SEL)select;

@end
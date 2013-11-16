//
//  CustomButton.m


#import "CustomButton.h"

@implementation CustomButton

/**
 * Create a custom button with some general properties.
 * @return UIButton button to return.
 */
+ (UIButton*)initButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 6.0);
    return button;
}

/**
 * Create a custom back barbutton with title, target and selector.
 * @param title title of button
 * @param targ target of button (e.g.: mainViewController)
 * @param select selector the button should call when pressed.
 * @return UIBarButtonItem barbutton to return.
 */
+ (UIBarButtonItem*)createBackButtonWithTitle:(NSString*)title withTarget:(id)targ withSelector:(SEL)select
{
    UIImage *buttonImage = [[UIImage imageNamed:@"backButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:5];
    UIButton *backButton = [self initButton];
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 13.0, 0, 6.0);
    [backButton setTitle:title forState:UIControlStateNormal];
    CGSize textSize = [backButton.titleLabel.text sizeWithFont:backButton.titleLabel.font];
    backButton.frame = CGRectMake(0, 0, textSize.width + (14.0 * 1.5), buttonImage.size.height);
    [backButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [backButton addTarget:targ action:select forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

@end
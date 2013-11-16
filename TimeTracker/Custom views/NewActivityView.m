//
//  NewActivityView.m
//  TimeTracker


#import "NewActivityView.h"
#import "AppDelegate.h"
#import "CoreDataHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation NewActivityView

/**
 * Custom initializer method.
 * @param frame frame of the view
 * @param delegateObject delegate object.
 * @return id id object to return.
 */
- (id)initWithFrame:(CGRect)frame andDelegate:(id<NewActivityDelegate>)delegateObject
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel *label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(10.0, 10.0, self.frame.size.width-20.0, 40.0)];
        [label setText:@"Enter the name of your activity you wish to add to your activity list."];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:14.0]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setNumberOfLines:0];
        [self addSubview:label];
        
        self.textfield = [[UITextField alloc] init];
        self.textfield.frame = CGRectMake(10.0, 55.0, self.frame.size.width-20.0, 30.0);
        self.textfield.borderStyle = UITextBorderStyleRoundedRect;
        self.textfield.placeholder = @"Enter activity name here";
        self.textfield.textAlignment = NSTextAlignmentLeft;
        self.textfield.textColor = [UIColor blackColor];
        self.textfield.font = [UIFont systemFontOfSize:16.0];
        [self.textfield setMinimumFontSize:10.0];
        [self.textfield setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self.textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self.textfield setReturnKeyType:UIReturnKeyDone];
        self.textfield.delegate = self;
        self.frame = frame;
        [self addSubview:self.textfield];
        self.delegate = delegateObject;
        [self setBackgroundColor:[UIColor grayColor]];
        [self.layer setCornerRadius:6.0];
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
        [self.layer setShadowOpacity:0.7];
        [self.layer setShadowRadius:3.0];
    }
    return self;
}

/**
 * Save an activity to core data if it is not already in the core data or not null.
 * @param name name of activity to be saved.
 */
- (void)saveItem:(NSString*)name
{
    if (![CoreDataHandler isDuplicate:name])
    {
        if ([name length] != 0)
        {
            [CoreDataHandler addNewEntityName:name];
            if ([self.delegate respondsToSelector:@selector(activitySaved)])
            {
                [self.delegate activitySaved];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate"
                                                        message:@"This activity is already in your activity list."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        if ([self.delegate respondsToSelector:@selector(activitySaved)])
        {
            [self.delegate activitySaved];
        }
    }
}

/**
 * Slide the view down with animation and make the textfield active.
 */
- (void)slideViewDown
{
    __block CGRect frame = self.frame;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:
                     ^{
                         frame.origin.y = -10.0;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [self.textfield becomeFirstResponder];
                     }];
}

/**
 * Slide the view up with animation and make the textfield inactive.
 */
- (void)slideViewUp
{
    __block CGRect frame = self.frame;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:
                     ^{
                         frame.origin.y = -100.0;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [self.textfield resignFirstResponder];
                     }];
}

/**
 * Asks the delegate if the text field should process the pressing of the return button. Animate the view back up and save the item to core data if possible.
 * @param textField The text field whose return button was pressed.
 * @return BOOL YES if the text field should implement its default behavior for the return button; otherwise, NO.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self slideViewUp];
    [self saveItem:textField.text];
    [textField resignFirstResponder];
    textField.text = @"";
    return NO;
}

/**
 * Dealloc method to deallocate references and outlets.
 */
- (void)dealloc
{
    self.delegate = nil;
    [self setTextfield:nil];
}

@end
//
//  NewActivityView.h
//  TimeTracker

#import <UIKit/UIKit.h>

@class Activity;

/**
 * Delegate protocol.
 */
@protocol NewActivityDelegate <NSObject>
/**
 * Delegate method to tell the view controller that an activity has been saved.
 */
- (void)activitySaved;
@end

/**
 * A view to add new activities.
 */
@interface NewActivityView : UIView <UITextFieldDelegate>

/// delegate object
@property (nonatomic, weak) id<NewActivityDelegate>delegate;
/// textfield 
@property (nonatomic, strong) UITextField *textfield;

- (id)initWithFrame:(CGRect)frame andDelegate:(id<NewActivityDelegate>)delegateObject;
- (void)slideViewDown;
- (void)slideViewUp;
- (void)saveItem:(NSString*)name;

@end
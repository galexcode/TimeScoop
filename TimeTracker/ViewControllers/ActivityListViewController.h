//
//  ActivityListViewController.h
//  TimeTracker


#import <UIKit/UIKit.h>
#import "NewActivityView.h"

@class Activity;

/**
 * Delegate protocol
 */
@protocol ActivityListDelegate <NSObject>
/**
 * Delegate method.
 * @param activity activity that was selected
 */
- (void)activitySelected:(Activity*)activity;
@end

/**
 * View controller that holds all the activities
 */
@interface ActivityListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NewActivityDelegate, NSFetchedResultsControllerDelegate>

/// managed object context
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
/// delegate object
@property (nonatomic, weak) id <ActivityListDelegate> delegate;
/// table view to display cells
@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NewActivityView *newActivityView;
/// activity array to hold all activities
@property (nonatomic, strong) NSMutableArray *activitiesArray;
/// view to display if there are no activities to be displayed
@property (weak, nonatomic) IBOutlet UIView *noItemsImage;

- (id)initWithDelegateObject:(id<ActivityListDelegate>)delegateObj;

@end
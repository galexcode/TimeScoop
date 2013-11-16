//
//  MainViewController.h
//  TimeTracker

/**
 * Main View controller that handles the running of the activity and displaying it's properties.
 */

#import <UIKit/UIKit.h>
#import "ActivityListViewController.h"
#import "History.h"

@class Activity;

@interface MainViewController : UIViewController <ActivityListDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

/// boolean value to determine whether an activity is running
@property (nonatomic) BOOL isActivityRunning;
/// boolean value to determine whether an activity is paused
@property (nonatomic) BOOL isActivityPaused;
/// passed seconds from start
@property (nonatomic) int passedSeconds;
/// date of start
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSTimer *activityTimer;
/// the choosen activity object to use
@property (nonatomic, strong) Activity *choosenActivity;

/// tableview to display today's activities
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/// start and pause button
@property (weak, nonatomic) IBOutlet UIButton *startPauseButton;
/// stop button
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
/// label to display the current seconds
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
/// label to display the start date and name of activity
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;

/// view to display if there are no activities to be displayed
@property (weak, nonatomic) IBOutlet UIView *noItemsImage;

- (IBAction)startPauseActivity;
- (IBAction)stopActivity;

- (void)appLoadedFromBackground;
- (void)appGoesIntoBackground;

@end
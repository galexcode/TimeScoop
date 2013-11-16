//
//  HistoryViewController.h
//  TimeTracker

/**
 * History view controller to display the history objects from core data.
 */
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate>
{
    /// button to export items
    __weak IBOutlet UIBarButtonItem *exportButton;
    /// button to clear the list view
    __weak IBOutlet UIBarButtonItem *clearButton;
}
/// table view to display items
@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
/// view to display if there are no activities to be displayed
@property (weak, nonatomic) IBOutlet UIView *noItemsImage;

- (IBAction)deleteItems:(id)sender;
- (IBAction)exportItems:(id)sender;
- (void)loadCoreDataEntities;

@end
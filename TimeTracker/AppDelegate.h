//
//  AppDelegate.h
//  TimeTracker


#import <UIKit/UIKit.h>

/**
 Application appDelegate that is responsible for loading the application.
 */

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

/// application's main window
@property (strong, nonatomic) UIWindow *window;
/// application's main navigation controller that handles navigation bw views
@property (strong, nonatomic) UINavigationController *navController;
/// application's mainViewController that holds everything in place
@property (strong, nonatomic) MainViewController *mainViewController;

/// core data managed object context
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
/// core data managed object model
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
/// core data store coordinator
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

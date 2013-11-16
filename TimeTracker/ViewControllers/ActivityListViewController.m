//
//  ActivityListViewController.m
//  TimeTracker

#import "ActivityListViewController.h"
#import "Activity.h"
#import "AppDelegate.h"
#import "CustomButton.h"
#import <QuartzCore/QuartzCore.h>

@interface ActivityListViewController ()
///custom fadeview to make unavailable to hit an activity while adding new one
@property (nonatomic, strong) UIView *fadeView;
/// a fetchcontroller
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@end
@implementation ActivityListViewController
@synthesize fetchController = _fetchController;

/**
 * Custom class initializer
 * @param delegateObj delegate object.
 * @return id id object to return
 */
- (id)initWithDelegateObject:(id<ActivityListDelegate>)delegateObj
{
    self = [super init];
    if (self)
    {
        self.delegate = delegateObj;
    }
    return self;
}

/**
 * Special getter for fade view for better performance.
 * @return UIView the activity view to return.
 */
- (UIView*)fadeView
{
    if (_fadeView == nil)
    {
        _fadeView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_fadeView setBackgroundColor:[UIColor blackColor]];
        [_fadeView setAlpha:0.6];
    }
    return _fadeView;
}

/**
 * Special getter for newActivity view for better performance.
 * @return NewActivityView the activity view to return.
 */
- (NewActivityView*)newActivityView
{
    if (_newActivityView == nil)
    {
        CGRect frame = CGRectMake(10.0, -100.0, self.view.frame.size.width-20.0, 100.0);
        _newActivityView = [[NewActivityView alloc] initWithFrame:frame andDelegate:self];
        [self.view addSubview:_newActivityView];
    }
    return _newActivityView;
}

#pragma mark  Fetch controller delegate methods
/**
 * Special getter for NSFetchedResultsController to fetch activity entities from core data. Because it costs a lot to initalize a NSFetchedResultsController.
 * @return NSFetchedResultsController a fetchController
 */
- (NSFetchedResultsController*)fetchController
{
    if (_fetchController != nil) {
        return _fetchController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                           managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                                      cacheName:@"Activity"];
    _fetchController.delegate = self;
    return _fetchController;
}

/**
 * Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
 * @param controller The fetched results controller that sent the message.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView beginUpdates];
}

/**
 * Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update. The fetched results controller reports changes to its section before changes to the fetch result objects.
 * @param controller The fetched results controller that sent the message.
 * @param anObject The object in controller’s fetched results that changed.
 * @param indexPath The index path of the changed object (this value is nil for insertions).
 * @param type The type of change. For valid values see “NSFetchedResultsChangeType”.
 * @param newIndexPath The destination path for the object for insertions or moves (this value is nil for a deletion).
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.myTableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    if ([[self.fetchController fetchedObjects] count] == 0)
    {
        //display an empty indicator image
        [self.noItemsImage setHidden:NO];
        [self.myTableView setHidden:YES];
    }
    else
    {
        [self.noItemsImage setHidden:YES];
        [self.myTableView setHidden:NO];
        [self.myTableView reloadData];
    }
}

/**
 * Notifies the receiver of the addition or removal of a section. The fetched results controller reports changes to its section before changes to the fetched result objects.
 * @param controller The fetched results controller that sent the message.
 * @param sectionInfo The section that changed.
 * @param sectionIndex The index of the changed section.
 * @param type The type of change (insert or delete). Valid values are NSFetchedResultsChangeInsert and NSFetchedResultsChangeDelete.
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
            break;
    }
}

/**
 * Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
 * @param controller The fetched results controller that sent the message.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView endUpdates];
}

/**
 * Tells the data source to return the number of rows in a given section of a table view. (required)
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return NSInteger The number of rows in section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if ([[self.fetchController sections] count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

/**
 * Asks the data source to return the number of sections in the table view.
 * @param tableView An object representing the table view requesting this information.
 * @return NSInteger The number of sections in tableView. The default value is 1.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchController sections] count];
}

/**
 * Asks the data source for a cell to insert in a particular location of the table view.
 * @param tableView An object representing the table view requesting this information.
 * @param indexPath An index path locating a row in tableView.
 * @return UITableViewCell An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
 */
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/**
 * Configure a given cell to display the name of the activity.
 * @param cell a cell t configure
 * @param indexPath An index path locating a row in tableView.
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Activity *activity = [self.fetchController objectAtIndexPath:indexPath];
    [cell.textLabel setText:activity.name];
}

/**
 * Tells the delegate that the specified row can be edited or not.
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

/**
 * Called when an editing happened to the cell, in this case: delete. So delete the object from core data.
 * @param tableView tableview where editing will begin
 * @param editingStyle what type editing is happened (add, delete, move)
 * @param indexPath where editing will begin
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObject *activityToDelete = (Activity*)[self.fetchController objectAtIndexPath:indexPath];
        [appDelegate.managedObjectContext deleteObject:activityToDelete];
        [appDelegate saveContext];
        [self.myTableView reloadData];
    }
}

/**
 * Tells the delegate that the specified row is now selected. Pass the selected activity to the delegate method.
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Activity *activity = [self.fetchController objectAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(activitySelected:)])
    {
        [self.delegate activitySelected:activity];
    }
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"alignedCube";
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - new activity view delegate method
/**
 * Delegate method, which gets called if activity has been saved.
 */
- (void)activitySaved
{
    [self.newActivityView slideViewUp];
    [self.fadeView removeFromSuperview];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addNewActivity)];
}

#pragma mark - view methods
/**
 * Load activity entities from core data.
 */
- (void)loadCoreDataEntities
{
    NSError *error = nil;
    if (![self.fetchController performFetch:&error])
    {
        NSLog(@"Error %@, %@", error, [error userInfo]);
    }
    if ([[self.fetchController fetchedObjects] count] == 0)
    {
        //display an empty indicator image
        [self.noItemsImage setHidden:NO];
        [self.myTableView setHidden:YES];
    }
    else
    {
        [self.noItemsImage setHidden:YES];
        [self.myTableView setHidden:NO];
        [self.myTableView reloadData];
    }
}

/**
 * Handle the save notification.
 * @param aNotification notification to handle.
 */
- (void)handleSaveNotification:(NSNotification *)aNotification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:aNotification];
}

/**
 * Slide down new activity view and change the barbutton item
 */
- (void)addNewActivity
{
    [self.newActivityView slideViewDown];
    [self.view insertSubview:_fadeView belowSubview:self.newActivityView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(activitySaved)];
}

/**
 * Method to go back to previous controller.
 */
- (void)goBack
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"alignedCube";
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Called when finish loading the view, load core data entities
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"My activities";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addNewActivity)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [CustomButton createBackButtonWithTitle:@"Back"
                                                                         withTarget:self
                                                                       withSelector:@selector(goBack)];
    [self.view setBackgroundColor:[UIColor colorWithRed:43.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    [self fadeView];
    [self loadCoreDataEntities];
}

/**
 * When view did apper add obsever to handle notifications.
 * @param animated to display animated or not
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.managedObjectContext];
}

/**
 * When view did disappear remove obsever to handle notifications.
 * @param animated to display animated or not
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.managedObjectContext];
}

/**
 * Called when memory warning received.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * Dealloc method to deallocate references and outlets.
 */
- (void)dealloc
{
    self.delegate = nil;
    [self setFadeView:nil];
    [self setNewActivityView:nil];
    [self setMyTableView:nil];
    [self setActivitiesArray:nil];
    [self setFetchController:nil];
}

@end
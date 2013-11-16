//
//  MainViewController.m
//  TimeTracker


#import "MainViewController.h"
#import "Activity.h"
#import "History.h"
#import "HistoryCell.h"
#import "HistoryViewController.h"
#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()
@property (nonatomic) int totalduration;
/// the date when the user pressed the home button
@property (nonatomic, strong) NSDate *quitDate;
/// the date when the user came back to the app
@property (nonatomic, strong) NSDate *returnDate;
/// a fetchcontroller
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
/// today's date formatter
@property (nonatomic, strong) NSDateFormatter *todayDateFormatter;
@end

@implementation MainViewController

/**
 * If an activity is running save the return date to be able count the elapsed seconds between going to background and coming back. And count the passed seconds.
 */
- (void)appLoadedFromBackground
{
    if (!self.isActivityPaused)
    {
        self.returnDate = [NSDate date];
        NSTimeInterval interval = [self.returnDate timeIntervalSinceDate:self.quitDate];
        self.passedSeconds = self.passedSeconds + interval;
    }
}

/**
 * If an activity is running save the quit date to be able count the elapsed seconds between going to background and coming back.
 */
- (void)appGoesIntoBackground
{
    if (!self.isActivityPaused) {
        self.quitDate = [NSDate date];
    }
}

#pragma mark - timer related methods
/**
 * IBAction method to handle the start and pause button's press action.
 */
- (IBAction)startPauseActivity
{
    if (self.isActivityRunning) {
        //pause running activity
        [self pauseActivity];
    }else{
        //start again activity
        if (self.isActivityPaused) {
            [self activityTimer];
            self.isActivityPaused = NO;
            self.isActivityRunning = YES;
            [self.startPauseButton setTitle:@"pause" forState:UIControlStateNormal];
        }else{
            [self openActivityView];
        }
    }
}

/**
 * Stop the activity and save it to core data.
 */
- (IBAction)stopActivity
{
    [self invalidateTimer];
    self.isActivityPaused = NO;
    self.isActivityRunning = NO;
    [self.timeLabel setText:@"00   00   00"];
    [self.activityLabel setText:@"Start your activity"];
    [self.startPauseButton setTitle:@"start" forState:UIControlStateNormal];
    if (self.passedSeconds != 0)
    {
         [self saveActivityToHistory];
    }
}

#pragma mark - timer methods
/**
 * Special getter method for activityTimer
 * @return NSTimer timer object to return
 */
- (NSTimer*)activityTimer
{
    if (_activityTimer == nil) {
        _activityTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    }
    return _activityTimer;
}

/**
 * Update labels every time the timer's method called.
 */
- (void)updateLabel
{
    self.passedSeconds++;
    int seconds = self.passedSeconds % 60;
    int minutes = (self.passedSeconds / 60) % 60;
    int hours = (self.passedSeconds / 3600);
    [self.timeLabel setText:[NSString stringWithFormat:@"%.2d   %.2d   %.2d", hours, minutes, seconds]];
}

/**
 * Pause the activity.
 */
- (void)pauseActivity
{
    self.isActivityPaused = YES;
    self.isActivityRunning = NO;
    [self invalidateTimer];
    [self.startPauseButton setTitle:@"start" forState:UIControlStateNormal];
}

/**
 * Start the new activity. start timer and set properties.
 */
- (void)startActivity
{
    if (self.startDate == nil) {
        self.startDate = [NSDate date];
    }
    self.passedSeconds = 0;
    [self invalidateTimer];
    [self activityTimer];
    [self.startPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    self.isActivityPaused = NO;
    self.isActivityRunning = YES;
    self.startDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    self.activityLabel.text = [NSString stringWithFormat:@"%@ started at %@", self.choosenActivity.name, [formatter stringFromDate:self.startDate]];
}

/**
 * Invalidate the timer if valid.
 */
- (void)invalidateTimer
{
    if ([self.activityTimer isValid]) {
        [self.activityTimer invalidate];
        self.activityTimer = nil;
    }
}

/**
 * Save the finished activity to core data as a history object.
 */
- (void)saveActivityToHistory
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.startDate, @"startDate", [NSDate date], @"endDate", self.choosenActivity.name, @"name", nil];
    [CoreDataHandler saveHistoryItem:dictionary andDuration:[NSNumber numberWithInt:self.passedSeconds]];
    self.passedSeconds = 0;
    self.startDate = nil;
    self.choosenActivity = nil;
    [self.tableView reloadData];
}

#pragma mark - activityList delegate
/**
 * Delegate method from ActivityListViewController which starts the timer if it's not equal to the currently selected activity.
 * @param activity activity that was passed in
 */
- (void)activitySelected:(Activity *)activity
{
    if (![self.choosenActivity isEqual:activity])
    {
        if (self.isActivityRunning) {
            [self stopActivity];
        }
        self.choosenActivity = activity;
        [self startActivity];
    }
}

#pragma mark  Fetch controller delegate methods
/**
 * Special getter for dateFormatter. Because it costs a lot to initalize a dateformatter for every cell.
 */
+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter *instance = nil;
    if (instance == nil) {
        instance = [[NSDateFormatter alloc] init];
    }
    instance.dateFormat = @"HH:mm:ss";
    return instance;
}

/**
 * Special getter for today's dateFormatter. Because it costs a lot to initalize a dateformatter for every cell.
 */
- (NSDateFormatter*)todayDateFormatter
{
    if (_todayDateFormatter == nil) {
        _todayDateFormatter = [[NSDateFormatter alloc] init];
        [_todayDateFormatter setDateFormat:@"MM-dd"];
    }
    return _todayDateFormatter;
}

/**
 * Returns an NSDate object which represents the start of the day. (like: 0:00:00 hour)
 * @return NSDate date to return.
 */
- (NSDate *)dateByMovingToBeginningOfDay
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *parts = [[NSCalendar currentCalendar] components:flags fromDate:[NSDate date]];
    [parts setHour:0];
    [parts setMinute:0];
    [parts setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:parts];
}

/**
 * Returns an NSDate object which represents the end of the day. (like: 23:59:59 hour)
 * @return NSDate date to return.
 */
- (NSDate *)dateByMovingToEndOfDay
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *parts = [[NSCalendar currentCalendar] components:flags fromDate:[NSDate date]];
    [parts setHour:23];
    [parts setMinute:59];
    [parts setSecond:59];
    return [[NSCalendar currentCalendar] dateFromComponents:parts];
}


/**
 * Special getter for NSFetchedResultsController to fetch history entities from core data the ones which happened today. Because it costs a lot to initalize a NSFetchedResultsController.
 * @return NSFetchedResultsController a fetchController
 */
- (NSFetchedResultsController*)fetchController
{
    if (_fetchController != nil) {
        return _fetchController;
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    
    NSDate *startDate = [self dateByMovingToBeginningOfDay];
    NSDate *endDate = [self dateByMovingToEndOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate <= %@)", startDate, endDate];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    
    _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                           managedObjectContext:appDelegate.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                                      cacheName:nil];
    _fetchController.delegate = self;
    return _fetchController;
}

/**
 * Calculate the total duration of activites for today.
 * @return int summary value of durations as an integer. 
 */
- (int)calculateTotalDurationForToday
{
    int sum = 0;
    History *historyObj = nil;
    for (int i = 0; i < [[self.fetchController fetchedObjects] count]; i++)
    {
        historyObj = (History*)[self.fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        sum += [historyObj.duration intValue];
    }
    return sum;
}

/**
 * Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
 * @param controller The fetched results controller that sent the message.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
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
    UITableView *tableView = self.tableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(HistoryCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
        [self.tableView setHidden:YES];
    }
    else
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
            self.totalduration = [self calculateTotalDurationForToday];
        }];
        [self.noItemsImage setHidden:YES];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
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
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
            break;
    }
}

/**
 * Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
 * @param controller The fetched results controller that sent the message.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/***
 * Asks the delegate for the height to use for a row in a specified location.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path that locates a row in tableView.
 * @return GGFloat A floating-point value that specifies the height (in points) that row should be.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0;
}

/***
 * Asks the data source for the title of the header of the specified section of the table view. Displays the total duration of time for today.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return NSString the title of the header to return.
 */
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    int duration = self.totalduration;
    int seconds = duration % 60;
    int minutes = (duration / 60) % 60;
    int hours = (duration / 3600);
    NSString *durationText = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
    return [NSString stringWithFormat:@"Total time spent today: %@", durationText];
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
    HistoryCell *cell = (HistoryCell*)[tableView dequeueReusableCellWithIdentifier:[HistoryCell reuseIdentifier]];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/**
 * Configure a given cell to display the name of the activity.
 * @param cell a cell t configure
 * @param indexPath An index path locating a row in tableView.
 */
- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    History *history = [self.fetchController objectAtIndexPath:indexPath];
    [cell.nameLabel setText:history.name];
    NSDateFormatter *f = [self.class dateFormatter];
    [cell.startDateLabel setText:[NSString stringWithFormat:@"%@", [f stringFromDate:history.startDate]]];
    [cell.endDateLabel setText:[NSString stringWithFormat:@"%@", [f stringFromDate:history.endDate]]];
    int duration = [history.duration intValue];
    int seconds = duration % 60;
    int minutes = (duration / 60) % 60;
    int hours = (duration / 3600);
    [cell.durationLabel setText:[NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds]];
}

/**
 * Tells the delegate that the specified row is now selected. Pass the selected activity to the delegate method.
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - view methods
/**
 * Load history entities from core data.
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
        [self.tableView setHidden:YES];
    }
    else
    {
        self.totalduration = [self calculateTotalDurationForToday];
        [self.noItemsImage setHidden:YES];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
}

/**
 * Handle the save notification.
 * @param aNotification notification to handle.
 */
- (void)handleSaveNotification:(NSNotification *)aNotification
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.managedObjectContext mergeChangesFromContextDidSaveNotification:aNotification];
}

/**
 * Open history view controller.
 */
- (void)openHistoryView
{
    HistoryViewController *historyVC = [[HistoryViewController alloc] init];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"alignedCube";
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController pushViewController:historyVC animated:YES];
}

/**
 * Open activity view controller.
 */
- (void)openActivityView
{
    ActivityListViewController *actListVC = [[ActivityListViewController alloc] initWithDelegateObject:self];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"alignedCube";
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:actListVC animated:YES];
}

/**
 * Called when view has finished loading.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TimeScoop";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"History"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(openHistoryView)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Activities"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(openActivityView)];
    [self.view setBackgroundColor:[UIColor colorWithRed:43.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]];
    [self.tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:[HistoryCell reuseIdentifier]];
    [self loadCoreDataEntities];
}

/**
 * When view did apper add obsever to handle notifications.
 * @param animated to display animated or not
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:appDelegate.managedObjectContext];
}

/**
 * When view did disappear remove obsever to handle notifications.
 * @param animated to display animated or not
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:appDelegate.managedObjectContext];
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
    [self setNoItemsImage:nil];
    [self setQuitDate:nil];
    [self setReturnDate:nil];
    [self setStartPauseButton:nil];
    [self setStopButton:nil];
    [self setActivityLabel:nil];
    [self setActivityTimer:nil];
    [self setTimeLabel:nil];
    [self setTableView:nil];
    [self setChoosenActivity:nil];
}

@end
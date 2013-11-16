//
//  CoreDataHandler.m
//  TimeTracker

#import "CoreDataHandler.h"
#import "Activity.h"
#import "History.h"
#import "AppDelegate.h"

@implementation CoreDataHandler

/**
 * Tells whether the passed in activity's name is already saved or not.
 * @param activityName activity to be saved.
 * @return BOOL boolean value determining whether the activity is already in core data or not.
 */
+ (BOOL)isDuplicate:(NSString*)activityName
{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appdelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", activityName];
    [request setPredicate:pred];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    return ([objects count] != 0 ? YES : NO);
}

/**
 * Adds new activity to core data.
 * @param name activity name to be saved.
 */
+ (void)addNewEntityName:(NSString*)name
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Activity *newActivity = (Activity *)[NSEntityDescription insertNewObjectForEntityForName:@"Activity"
                                                                      inManagedObjectContext:appDelegate.managedObjectContext];
    [newActivity setName:name];
    [appDelegate saveContext];
}

/**
 * Save new history object to core data.
 * @param dictionaryToSave dictionary that holds keys and values
 * @param duration duration of the history object.
 */
+ (void)saveHistoryItem:(NSDictionary*)dictionaryToSave andDuration:(NSNumber*)duration
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    History *history = (History *)[NSEntityDescription insertNewObjectForEntityForName:@"History"
                                                                inManagedObjectContext:appDelegate.managedObjectContext];
    [history setName:[dictionaryToSave valueForKey:@"name"]];
    [history setStartDate:[dictionaryToSave valueForKey:@"startDate"]];
    [history setEndDate:[dictionaryToSave valueForKey:@"endDate"]];
    [history setDuration:duration];
    [history setUploaded:[NSNumber numberWithBool:NO]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    [history setSaveTime:[formatter stringFromDate:[NSDate date]]];
    [appDelegate saveContext];
}

/**
 * Fetch core data to get all history objects.
 * @return NSArray array of all history objects.
 */
+ (NSArray*)allHistoryItems
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (!mutableFetchResults) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"An error occured, please restart the application."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return mutableFetchResults;
}

/**
 * Fetch core data to get those history objects that haven't been exported yet.
 * @return NSArray array of history objects.
 */
+ (NSArray*)notUploadedHistoryItems
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameDescriptor, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uploaded == NO"];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (!mutableFetchResults) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"An error occured, please restart the application."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return mutableFetchResults;
}

@end
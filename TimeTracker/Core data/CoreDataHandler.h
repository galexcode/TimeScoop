//
//  CoreDataHandler.h
//  TimeTracker

/**
 * A simple class to handle all core data related methods.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHandler : NSObject

+ (BOOL)isDuplicate:(NSString*)activityName;
+ (void)addNewEntityName:(NSString*)name;
+ (void)saveHistoryItem:(NSDictionary*)dictionaryToSave andDuration:(NSNumber*)duration;
+ (NSArray*)allHistoryItems;
+ (NSArray*)notUploadedHistoryItems;

@end
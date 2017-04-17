// @author Simon Toens 04/21/13

#import <Foundation/Foundation.h>
#import "ItemPickerDataSource.h"

/**
 * The most minimal data source implementation possible.
 */
@interface SampleCityDataSource : NSObject <ItemPickerDataSource>

- (id)init;

/**
 * Adds a city to the in-memory city db.
 * 
 * @return the city that was added
 */
+ (NSString *)addCityToOregon;

/**
 * Removes a city from the in-memory city db.
 *
 * @return the city that was removed
 */
+ (NSString *)removeCityFromOregon;

@end

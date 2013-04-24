// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>

#import "ItemPickerDataSource.h"

/**
 * This data sources simulates a small music library.  It implements all methods
 * and properties of ItemPickerDataSource to demonstrate the extend of customizability
 * of the ItemPicker.
 */
@interface SampleMediaDataSource : NSObject <ItemPickerDataSource>

+ (id)artistsDataSource;
+ (id)albumsDataSource;
+ (id)songsDataSource;

@end
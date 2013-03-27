// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>

#import "ItemPickerDataSource.h"

@interface SampleDataSource : NSObject <ItemPickerDataSource>

+ (id)artistsDataSource;
+ (id)albumsDataSource;
+ (id)songsDataSource;

@end
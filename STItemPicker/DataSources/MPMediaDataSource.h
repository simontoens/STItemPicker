// @author Simon Toens 04/21/13

#import <Foundation/Foundation.h>
#import "ItemPickerDataSource.h"

@interface MPMediaDataSource : NSObject <ItemPickerDataSource>

+ (id)artistsDataSource;
+ (id)albumsDataSource;
+ (id)songsDataSource;

@end
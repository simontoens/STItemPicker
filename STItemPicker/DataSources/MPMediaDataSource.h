// @author Simon Toens 04/21/13

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ItemPickerDataSource.h"

@interface MPMediaDataSource : NSObject <ItemPickerDataSource>

+ (id)artistsDataSource;
+ (id)albumsDataSource;
+ (id)songsDataSource;

- (BOOL)artistList;
- (BOOL)albumList;
- (BOOL)songList;

@property(nonatomic, strong) MPMediaQuery *query;

@end
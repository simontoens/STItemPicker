// @author Simon Toens 04/21/13

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ItemPickerDataSource.h"

@interface MPMediaDataSource : NSObject <ItemPickerDataSource>

- (id)initArtistsDataSource;
- (id)initAlbumsDataSource;
- (id)initSongsDataSource;

- (BOOL)artistList;
- (BOOL)albumList;
- (BOOL)songList;

@property(nonatomic, strong) MPMediaQuery *query;

@end
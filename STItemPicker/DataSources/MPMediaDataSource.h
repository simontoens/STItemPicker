// @author Simon Toens 04/21/13

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ItemPickerDataSource.h"

@interface MPMediaDataSource : NSObject <ItemPickerDataSource>

- (id)initArtistDataSource;
- (id)initAlbumDataSource;
- (id)initSongDataSource;
- (id)initPlaylistDataSource;

- (BOOL)artistList;
- (BOOL)albumList;
- (BOOL)songList;
- (BOOL)playlistList;

/**
 * The MPMediaQuery backing this data source.
 */
@property (nonatomic, readonly) MPMediaQuery *query;

@end

// @author Simon Toens 04/21/13

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) UIImage *headerImage;
@property(nonatomic, strong) NSArray *images;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSArray *sections;

@property(nonatomic, strong) NSString *itemProperty;
@property(nonatomic, strong) MPMediaQuery *query;
- (id)initWithQuery:(MPMediaQuery *)runQuery itemProperty:(NSString *)itemProperty;
- (BOOL)isArtistList;
- (BOOL)isAlbumList;
- (BOOL)isSongList;

- (void)runQuery;
@end

@implementation MPMediaDataSource

static UIImage *kDefaultArtwork;

@synthesize itemProperty = _itemProperty;
@synthesize query = _query;

@synthesize headerImage = _headerImage;
@synthesize images = _images;
@synthesize items = _items;
@synthesize sections = _sections;


+ (void)initialize
{
    kDefaultArtwork = [UIImage imageNamed:@"DefaultNoArtwork.png"];
}

+ (id)artistsDataSource
{
    return [[MPMediaDataSource alloc] initWithQuery:[MPMediaQuery artistsQuery] itemProperty:MPMediaItemPropertyArtist];    
}

+ (id)albumsDataSource
{
    return [[MPMediaDataSource alloc] initWithQuery:[MPMediaQuery albumsQuery] itemProperty:MPMediaItemPropertyAlbumTitle];
}

+ (id)songsDataSource
{
    return [[MPMediaDataSource alloc] initWithQuery:[MPMediaQuery songsQuery] itemProperty:MPMediaItemPropertyTitle];
}

- (id)initWithQuery:(MPMediaQuery *)query itemProperty:(NSString *)itemProperty
{
    if (self = [super init])
    {
        _itemProperty = itemProperty;
        _query = query;
    }
    return self;
}

- (NSArray *)items
{
    [self runQuery];
    return _items;
}

- (BOOL)itemsAlreadySorted
{
    return YES;
}

- (NSArray *)itemImages
{
    [self runQuery];
    return _images;
}

- (NSString *)title
{
    if ([self isArtistList])
    {
        return @"Artists";
    }
    else if ([self isAlbumList])
    {
        return @"Albums";
    }
    else 
    {
        return @"Songs";
    }
}

- (BOOL)sectionsEnabled
{
    [self runQuery];
    return [self.items count] > 50;
}

- (NSArray *)sections
{
    [self runQuery];
    return _sections;
}

- (BOOL)autoSelectSingleItem
{
    return [self isAlbumList];
}

- (UIImage *)headerImage
{
    [self runQuery];
    return _headerImage;
}

- (UIImage *)tabImage
{
    if ([self isArtistList])
    {
        return [UIImage imageNamed:@"Artists.png"];
    }
    else if ([self isAlbumList])
    {
        return [UIImage imageNamed:@"Albums.png"];        
    } 
    else
    {
        return [UIImage imageNamed:@"Songs.png"];                
    }
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item
{
    if ([self isArtistList])
    {
        MPMediaQuery *nextQuery = [MPMediaQuery albumsQuery];
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:item forProperty:MPMediaItemPropertyArtist]];
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyAlbumTitle];
    }
    else if ([self isAlbumList])
    {
        MPMediaQuery *nextQuery = [MPMediaQuery songsQuery];        
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:item forProperty:MPMediaItemPropertyAlbumTitle]];
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyTitle];
    }
    return nil;
}

- (void)runQuery
{
    if (_items)
    {
        // already ran the query
        return;    
    }
    
    NSArray *mediaItems = _query.collections;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[mediaItems count]];
    NSMutableArray *images = nil;
    BOOL loadItemImages = [self isAlbumList];
    BOOL loadHeaderImage = [self isSongList] && [_query.filterPredicates count] > 1;
    if (loadItemImages)
    {
        images = [NSMutableArray arrayWithCapacity:[mediaItems count]];
    }
    
    _sections = _query.collectionSections;
    for (MPMediaItemCollection *collection in mediaItems)
    {
        MPMediaItem *item = [collection representativeItem];
        NSString *prop = [item valueForProperty:_itemProperty];
        [items addObject:prop];
        if (loadItemImages || (loadHeaderImage && !_headerImage))
        {
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            CGSize size = artwork.bounds.size;
            UIImage *image = [artwork imageWithSize:CGSizeMake(size.height, size.width)];
            if (image)
            {
                if (loadItemImages)
                {
                    [images addObject:image];
                }
                else 
                {
                    _headerImage = image;
                }
            } 
            else 
            {
                if (loadItemImages)
                {
                    [images addObject:kDefaultArtwork];
                }
            }
        }
        
        if (loadHeaderImage && !_headerImage)
        {
            _headerImage = kDefaultArtwork;
        }
    }
    
    _images = images;
    _items = items;
}

- (BOOL)isArtistList
{
    return self.query.groupingType == MPMediaGroupingArtist;
}

- (BOOL)isAlbumList
{
    return self.query.groupingType == MPMediaGroupingAlbum;
}

- (BOOL)isSongList 
{
    return self.query.groupingType == MPMediaGroupingTitle;
}

@end
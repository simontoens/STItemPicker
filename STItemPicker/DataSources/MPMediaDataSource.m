// @author Simon Toens 04/21/13

#import "ItemPicker.h"
#import "ItemPickerHeader.h"
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSString *itemProperty;

@property(nonatomic, strong) UIImage *tabImage;
@property(nonatomic, strong) NSString *title;

@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) NSMutableArray *itemDescriptions;
@property(nonatomic, strong) NSMutableArray *itemImages;
@property(nonatomic, assign) BOOL showAllSongs;

@end

@implementation MPMediaDataSource

static UIImage *kDefaultArtwork;

#pragma mark - Initializers/Dealloc

+ (void)initialize
{
    kDefaultArtwork = [UIImage imageNamed:@"DefaultNoArtwork.png"];
}

- (id)initArtistDataSource
{
    MPMediaDataSource *ds = [self initWithQuery:[MPMediaQuery artistsQuery] itemProperty:MPMediaItemPropertyArtist];
    ds.tabImage = [UIImage imageNamed:@"Artists.png"];
    ds.title = @"Artists";
    return ds;
}

- (id)initAlbumDataSource
{
    MPMediaDataSource *ds = [self initWithQuery:[MPMediaQuery albumsQuery] itemProperty:MPMediaItemPropertyAlbumTitle];
    ds.tabImage = [UIImage imageNamed:@"Albums"];
    ds.title = @"Albums";
    return ds;
}

- (id)initSongDataSource
{
    MPMediaDataSource *ds = [self initWithQuery:[MPMediaQuery songsQuery] itemProperty:MPMediaItemPropertyTitle];
    ds.tabImage = [UIImage imageNamed:@"Songs.png"];
    ds.title = @"Songs";
    return ds;
}

- (id)initPlaylistDataSource
{
    MPMediaDataSource *ds = [self initWithQuery:[MPMediaQuery playlistsQuery] itemProperty:MPMediaPlaylistPropertyName];
    ds.tabImage = [UIImage imageNamed:@"Albums"];
    ds.title = @"Playlists";
    return ds;
}

- (id)initWithQuery:(MPMediaQuery *)query itemProperty:(NSString *)itemProperty
{
    if (self = [super init])
    {
        _itemProperty = itemProperty;
        _query = query;
        _showAllSongs = NO;
        [self registerForLibraryChangeNotifications];
        
    }
    return self;
}

- (void)dealloc
{
    [self unregisterForLibraryChangeNotifications];
}

#pragma mark - ItemPickerDataSource Protocol conformance

- (NSUInteger)count
{
    return [self.query.collections count];
}

- (ItemPickerHeader *)header
{
    if ([self songList] && [self.query.filterPredicates count] > 1 && !self.showAllSongs)
    {
        int numSongs = self.count;
        ItemPickerHeader *header = [[ItemPickerHeader alloc] init];
        header.defaultNilLabels = NO;
        MPMediaItemCollection *collection  = [self.query.collections objectAtIndex:0];
        MPMediaItem *item = [collection representativeItem];
        header.image = [self getMediaItemAlbumImage:item];
        header.boldLabel = [item valueForProperty:MPMediaItemPropertyArtist];
        header.label = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        header.smallerLabel = [NSString stringWithFormat:@"%i %@%@", numSongs, @"Song", numSongs > 1 ? @"s" : @""];
        return header;
    }
    return nil;
}

- (void)initForRange:(NSRange)range
{
    _items = [[NSMutableArray alloc] initWithCapacity:range.length];
    _itemDescriptions = [[NSMutableArray alloc] initWithCapacity:range.length];
    _itemImages = [[NSMutableArray alloc] initWithCapacity:range.length];
    
    BOOL collectionQuery = [self playlistList];
    
    for (int i = range.location; i < range.location + range.length; i++)
    {
        MPMediaItemCollection *collection  = [self.query.collections objectAtIndex:i];
        if (collectionQuery)
        {
            NSString *itemValue = [collection valueForProperty:_itemProperty];
            [_items addObject:itemValue];
        }
        else
        {
            MPMediaItem *item = [collection representativeItem];
            NSString *itemValue = [item valueForProperty:_itemProperty];
            [_items addObject:itemValue];
            
            NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
            NSString *album = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
            
            if ([self albumList]) 
            {
                [_itemImages addObject:[self getMediaItemAlbumImage:item]];
                
                [_itemDescriptions addObject:artist];
            }
            else if ([self songList] && ([self.query.filterPredicates count] == 1 || self.showAllSongs))
            {
                artist = artist ? artist : @"";
                album = album ? album : @"";
                if ([artist length] == 0 || [album length] == 0)
                {
                    [_itemDescriptions addObject:[artist length] > 0 ? artist : [album length] > 0 ? album : @""];
                }
                else
                {
                    [_itemDescriptions addObject:[NSString stringWithFormat:@"%@ - %@", artist, album]];
                }
            }
        }
    }
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return self.items;
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    return [self.itemImages count] > 0 ? self.itemImages : nil;
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    return [self.itemDescriptions count] > 0 ? self.itemDescriptions : nil;
}

- (BOOL)isLeaf
{
    return [self songList] || [self playlistList];
}

- (BOOL)sectionsEnabled
{
    return [self.query.collections count] > 50;
}

- (NSArray *)sections
{
    return self.query.collectionSections;
}

- (BOOL)autoSelectSingleItem
{
    return [self albumList];
}

- (NSString *)metaCellTitle
{
    return [self albumList] && [self.query.filterPredicates count] > 1 ? @"All Songs" : nil;
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)selection
                                       previousSelections:(NSArray *)previousSelections
{
    MPMediaQuery *nextQuery = nil;
    NSString *nextItemProperty = nil;
    if ([self artistList])
    {
        nextQuery = [MPMediaQuery albumsQuery];
        [self addFilterPredicates:[NSArray arrayWithObjects:MPMediaItemPropertyAlbumArtist, MPMediaItemPropertyArtist, nil] 
                          toQuery:nextQuery basedOnSelection:selection];
        nextItemProperty = MPMediaItemPropertyAlbumTitle;
    }
    else if ([self albumList])
    {
        nextQuery = [MPMediaQuery songsQuery];
        if (!selection.metaCell)
        {
            [self addFilterPredicates:[NSArray arrayWithObject:MPMediaItemPropertyAlbumTitle] 
                              toQuery:nextQuery basedOnSelection:selection];
        }
        nextItemProperty = MPMediaItemPropertyTitle;
    }
    
    if (nextQuery)
    {        
        if ([previousSelections count] > 0)
        {
            // not a top level data source, carry over previous filters
            [self addFilterPredicatesFromQuery:self.query toQuery:nextQuery];
        }

        MPMediaDataSource *nextDataSource = [[[self class] alloc] initWithQuery:nextQuery itemProperty:nextItemProperty];
        nextDataSource.showAllSongs = selection.metaCell;
        return nextDataSource;
    }

    return nil;
}

# pragma mark - Private methods

- (void)addFilterPredicates:(NSArray *)itemProperties toQuery:(MPMediaQuery *)query basedOnSelection:(ItemPickerSelection *)selection
{
    MPMediaDataSource *dataSource = selection.dataSource;    
    MPMediaItemCollection *collection  = [dataSource.query.collections objectAtIndex:selection.selectedIndex];
    MPMediaItem *item = [collection representativeItem];
    for (NSString *property in itemProperties)
    {
        NSString *propertyValue = [item valueForProperty:property];
        if (propertyValue)
        {
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:propertyValue forProperty:property]];
        }
    }
}

- (void)addFilterPredicatesFromQuery:(MPMediaQuery *)fromQuery toQuery:(MPMediaQuery *)toQuery
{
    for (MPMediaPropertyPredicate *predicate in fromQuery.filterPredicates)
    {
        [toQuery addFilterPredicate:predicate];
    }
}

- (UIImage *)getMediaItemAlbumImage:(MPMediaItem *)item
{
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    CGSize size = artwork.bounds.size;
    UIImage *image = [artwork imageWithSize:CGSizeMake(size.height, size.width)];
    return image ? image : kDefaultArtwork;
}

- (BOOL)artistList
{
    return self.query.groupingType == MPMediaGroupingArtist;
}

- (BOOL)albumList
{
    return self.query.groupingType == MPMediaGroupingAlbum;
}

- (BOOL)songList 
{
    return self.query.groupingType == MPMediaGroupingTitle;
}

- (BOOL)playlistList
{
    return self.query.groupingType == MPMediaGroupingPlaylist;
}

- (void)onLibraryChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ItemPickerDataSourceDidChangeNotification object:nil];
}

- (void)registerForLibraryChangeNotifications
{
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(onLibraryChanged) name:MPMediaLibraryDidChangeNotification object:nil];
}

- (void)unregisterForLibraryChangeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
}

@end
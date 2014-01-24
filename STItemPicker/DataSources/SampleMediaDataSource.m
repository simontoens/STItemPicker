// @author Simon Toens 03/16/13

#import "ItemAttributes.h"
#import "ItemPickerSelection.h"
#import "MultiDictionary.h"
#import "SampleMediaDataSource.h"

@interface SampleMediaDataSource()
@property(nonatomic, strong, readwrite) UIImage *headerImage;
@property(nonatomic, strong, readwrite) NSMutableArray *itemDescriptions;
@property(nonatomic, strong, readwrite) NSMutableArray *itemImages;
@property(nonatomic, strong, readwrite) NSMutableArray *itemAttributes;
@property(nonatomic, assign, readwrite) BOOL sectionsEnabled;
@property(nonatomic, strong, readwrite) UIImage *tabImage;
@property(nonatomic, strong, readwrite) NSString *title;

@property(nonatomic, assign, readonly) NSUInteger depth;
@property(nonatomic, strong, readonly) NSArray *items;
@property(nonatomic, strong, readonly) ItemPickerSelection *selection;

@end

@implementation SampleMediaDataSource

static NSString *const kArtists = @"Artists";
static NSString *const kAlbums = @"Albums";
static NSString *const kSongs = @"Songs";

static MultiDictionary *kArtistsToAllSongs;

static MultiDictionary *kArtistToAlbums;
static NSMutableDictionary *kAlbumToArtist;

static MultiDictionary *kAlbumToSongs;
static NSMutableDictionary *kSongToAlbum;

static NSMutableDictionary *kAlbumToArtwork;
static UIImage *kDefaultArtwork;

static NSArray *kAllDictionaries;
static NSArray *kAllTitles;


+ (id)artistsDataSource
{
    SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:0 items:[kArtistToAlbums allKeys] selection:nil];
    ds.sectionsEnabled = YES;
    ds.tabImage = [UIImage imageNamed:@"Artists.png"];
    return ds;
}

+ (id)albumsDataSource
{
    SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:1 items:[kAlbumToSongs allKeys] selection:nil];
    ds.sectionsEnabled = YES;
    ds.tabImage = [UIImage imageNamed:@"Albums.png"];
    return ds;
}

+ (id)songsDataSource
{
    SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:2 items:[kAlbumToSongs allValues] selection:nil];
    ds.sectionsEnabled = YES;
    ds.tabImage = [UIImage imageNamed:@"Songs.png"];
    return ds;
}

- (id)initWithDepth:(NSUInteger)depth items:(NSArray *)items selection:(ItemPickerSelection *)selection
{
    if (self = [super init])
    {
        _depth = depth;
        _items = items;
        _sectionsEnabled = NO;
        _selection = selection;
        _title = [kAllTitles objectAtIndex:depth];        
        [self initSecondayLists];
    }
    return self;
}

# pragma mark - ItemPickerDataSource methods

- (NSUInteger)count
{
    return [self.items count];
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)itemPickerSelection 
                                       previousSelections:(NSArray *)previousSelections
{
    if (itemPickerSelection.metaCell)
    {
        NSArray *nextItems = nil;
        BOOL sectionsEnabled = NO;
        if ([previousSelections count] == 0)
        {
            nextItems = [kArtistsToAllSongs allValues];
            sectionsEnabled = YES;
        }
        else
        {
            ItemPickerSelection *previousSelection = [previousSelections lastObject];
            nextItems = [[[kArtistsToAllSongs objectsForKey:previousSelection.selectedItem] allObjects] 
                         sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        }
        SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:[kAllDictionaries count] items:nextItems selection:nil];
        ds.sectionsEnabled = sectionsEnabled;
        return ds;
    }
    else if (self.depth <= [kAllDictionaries count] - 1)
    {
        MultiDictionary *currentDict = [kAllDictionaries objectAtIndex:self.depth];
        NSArray *nextItems = [[currentDict objectsForKey:itemPickerSelection.selectedItem] allObjects];
        SampleMediaDataSource *nextDataSource = [[SampleMediaDataSource alloc] initWithDepth:self.depth+1 
                                                                                       items:nextItems 
                                                                                   selection:itemPickerSelection];
        if ([self albumsList])
        {
            UIImage *albumArtwork = [kAlbumToArtwork objectForKey:itemPickerSelection.selectedItem];
            nextDataSource.headerImage = albumArtwork ? albumArtwork : kDefaultArtwork;
            nextDataSource.title = kSongs;
        }
        return nextDataSource;
    }
    return nil;
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self.items subarrayWithRange:range];
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    return self.itemImages ? [self.itemImages subarrayWithRange:range] : nil;
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    return self.itemDescriptions ? [self.itemDescriptions subarrayWithRange:range] : nil;
}

- (NSArray *)getItemAttributesInRange:(NSRange)range
{
    return self.itemAttributes ? [self.itemAttributes subarrayWithRange:range] : nil;
}

- (BOOL)autoSelectSingleItem
{
    return [self albumsList];
}

- (ItemPickerHeader *)header
{
    if (self.headerImage)
    {
        ItemPickerHeader *header = [[ItemPickerHeader alloc] init];
        header.image = self.headerImage;
        header.smallestLabel = @"Copyright 1987 Sony Music Lausanne";
        header.defaultNilLabels = YES;
        return header;
    }
    return nil;
}

- (BOOL)isLeaf
{
    return [self songsList];
}

# pragma mark - Private methods

- (BOOL)artistsList 
{
    return [self.title isEqualToString:kArtists];
}

- (BOOL)albumsList 
{
    return [self.title isEqualToString:kAlbums];
}

- (BOOL)songsList 
{
    return [self.title isEqualToString:kSongs];
}

- (NSString *)metaCellTitle
{
    return [self albumsList] ? @"All Songs" : nil;
}

- (NSString *)noItemsItemText
{
    return @"No songs found";
}

- (void)initSecondayLists
{
    [self initImages];
    [self initDescriptions];
    [self initAttributes];
}

- (void)initImages
{
    if ([self albumsList])
    {    
        NSArray *albums = [self getItemsInRange:NSMakeRange(0, self.count)];
        self.itemImages = [[NSMutableArray alloc] initWithCapacity:[albums count]];
        for (NSString *album in albums) 
        {
            UIImage *image = [kAlbumToArtwork objectForKey:album];
            [self.itemImages addObject:image == nil ? kDefaultArtwork : image];
        }
    }
}

- (void)initDescriptions
{
    if (([self albumsList] || [self songsList]) && !self.selection)
    {
        NSArray *items = [self getItemsInRange:NSMakeRange(0, self.count)];
        self.itemDescriptions = [[NSMutableArray alloc] initWithCapacity:[items count]];
        for (NSString *item in items) 
        {
            if ([self albumsList])
            {
                [self.itemDescriptions addObject:[kAlbumToArtist objectForKey:item]];
            }
            else
            {
                NSString *album = [kSongToAlbum objectForKey:item];
                NSString *artist = [kAlbumToArtist objectForKey:album];
                [self.itemDescriptions addObject:[NSString stringWithFormat:@"%@ - %@", artist, album]];
            }
        }
    }
}

- (void)initAttributes
{
    if ([self songsList] && [self.items count] > 15)
    {
        self.itemAttributes = [[NSMutableArray alloc] initWithCapacity:self.count];
        for (int i = 0; i < self.count - 1; i++)
        {
            [self.itemAttributes addObject:[NSNull null]];
        }
        ItemAttributes *attr = [[ItemAttributes alloc] init];
        attr.textColor = [UIColor blueColor];
        attr.descriptionTextColor = [UIColor redColor];
        attr.userInteractionEnabled = NO;
        [self.itemAttributes addObject:attr];
    }
}

+ (void)addArtist:(NSString *)artist album:(NSString *)album songs:(NSArray *)songs 
{
    [self addArtist:artist album:album imageName:nil songs:songs];
}

+ (void)addArtist:(NSString *)artist album:(NSString *)album imageName:(NSString *)imageName songs:(NSArray *)songs
{
    [kArtistToAlbums setObject:album forKey:artist];
    [kAlbumToArtist setObject:artist forKey:album];
    for (NSString *song in songs) {
        [kAlbumToSongs setObject:song forKey:album];
        [kSongToAlbum setObject:album forKey:song];
        [kArtistsToAllSongs setObject:song forKey:artist];
    }
    if (imageName) 
    {
        UIImage *image = [UIImage imageNamed:imageName];
        [kAlbumToArtwork setObject:image forKey:album];
    }
}

+ (void)initialize 
{
    kArtistsToAllSongs = [[MultiDictionary alloc] init];
    kArtistToAlbums = [[MultiDictionary alloc] init];
    kAlbumToArtist = [[NSMutableDictionary alloc] init];
    kAlbumToSongs = [[MultiDictionary alloc] init];
    kSongToAlbum = [[NSMutableDictionary alloc] init];
    kAlbumToArtwork = [[NSMutableDictionary alloc] init];
    kDefaultArtwork = [UIImage imageNamed:@"DefaultNoArtwork.png"];
    
    kAllDictionaries = [NSArray arrayWithObjects:kArtistToAlbums, kAlbumToSongs, nil];
    kAllTitles = [NSArray arrayWithObjects:kArtists, kAlbums, kSongs, nil];
    
    [SampleMediaDataSource addArtist:@"Band Without Songs" album:@"Album Without Songs" 
                               songs:[NSArray array]];
    
    [SampleMediaDataSource addArtist:@"M83" album:@"Hurry Up, We're Dreaming" 
                               songs:[NSArray arrayWithObject:@"Midnight City"]];
    
    [SampleMediaDataSource addArtist:@"Gene" album:@"Drawn To The Deep End" 
                               songs:[NSArray arrayWithObject:@"Fighting Fit"]];
    
    [SampleMediaDataSource addArtist:@"Doves" album:@"The Last Broadcast" imageName:@"TheLastBroadcast.jpg"
                               songs:[NSArray arrayWithObject:@"Words"]];
    
    [SampleMediaDataSource addArtist:@"Kent" album:@"Isola" 
                               songs:[NSArray arrayWithObjects:@"747", @"Things She Said", nil]];
    
    [SampleMediaDataSource addArtist:@"Happy Mondays" album:@"Pills 'N' Thrills And Belly Aches" 
                               songs:[NSArray arrayWithObject:@"Kinky Afro"]];
    
    [SampleMediaDataSource addArtist:@"Air" album:@"Moon Safari" imageName:@"MoonSafari.jpg"
                               songs:[NSArray arrayWithObjects:@"La Femme d'Argent", @"Sexy Boy", @"All I Need", @"Kelly Watch The Stars", @"Talisman", @"Remember", @"You Make It Easy", @"Ce Matin-La", @"New Star In The Sky", @"Le Voyage De Penelope", nil]];
    
    [SampleMediaDataSource addArtist:@"Air" album:@"Talkie Walkie" imageName:@"TalkieWalkie.jpg"
                               songs:[NSArray arrayWithObjects:@"Venus", @"Cherry Blossom Girl", @"Run", @"Universal Traveler", @"Mike Millis", @"Surfing On A Rocket", @"Another Day", @"Alpha Beta Gaga", @"Biological", @"Alone In Kyoto", nil]];
    
    [SampleMediaDataSource addArtist:@"Badly Drawn Boy" album:@"The Hour of Bewilderbeast" 
                               songs:[NSArray arrayWithObjects:@"The Shining", @"Disillusion", nil]];
    
    [SampleMediaDataSource addArtist:@"Chemical Borthers" album:@"Push The Button" 
                               songs:[NSArray arrayWithObjects:@"Come Inside", @"The Big Jump", nil]];
    
    [SampleMediaDataSource addArtist:@"Queen" album:@"Innuendo" imageName:@"Innuendo.jpg"
                               songs:[NSArray arrayWithObjects:@"I'm Going Slightly Mad", @"The Show Must Go On", nil]];
    
    [SampleMediaDataSource addArtist:@"Blur" album:@"Parklife" imageName:@"Parklife.jpg"
                               songs:[NSArray arrayWithObjects:@"Girls and Boys", @"Tracy Jacks", @"This is a Low", nil]];
    
    [SampleMediaDataSource addArtist:@"Blur" album:@"Modern Life Is Rubbish" imageName:@"ModernLife.jpg"
                               songs:[NSArray arrayWithObjects:@"For Tomorrow", @"Chemical World", @"Blue Jeans", nil]];
    
    [SampleMediaDataSource addArtist:@"Wilco" album:@"A Ghost is Born" 
                               songs:[NSArray arrayWithObjects:@"Handshake Drugs", @"The Late Greats", nil]];
    
    [SampleMediaDataSource addArtist:@"Wilco" album:@"Summer Teeth" 
                               songs:[NSArray arrayWithObjects:@"A Shot in the Arm", @"Candy Floss", nil]];
    
    [SampleMediaDataSource addArtist:@"Oscar's Band" album:@"That's Stupid" 
                               songs:[NSArray arrayWithObject:@"### stupid!"]];
    
    [SampleMediaDataSource addArtist:@"Daft Punk" album:@"Homework" 
                               songs:[NSArray arrayWithObjects:@"Revolution 909", @"Around The World", nil]];
    
    [SampleMediaDataSource addArtist:@"Lets Start A Band With A Really Long Name" 
                               album:@"Lets Make An Abum With A Really Long Name" 
                               songs:[NSArray arrayWithObject:@"Lets Write A Song With A Really Long Name"]];

    static int numSongs = 1000;
    NSMutableArray *manySongs = [[NSMutableArray alloc] initWithCapacity:numSongs];
    for (int i = 0; i < numSongs; i++) {
        [manySongs addObject:[NSString stringWithFormat:@"Song-%i", i]];
    }
    
    [SampleMediaDataSource addArtist:@"Many Songs Band"
                               album:@"Many Songs Album"
                               songs:manySongs];
}

@end
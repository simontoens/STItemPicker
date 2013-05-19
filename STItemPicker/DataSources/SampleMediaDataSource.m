// @author Simon Toens 03/16/13

#import "MultiDictionary.h"
#import "SampleMediaDataSource.h"

@interface SampleMediaDataSource() 
- (id)initWithDepth:(NSUInteger)depth items:(NSArray *)items;

- (BOOL)artistsList;
- (BOOL)albumsList;
- (BOOL)songsList;
+ (void)addArtist:(NSString *)artist album:(NSString *)album imageName:(NSString *)imageName songs:(NSArray *)songs;


@property (nonatomic, strong, readwrite) UIImage *headerImage;
@property (nonatomic, strong, readwrite) NSArray *itemImages;
@property (nonatomic, assign, readwrite) BOOL sectionsEnabled;
@property (nonatomic, strong, readwrite) UIImage *tabImage;
@property (nonatomic, strong, readwrite) NSString *title;

@property (nonatomic, assign) NSUInteger depth;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) SampleMediaDataSource *parentDataSource;

@end

@implementation SampleMediaDataSource

static NSString *const kArtists = @"Artists";
static NSString *const kAlbums = @"Albums";
static NSString *const kSongs = @"Songs";

static MultiDictionary* kArtistsToAlbums;
static MultiDictionary* kAlbumsToSongs;
static NSMutableDictionary *kAlbumToArtwork;
static UIImage *kDefaultArtwork;

static NSArray *kAllDictionaries;

@synthesize depth = _depth;
@synthesize headerImage;
@synthesize itemImages;
@synthesize items = _items;
@synthesize parentDataSource;
@synthesize sectionsEnabled = _sectionsEnabled;
@synthesize tabImage;
@synthesize title;

+ (id)artistsDataSource
{
    SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:0 items:[kArtistsToAlbums allKeys]];
    ds.sectionsEnabled = YES;
    ds.tabImage = [UIImage imageNamed:@"Artists.png"];
    ds.title = kArtists;
    return ds;
}

+ (id)albumsDataSource
{
    SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:1 items:[kAlbumsToSongs allKeys]];
    ds.sectionsEnabled = YES;
    ds.tabImage = [UIImage imageNamed:@"Albums.png"];
    ds.title = kAlbums;
    return ds;
}

+ (id)songsDataSource
{
    SampleMediaDataSource *ds = [[SampleMediaDataSource alloc] initWithDepth:2 items:[kAlbumsToSongs allValues]];
    ds.sectionsEnabled = YES;
    ds.tabImage = [UIImage imageNamed:@"Songs.png"];
    ds.title = kSongs;
    return ds;
}

- (id)initWithDepth:(NSUInteger)depth items:(NSArray *)items
{
    if (self = [super init])
    {
        _depth = depth;
        _items = items;
        _sectionsEnabled = NO;
    }
    return self;
}

# pragma mark - ItemPickerDataSource methods

- (NSUInteger)count
{
    return [self.items count];
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self.items subarrayWithRange:range];
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context
{
    if (self.depth <= [kAllDictionaries count] - 1)
    {
        MultiDictionary *currentDict = [kAllDictionaries objectAtIndex:self.depth];
        NSArray *nextItems = [[currentDict objectsForKey:context.selectedItem] allObjects];
        SampleMediaDataSource *nextDataSource = [[SampleMediaDataSource alloc] initWithDepth:self.depth+1 items:nextItems];
        if ([self albumsList])
        {
            UIImage *albumArtwork = [kAlbumToArtwork objectForKey:context.selectedItem];
            nextDataSource.headerImage = albumArtwork ? albumArtwork : kDefaultArtwork;
            nextDataSource.title = kSongs;
        }
        nextDataSource.parentDataSource = context.dataSource;
        return nextDataSource;
    }
    return nil;
}

- (BOOL)itemImagesEnabled
{
    return [self albumsList];
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    NSArray *albums = [self getItemsInRange:range];
    NSMutableArray *albumImages = [[NSMutableArray alloc] initWithCapacity:[albums count]];
    for (NSString *album in albums) 
    {
        UIImage *image = [kAlbumToArtwork objectForKey:album];
        if (image == nil)
        {
            [albumImages addObject:kDefaultArtwork];
        } 
        else 
        {
            [albumImages addObject:image];
        }
    }
    return albumImages;
}

- (BOOL)autoSelectSingleItem
{
    return [self albumsList];
}

# pragma mark - Private methods

- (BOOL)artistsList 
{
    return [self.title isEqualToString:kArtists];
}

- (BOOL)albumsList 
{
    return [self.title isEqualToString:kAlbums] || [self.parentDataSource.title isEqualToString:kArtists];
}

- (BOOL)songsList 
{
    return [self.title isEqualToString:kSongs];
}

+ (void)addArtist:(NSString *)artist album:(NSString *)album songs:(NSArray *)songs 
{
    [self addArtist:artist album:album imageName:nil songs:songs];
}

+ (void)addArtist:(NSString *)artist album:(NSString *)album imageName:(NSString *)imageName songs:(NSArray *)songs
{
    [kArtistsToAlbums setObject:album forKey:artist];
    for (NSString *song in songs) {
        [kAlbumsToSongs setObject:song forKey:album];
    }
    if (imageName) 
    {
        UIImage *image = [UIImage imageNamed:imageName];
        [kAlbumToArtwork setObject:image forKey:album];
    }
}

+ (void)initialize 
{
    kArtistsToAlbums = [[MultiDictionary alloc] init];
    kAlbumsToSongs = [[MultiDictionary alloc] init];
    kAlbumToArtwork = [[NSMutableDictionary alloc] init];
    kDefaultArtwork = [UIImage imageNamed:@"DefaultNoArtwork.png"];
    
    kAllDictionaries = [NSArray arrayWithObjects:kArtistsToAlbums, kAlbumsToSongs, nil];
    
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
                               songs:[NSArray arrayWithObject:@"Come Inside"]];
    
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
}

@end
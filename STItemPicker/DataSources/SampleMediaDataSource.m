// @author Simon Toens 03/16/13

#import "MultiDictionary.h"
#import "SampleMediaDataSource.h"

@interface SampleMediaDataSource() 
{
    @private
    NSString * selection;
}
- (id)initWithTitle:(NSString *)header;
- (BOOL)artistsList;
- (BOOL)albumsList;
- (BOOL)songsList;
+ (void)addArtist:(NSString *)artist album:(NSString *)album imageName:(NSString *)imageName songs:(NSArray *)songs;

@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation SampleMediaDataSource

static NSString *const kArtists = @"Artists";
static NSString *const kAlbums = @"Albums";
static NSString *const kSongs = @"Songs";

static MultiDictionary* kArtistsToAlbums;
static MultiDictionary* kAlbumsToSongs;
static NSMutableDictionary *kAlbumToArtwork;
static UIImage *kDefaultArtwork;

@synthesize title = _title;

+ (id)artistsDataSource
{
    return [[SampleMediaDataSource alloc] initWithTitle:kArtists];
}

+ (id)albumsDataSource
{
    return [[SampleMediaDataSource alloc] initWithTitle:kAlbums];
}

+ (id)songsDataSource
{
    return [[SampleMediaDataSource alloc] initWithTitle:kSongs];
}

- (id)initWithTitle:(NSString *)title
{
    if (self = [super init]) 
    {
        _title = title;
    }
    return self;
}

- (id)initWithParentSelection:(NSString *)aSelection 
{
    if (self = [super init]) 
    {
        selection = aSelection;
    }
    return self;
}

# pragma mark - ItemPickerDataSource methods

- (UIImage *)headerImage
{
    if ([self songsList] && selection) 
    {
        UIImage *image = [kAlbumToArtwork objectForKey:selection];
        return image ? image : kDefaultArtwork;
    }
    return nil;
}

- (UIImage *)tabImage
{
    if ([self artistsList]) 
    {
        return [UIImage imageNamed:@"Artists.png"];
    }
    else if ([self albumsList]) 
    {
        return [UIImage imageNamed:@"Albums.png"];        
    } 
    else
    {
        return [UIImage imageNamed:@"Songs.png"];                
    }
}

- (BOOL)sectionsEnabled 
{
    return !selection;
}

- (NSArray *)items 
{
    if ([self artistsList]) 
    {
        return [kArtistsToAlbums allKeys];
    } 
    else if ([self albumsList]) 
    {
        return selection ? [[kArtistsToAlbums objectsForKey:selection] allObjects] : [kAlbumsToSongs allKeys];
    } 
    else if ([self songsList]) 
    {
        return selection ? [[kAlbumsToSongs objectsForKey:selection] allObjects] : [kAlbumsToSongs allValues];
    } 
    else 
    {
        NSAssert(NO, @"bad value for header");
        return nil;
    }
}

- (NSArray *)itemImages
{
    if ([self albumsList]) 
    {
        NSArray *albums = self.items;
        NSMutableArray *albumImages = [[NSMutableArray alloc] initWithCapacity:[albums count]];
        for (NSString *album in albums) 
        {
            UIImage *image = [kAlbumToArtwork objectForKey:album];
            if (image == nil)
            {
                [albumImages addObject:[NSNull null]];
            } 
            else 
            {
                [albumImages addObject:image];
            }
            
        }
        return albumImages;
    }
    return nil;
}


- (BOOL)itemsAlreadySorted 
{
    return NO;
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item
{
    NSString *title = nil;
    if ([self artistsList]) 
    {
        title = kAlbums;
    } else if ([self albumsList]) 
    {
        title = kSongs;
    } 
    if (title) 
    {
        SampleMediaDataSource *s = [[SampleMediaDataSource alloc] initWithParentSelection:item];
        s.title = title;
        return s;
    } 
    else 
    {
        return nil;
    }
}

- (BOOL)skipIntermediaryLists
{
    return YES;
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
    
    [SampleMediaDataSource addArtist:@"M83" album:@"Hurry Up, We're Dreaming" 
                               songs:[NSArray arrayWithObjects:@"Midnight City", nil]];
    
    [SampleMediaDataSource addArtist:@"Gene" album:@"Drawn To The Deep End" 
                               songs:[NSArray arrayWithObjects:@"Fighting Fit", nil]];
    
    [SampleMediaDataSource addArtist:@"Doves" album:@"The Last Broadcast" imageName:@"TheLastBroadcast.jpg"
                               songs:[NSArray arrayWithObjects:@"Words", nil]];
    
    [SampleMediaDataSource addArtist:@"Kent" album:@"Isola" 
                               songs:[NSArray arrayWithObjects:@"747", @"Things She Said", nil]];
    
    [SampleMediaDataSource addArtist:@"Happy Mondays" album:@"Pills 'N' Thrills And Belly Aches" 
                               songs:[NSArray arrayWithObjects:@"Kinky Afro", nil]];
    
    [SampleMediaDataSource addArtist:@"Air" album:@"Moon Safari" imageName:@"MoonSafari.jpg"
                               songs:[NSArray arrayWithObjects:@"La Femme d'Argent", @"Sexy Boy", @"All I Need", @"Kelly Watch The Stars", @"Talisman", @"Remember", @"You Make It Easy", @"Ce Matin-La", @"New Star In The Sky", @"Le Voyage De Penelope", nil]];
    
    [SampleMediaDataSource addArtist:@"Air" album:@"Talkie Walkie" imageName:@"TalkieWalkie.jpg"
                               songs:[NSArray arrayWithObjects:@"Venus", @"Cherry Blossom Girl", @"Run", @"Universal Traveler", @"Mike Millis", @"Surfing On A Rocket", @"Another Day", @"Alpha Beta Gaga", @"Biological", @"Alone In Kyoto", nil]];
    
    [SampleMediaDataSource addArtist:@"Badly Drawn Boy" album:@"The Hour of Bewilderbeast" 
                               songs:[NSArray arrayWithObjects:@"Come Inside", nil]];
    
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
                               songs:[NSArray arrayWithObjects:@"### stupid!", nil]];
    
    [SampleMediaDataSource addArtist:@"Daft Punk" album:@"Homework" 
                               songs:[NSArray arrayWithObjects:@"Revolution 909", @"Around The World", nil]];
}

@end
// @author Simon Toens 03/16/13

#import "SampleDataSource.h"
#import "MultiDictionary.h"

@interface SampleDataSource() 
{
    @private
    NSString * selection;
}
- (id)initWithHeader:(NSString *)header;

@property (nonatomic, strong, readwrite) NSString *header;

@end

@implementation SampleDataSource

static NSString *const kArtists = @"Artists";
static NSString *const kAlbums = @"Albums";
static NSString *const kSongs = @"Songs";

static MultiDictionary* kArtistsToAlbums;
static MultiDictionary* kAlbumsToSongs;

@synthesize header = _header;

+ (id)artistsDataSource
{
    return [[SampleDataSource alloc] initWithHeader:kArtists];
}

+ (id)albumsDataSource
{
    return [[SampleDataSource alloc] initWithHeader:kAlbums];
}

+ (id)songsDataSource
{
    return [[SampleDataSource alloc] initWithHeader:kSongs];
}

- (id)initWithHeader:(NSString *)header
{
    if (self = [super init]) 
    {
        _header = header;
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

- (BOOL)artistsList 
{
    return [self.header isEqualToString:kArtists];
}

- (BOOL)albumsList 
{
    return [self.header isEqualToString:kAlbums];
}

- (BOOL)songsList 
{
    return [self.header isEqualToString:kSongs];
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

- (BOOL)itemsAlreadySorted 
{
    return NO;
}

- (id<ItemPickerDataSource>)getNextDataSource:(NSString *)aSelection 
{
    NSString *header = nil;
    if ([self artistsList]) 
    {
        header = kAlbums;
    } else if ([self albumsList]) 
    {
        header = kSongs;
    } 
    if (header) 
    {
        SampleDataSource *s = [[SampleDataSource alloc] initWithParentSelection:aSelection];
        s.header = header;
        return s;
    } 
    else 
    {
        return nil;
    }
}

+ (void)addArtist:(NSString *)artist album:(NSString *)album songs:(NSArray *)songs 
{
    [kArtistsToAlbums setObject:album forKey:artist];
    for (NSString *song in songs) {
        [kAlbumsToSongs setObject:song forKey:album];
    }
}

+ (void)initialize 
{
    kArtistsToAlbums = [[MultiDictionary alloc] init];
    kAlbumsToSongs = [[MultiDictionary alloc] init];
    
    [SampleDataSource addArtist:@"M83" album:@"Hurry Up, We're Dreaming" 
                                    songs:[NSArray arrayWithObjects:@"Midnight City", nil]];
    
    [SampleDataSource addArtist:@"Gene" album:@"Drawn To The Deep End" 
                                    songs:[NSArray arrayWithObjects:@"Fighting Fit", nil]];
    
    [SampleDataSource addArtist:@"Doves" album:@"The Last Broadcast" 
                                    songs:[NSArray arrayWithObjects:@"Words", nil]];
    
    [SampleDataSource addArtist:@"Kent" album:@"Isola" 
                                    songs:[NSArray arrayWithObjects:@"747", @"Things She Said", nil]];
    
    [SampleDataSource addArtist:@"Happy Mondays" album:@"Pills 'N' Thrills And Belly Aches" 
                                    songs:[NSArray arrayWithObjects:@"Kinky Afro", nil]];
    
    [SampleDataSource addArtist:@"Air" album:@"Moon Safari" 
                                    songs:[NSArray arrayWithObjects:@"La Femme d'Argent", nil]];
    
    [SampleDataSource addArtist:@"Badly Drawn Boy" album:@"The Hour of Bewilderbeast" 
                                    songs:[NSArray arrayWithObjects:@"Come Inside", nil]];
    
    [SampleDataSource addArtist:@"The Chemical Borthers" album:@"Push The Button" 
                                    songs:[NSArray arrayWithObjects:@"Come Inside", @"The Big Jump", nil]];
    
    [SampleDataSource addArtist:@"Queen" album:@"Innuendo" 
                                    songs:[NSArray arrayWithObjects:@"I'm Going Slightly Mad", @"The Show Must Go On", nil]];
    
    [SampleDataSource addArtist:@"Blur" album:@"Parklife" 
                                    songs:[NSArray arrayWithObjects:@"Girls and Boys", @"Tracy Jacks", @"This is a Low", nil]];
    
    [SampleDataSource addArtist:@"Wilco" album:@"A Ghost is Born" 
                                    songs:[NSArray arrayWithObjects:@"Handshake Drugs", @"The Late Greats", nil]];
    
    [SampleDataSource addArtist:@"Wilco" album:@"Summer Teeth" 
                                    songs:[NSArray arrayWithObjects:@"A Shot in the Arm", @"Candy Floss", nil]];
    
    [SampleDataSource addArtist:@"Oscar's Band" album:@"That's Stupid" 
                                    songs:[NSArray arrayWithObjects:@"### stupid!", nil]];
}

@end
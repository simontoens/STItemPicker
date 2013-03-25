// @author Simon Toens 03/16/13

#import "SampleItemPickerDataSource.h"
#import "MultiDictionary.h"

@interface SampleItemPickerDataSource() 
{
    @private
    NSString * selection;
}
@property (nonatomic, strong, readwrite) NSString *header;
@end

@implementation SampleItemPickerDataSource

static NSString *kArtists = @"Artists";
static NSString *kAlbums = @"Albums";
static NSString *kSongs = @"Songs";

static MultiDictionary* kArtistsToAlbums;
static MultiDictionary* kAlbumsToSongs;

@synthesize header = _header;

- (id)init 
{
    if (self = [super init]) {
        _header = kArtists;
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

- (BOOL)hasDetailDataSource 
{
    return ![self songsList];
}

- (BOOL)sectionsEnabled 
{
    return [self artistsList];
}

- (NSArray *)items 
{
    if ([self artistsList]) 
    {
        return [kArtistsToAlbums allKeys];
    } 
    else if ([self albumsList]) 
    {
        return [[kArtistsToAlbums objectsForKey:selection] allObjects];
    } 
    else if ([self songsList]) 
    {
        return [[kAlbumsToSongs objectsForKey:selection] allObjects];
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
        SampleItemPickerDataSource *s = [[SampleItemPickerDataSource alloc] initWithParentSelection:aSelection];
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
    
    [SampleItemPickerDataSource addArtist:@"M83" album:@"Hurry Up, We're Dreaming" 
                                    songs:[NSArray arrayWithObjects:@"Midnight City", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Gene" album:@"Drawn To The Deep End" 
                                    songs:[NSArray arrayWithObjects:@"Fighting Fit", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Doves" album:@"The Last Broadcast" 
                                    songs:[NSArray arrayWithObjects:@"Words", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Kent" album:@"Isola" 
                                    songs:[NSArray arrayWithObjects:@"747", @"Things She Said", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Happy Mondays" album:@"Pills 'N' Thrills And Belly Aches" 
                                    songs:[NSArray arrayWithObjects:@"Kinky Afro", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Air" album:@"Moon Safari" 
                                    songs:[NSArray arrayWithObjects:@"La Femme d'Argent", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Badly Drawn Boy" album:@"The Hour of Bewilderbeast" 
                                    songs:[NSArray arrayWithObjects:@"Come Inside", nil]];
    
    [SampleItemPickerDataSource addArtist:@"The Chemical Borthers" album:@"Push The Button" 
                                    songs:[NSArray arrayWithObjects:@"I'm Going Slightly Mad", @"The Show Must Go On", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Queen" album:@"Innuendo" 
                                    songs:[NSArray arrayWithObjects:@"I'm Going Slightly Mad", @"The Show Must Go On", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Blur" album:@"Parklife" 
                                    songs:[NSArray arrayWithObjects:@"Girls and Boys", @"Tracy Jacks", @"This is a Low", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Wilco" album:@"A Ghost is Born" 
                                    songs:[NSArray arrayWithObjects:@"Handshake Drugs", @"The Late Greats", nil]];
    
    [SampleItemPickerDataSource addArtist:@"Wilco" album:@"Summer Teeth" 
                                    songs:[NSArray arrayWithObjects:@"A Shot in the Arm", @"Candy Floss", nil]];
}

@end
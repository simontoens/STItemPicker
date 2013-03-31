// @author Simon Toens 03/16/13

#import "SampleDataSource.h"
#import "MultiDictionary.h"

@interface SampleDataSource() 
{
    @private
    NSString * selection;
}
- (id)initWithTitle:(NSString *)header;
- (BOOL)artistsList;
- (BOOL)albumsList;
- (BOOL)songsList;

@property (nonatomic, strong, readwrite) NSString *title;

@end

@implementation SampleDataSource

static NSString *const kArtists = @"Artists";
static NSString *const kAlbums = @"Albums";
static NSString *const kSongs = @"Songs";

static MultiDictionary* kArtistsToAlbums;
static MultiDictionary* kAlbumsToSongs;

@synthesize title = _title;

+ (id)artistsDataSource
{
    return [[SampleDataSource alloc] initWithTitle:kArtists];
}

+ (id)albumsDataSource
{
    return [[SampleDataSource alloc] initWithTitle:kAlbums];
}

+ (id)songsDataSource
{
    return [[SampleDataSource alloc] initWithTitle:kSongs];
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
    return [self songsList] && selection ? [UIImage imageNamed:@"ModernLife.jpg"] : nil;
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
        SampleDataSource *s = [[SampleDataSource alloc] initWithParentSelection:item];
        s.title = title;
        return s;
    } 
    else 
    {
        return nil;
    }
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
    
    [SampleDataSource addArtist:@"Blur" album:@"Modern Life Is Rubbish" 
                          songs:[NSArray arrayWithObjects:@"For Tomorrow", @"Chemical World", @"Blue Jeans", nil]];
    
    [SampleDataSource addArtist:@"Wilco" album:@"A Ghost is Born" 
                                    songs:[NSArray arrayWithObjects:@"Handshake Drugs", @"The Late Greats", nil]];
    
    [SampleDataSource addArtist:@"Wilco" album:@"Summer Teeth" 
                                    songs:[NSArray arrayWithObjects:@"A Shot in the Arm", @"Candy Floss", nil]];
    
    [SampleDataSource addArtist:@"Oscar's Band" album:@"That's Stupid" 
                                    songs:[NSArray arrayWithObjects:@"### stupid!", nil]];
}

@end
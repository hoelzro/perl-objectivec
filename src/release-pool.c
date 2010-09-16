// vim:ft=objc

#import <Foundation/NSAutoreleasePool.h>

static NSAutoreleasePool *pool = nil;

void _init_autorelease_pool(void)
{
    pool = [[NSAutoreleasePool alloc] init];
}

void _release_autorelease_pool(void)
{
    [pool release];
    pool = nil;
}

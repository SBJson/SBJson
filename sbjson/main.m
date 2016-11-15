//
//  main.m
//  sbjson
//
//  Created by Stig Brautaset on 12/11/2016.
//
//

#import <Foundation/Foundation.h>
#import "SBJson5.h"

void usage() {
    puts("Usage: sbjson [OPTIONS] [FILES]");
    puts("");
    puts("Options:");
    puts("  --help, -h");
    puts("    This message.");
    puts("  --verbose, -v");
    puts("    Be verbose about which arguments are used");
    puts("  --multi-root, -m");
    puts("    Accept multiple top-level JSON inputs");
    puts("  --unwrap-root, -u");
    puts("    Unwrap top-level arrays");
    puts("  --max-depth INT, -m INT");
    puts("    Change the max recursion limit to INT (default: 32)");
    puts("  --sort-keys, -s");
    puts("    Sort dictionary keys in output");
    puts("  --human-readable, -r");
    puts("    Format the JSON output with linebreaks and indents");
    puts("");
    puts("If no FILES are provided, the program reads standard input.");
    exit(0);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        BOOL multiRoot = NO, unwrapRoot = NO, verbose = NO, sortKeys = NO, humanReadable = NO;
        NSInteger maxDepth = 32;
        NSMutableArray *paths = [NSMutableArray array];

        NSMutableDictionary *parserOptions = [NSMutableDictionary dictionary];

        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        NSEnumerator *enumerator = [arguments objectEnumerator];
        (void)[enumerator nextObject]; // skip program name
        for (id arg = [enumerator nextObject]; arg; arg = [enumerator nextObject]) {
            if ([arg isEqualToString:@"--help"] || [arg isEqualToString:@"-h"]) {
                usage();
            } else if ([arg isEqualToString:@"--verbose"] || [arg isEqualToString:@"-v"]) {
                verbose = YES;
            } else if ([arg isEqualToString:@"--multi-root"] || [arg isEqualToString:@"-m"]) {
                multiRoot = YES;
            } else if ([arg isEqualToString:@"--unwrap-root"] || [arg isEqualToString:@"-u"]) {
                unwrapRoot = YES;
            } else if ([arg isEqualToString:@"--max-depth"] || [arg isEqualToString:@"-d"]) {
                maxDepth = [[enumerator nextObject] integerValue];
            } else if ([arg isEqualToString:@"--sort-keys"] || [arg isEqualToString:@"-s"]) {
                sortKeys = YES;
            } else if ([arg isEqualToString:@"--human-readable"] || [arg isEqualToString:@"-r"]) {
                humanReadable = YES;
            } else if ([[NSFileManager defaultManager] isReadableFileAtPath:arg]) {
                [paths addObject:arg];
            } else {
                NSLog(@"Warning: Don't know what to do with argument %@; ignoring", arg);
            }
        }

        NSFileHandle *output = [NSFileHandle fileHandleWithStandardOutput];

        SBJson5ValueBlock block = ^(id item, BOOL *stop) {
            // Let's try to generate JSON from what we just parsed, but not write anything as it will probably be noisy.
            SBJson5Writer *writer = [SBJson5Writer new];
            writer.sortKeys = sortKeys;
            writer.humanReadable = humanReadable;
            writer.maxDepth = maxDepth;
            [output writeData:[writer dataWithObject:item]];
            [output writeData:[NSData dataWithBytes:"\n" length:1]];
        };

        // We'll just quit on errors.
        SBJson5ErrorBlock eh = ^(NSError *error) {
            NSLog(@"Parser error: %@", error);
            exit(1);
        };

        if (verbose) {
            NSLog(@"Invoking Parser with multiRoot: %@, unwrapRoot: %@, maxDepth: %@", @(multiRoot), @(unwrapRoot), @(maxDepth));
            NSLog(@"Writer will be invoked with sortKeys: %@, humanReadable: %@", @(sortKeys), @(humanReadable));
        }

        id parser = [SBJson5Parser parserWithBlock:block
                                    allowMultiRoot:multiRoot
                                   unwrapRootArray:unwrapRoot
                                          maxDepth:maxDepth
                                      errorHandler:eh];

        // TODO: kill duplication in this section
        if (paths.count) {
            for (id path in paths) {
                NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
                [parser parse:[fh readDataToEndOfFile]];
                [fh closeFile];
            }
        } else {
            NSFileHandle *fh = [NSFileHandle fileHandleWithStandardInput];
            [parser parse:[fh readDataToEndOfFile]];
            [fh closeFile];
        }
    }

    return 0;
}

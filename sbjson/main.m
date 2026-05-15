//
//  main.m
//  sbjson
//
//  Created by Stig Brautaset on 12/11/2016.
//
//

#import <Foundation/Foundation.h>
#import "SBJson5.h"
#import <time.h>

#define BENCH_ITERATIONS 50
#define BENCH_WARMUP 3

static int compare_u64(const void *a, const void *b) {
    uint64_t x = *(const uint64_t *)a, y = *(const uint64_t *)b;
    return (x > y) - (x < y);
}

static uint64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static void benchmark_timing(const char *label, int iterations, void (^block)(void)) {
    uint64_t times[iterations];
    
    for (int i = 0; i < BENCH_WARMUP; i++) block();
    
    for (int i = 0; i < iterations; i++) {
        uint64_t start = now_ns();
        block();
        times[i] = now_ns() - start;
    }
    
    qsort(times, iterations, sizeof(uint64_t), compare_u64);
    uint64_t sum = 0, min = times[0], max = times[iterations - 1];
    for (int i = 0; i < iterations; i++) sum += times[i];
    double mean = (double)sum / iterations;
    double var = 0;
    for (int i = 0; i < iterations; i++) {
        double d = (double)times[i] - mean;
        var += d * d;
    }
    double stddev = sqrt(var / iterations);
    double cv = stddev / mean * 100.0;
    double median = times[iterations / 2];
    
    printf("  %s:\n", label);
    printf("    runs: %d  warmup: %d\n", iterations, BENCH_WARMUP);
    printf("    median: %.2f ms  mean: %.2f ms  \u03c3: %.2f ms  cv: %.1f%%\n",
           median / 1e6, mean / 1e6, stddev / 1e6, cv);
    printf("    min: %.2f ms  max: %.2f ms\n", min / 1e6, max / 1e6);
}

static void benchmark_file(NSString *path, NSUInteger maxDepth, BOOL multiRoot) {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        fprintf(stderr, "Error: cannot read %s\n", [path UTF8String]);
        return;
    }
    
    printf("=== benchmark: %s (%zu KB) ===\n\n", [path UTF8String], data.length / 1024);
    
    // Produce the object tree once
    __block id parsed = nil;
    id first = [SBJson5Parser parserWithBlock:^(id v, BOOL *s) { parsed = v; }
                                 allowMultiRoot:multiRoot
                                unwrapRootArray:NO
                                       maxDepth:maxDepth
                                   errorHandler:^(NSError *e) { exit(1); }];
    [first parse:data];
    
    // Parse benchmark
    benchmark_timing("parse", BENCH_ITERATIONS, ^{
        id p = [SBJson5Parser parserWithBlock:^(id v, BOOL *s) {}
                                 allowMultiRoot:multiRoot
                                unwrapRootArray:NO
                                       maxDepth:maxDepth
                                   errorHandler:^(NSError *e) { exit(1); }];
        [p parse:data];
    });
    
    printf("\n");
    
    // Write benchmark
    benchmark_timing("write", BENCH_ITERATIONS, ^{
        SBJson5Writer *w = [SBJson5Writer writerWithMaxDepth:maxDepth
                                               humanReadable:NO
                                                    sortKeys:NO];
        [w stringWithObject:parsed];
    });
    
    printf("\n");
}

void usage() {
    puts("Usage: sbjson [OPTIONS] [FILES]");
    puts("");
    puts("Options:");
    puts("  --help, -h");
    puts("    This message.");
    puts("  --verbose, -v");
    puts("    Be verbose about which arguments are used");
    puts("  --benchmark, -b");
    puts("    Run benchmarks on the given FILES");
    puts("  --multi-root, -m");
    puts("    Accept multiple top-level JSON inputs");
    puts("  --unwrap-root, -u");
    puts("    Unwrap top-level arrays");
    puts("  --max-depth INT, -d INT");
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
        
        BOOL multiRoot = NO, unwrapRoot = NO, verbose = NO, sortKeys = NO, humanReadable = NO, benchmark = NO;
        NSUInteger maxDepth = 32;
        NSMutableArray *paths = [NSMutableArray array];

        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        NSEnumerator *enumerator = [arguments objectEnumerator];
        (void)[enumerator nextObject]; // skip program name
        for (id arg = [enumerator nextObject]; arg; arg = [enumerator nextObject]) {
            if ([arg isEqualToString:@"--help"] || [arg isEqualToString:@"-h"]) {
                usage();
            } else if ([arg isEqualToString:@"--verbose"] || [arg isEqualToString:@"-v"]) {
                verbose = YES;
            } else if ([arg isEqualToString:@"--benchmark"] || [arg isEqualToString:@"-b"]) {
                benchmark = YES;
            } else if ([arg isEqualToString:@"--multi-root"] || [arg isEqualToString:@"-m"]) {
                multiRoot = YES;
            } else if ([arg isEqualToString:@"--unwrap-root"] || [arg isEqualToString:@"-u"]) {
                unwrapRoot = YES;
            } else if ([arg isEqualToString:@"--max-depth"] || [arg isEqualToString:@"-d"]) {
                id depthArg = [enumerator nextObject];
                if (!depthArg) {
                    fprintf(stderr, "Error: --max-depth requires a numeric argument\n");
                    exit(1);
                }
                NSInteger val = [depthArg integerValue];
                if (val < 1) {
                    fprintf(stderr, "Error: --max-depth must be a positive integer, got '%s'\n", [depthArg UTF8String]);
                    exit(1);
                }
                maxDepth = (NSUInteger)val;
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

        if (benchmark) {
            for (NSString *path in paths)
                benchmark_file(path, maxDepth, multiRoot);
            return 0;
        }

        NSFileHandle *output = [NSFileHandle fileHandleWithStandardOutput];

        SBJson5ValueBlock block = ^(id item, BOOL *stop) {
            // Let's try to generate JSON from what we just parsed, but not write anything as it will probably be noisy.
            SBJson5Writer *writer = [SBJson5Writer writerWithMaxDepth:maxDepth
                                                        humanReadable:humanReadable
                                                             sortKeys:sortKeys];
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

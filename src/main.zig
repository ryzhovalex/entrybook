const std = @import("std");
const json = std.json;
const fmt = std.fmt;
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var iter = try std.process.argsWithAllocator(allocator);
    defer iter.deinit();

    var command: [:0]const u8 = "";
    var command_args = ArrayList([:0]const u8).init(allocator);
    defer command_args.deinit();

    var i: u32 = 0;
    while (iter.next()) |value| {
        i += 1;
        if (i == 1) {
            continue;
        } else if (i == 2) {
            command = value;
        } else {
            try command_args.append(value);
        }
    }

    const now = std.time.now();
    const current_day = now.day_of_week;
    const days_to_subtract = if (current_day == 0) 6 else current_day - 1;
    const last_monday = now - std.time.Duration{ .days = days_to_subtract };
    print("Last Monday's date: {}\n", .{last_monday});

    if (std.mem.eql(u8, command, "write")) {
        const contents = command_args.items;
        const content = try joinStrings(allocator, contents, " "); 

        //print("{s} {s}\n", .{command, content});

    } else {
        return error.UnknownCommand;
    }
}

fn joinStrings(allocator: Allocator, strings: [][:0]const u8, delimiter: []const u8) ![]u8 {
    var total_length: usize = 0;

    for (strings) |s| {
        total_length += s.len;
    }
    total_length += delimiter.len * (strings.len - 1);

    const result = try allocator.alloc(u8, total_length);
    var cursor: usize = 0;

    var i: u32 = 0;
    for (strings) |s| {
        @memcpy(result[cursor..cursor+s.len], s);
        cursor += s.len;

        if (i < strings.len - 1) {
            @memcpy(result[cursor..cursor+delimiter.len], delimiter);
            cursor += delimiter.len;
        }
        i += 1;
    }

    return result;
}

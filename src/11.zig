const std = @import("std");

const MAX_NUMS = 1024 * 1024 * 200;
var NUMS_ARRAY: [MAX_NUMS]usize = undefined;
var N_NUMS: usize = 0;

fn read_line(file: std.fs.File) !void {
    const reader = file.reader();
    var buff: [512]u8 = undefined;

    const rest_line = try reader.readUntilDelimiter(&buff, '\n');
    var char_num: [64]u8 = undefined;
    var curr_idx: usize = 0;
    for (rest_line) |r| {
        if (r < '0' or r > '9') {
            if (curr_idx > 0) {
                const num = try std.fmt.parseInt(usize, char_num[0..curr_idx], 10);
                NUMS_ARRAY[N_NUMS] = num;
                N_NUMS += 1;
            }
            curr_idx = 0;
        } else {
            char_num[curr_idx] = r;
            curr_idx += 1;
        }
    }
    if (curr_idx > 0) {
        const num = try std.fmt.parseInt(usize, char_num[0..curr_idx], 10);
        NUMS_ARRAY[N_NUMS] = num;
        N_NUMS += 1;
    }
}

fn process_number(idx: usize) usize {
    const val = NUMS_ARRAY[idx];

    var n_digs: usize = 0;
    var count_dig = val;
    while (count_dig > 0) {
        n_digs += 1;
        count_dig = @divFloor(count_dig, 10);
    }

    var next_idx: usize = 0;
    if (val == 0) {
        NUMS_ARRAY[idx] = 1;
        next_idx = idx + 1;
    } else if (n_digs % 2 == 0) {
        var pow_10: usize = 1;
        for (0..@divExact(n_digs, 2)) |_| {
            pow_10 *= 10;
        }
        const lower_dig = @mod(val, pow_10);
        const upper_dig = @divFloor(val - lower_dig, pow_10);
        // std.debug.print("bef copy {} {any}\n", .{ idx, NUMS_ARRAY[0..N_NUMS] });
        std.mem.copyBackwards(usize, NUMS_ARRAY[idx + 2 .. N_NUMS + 2], NUMS_ARRAY[idx + 1 .. N_NUMS + 1]);
        NUMS_ARRAY[idx] = upper_dig;
        NUMS_ARRAY[idx + 1] = lower_dig;
        N_NUMS += 1;
        // std.debug.print("after copy {} {any}\n", .{ idx, NUMS_ARRAY[0..N_NUMS] });
        next_idx = idx + 2;
    } else {
        NUMS_ARRAY[idx] *= 2024;
        next_idx = idx + 1;
    }
    if (next_idx >= N_NUMS) {
        next_idx = 0;
    }
    return next_idx;
}

pub fn main() !void {
    const filename = "src/input/11.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    try read_line(file);
    std.debug.print("{any}\n", .{NUMS_ARRAY[0..N_NUMS]});
    for (0..25) |i| {
        var idx = process_number(0);
        while (idx > 0) {
            idx = process_number(idx);
        }
        // std.debug.print("{any}\n", .{NUMS_ARRAY[0..N_NUMS]});
        std.debug.print("n_nums {} {}\n", .{ i, N_NUMS });
    }

    std.debug.print("n_nums {}\n", .{N_NUMS});
}

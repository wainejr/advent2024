const std = @import("std");

const MAX_NUMS = 1024 * 1024 * 200;
var NUMS_ARRAY: [MAX_NUMS]usize = undefined;
var N_NUMS: usize = 0;
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const HashKey = struct {
    val: usize,
    repeat: usize,
};

var HASH_RESULTS = std.hash_map.AutoHashMap(HashKey, usize).init(allocator);

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

fn process_number(val: usize, n_repeat: usize) !usize {
    const key: HashKey = .{ .repeat = n_repeat, .val = val };
    if (HASH_RESULTS.contains(key)) {
        return HASH_RESULTS.get(key).?;
    }

    if (n_repeat == 0) {
        try HASH_RESULTS.put(.{ .repeat = 0, .val = val }, 1);
        return 1;
    }
    if (n_repeat % 50 == 0) {
        std.debug.print("processing repeat {} val {}...\n", .{ n_repeat, val });
    }
    if (val == 0) {
        const res = try process_number(1, n_repeat - 1);
        try HASH_RESULTS.put(.{ .repeat = n_repeat, .val = val }, res);
    } else {
        var n_digs: usize = 0;
        var count_dig = val;
        while (count_dig > 0) {
            n_digs += 1;
            count_dig = @divFloor(count_dig, 10);
        }
        if (n_digs % 2 == 0) {
            var pow_10: usize = 1;
            for (0..@divExact(n_digs, 2)) |_| {
                pow_10 *= 10;
            }
            const lower_dig = @mod(val, pow_10);
            const upper_dig = @divFloor(val - lower_dig, pow_10);
            const lower_n = try process_number(lower_dig, n_repeat - 1);
            const upper_n = try process_number(upper_dig, n_repeat - 1);

            try HASH_RESULTS.put(.{ .repeat = n_repeat, .val = val }, lower_n + upper_n);
        } else {
            const res = try process_number(val * 2024, n_repeat - 1);

            try HASH_RESULTS.put(.{ .repeat = n_repeat, .val = val }, res);
        }
    }

    return HASH_RESULTS.get(key).?;
}

pub fn main() !void {
    defer arena.deinit();

    const filename = "src/input/11.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    try read_line(file);
    std.debug.print("{any}\n", .{NUMS_ARRAY[0..N_NUMS]});
    var total_nums: usize = 0;
    for (0..N_NUMS) |i| {
        total_nums += try process_number(NUMS_ARRAY[i], 75);
        std.debug.print("n_nums {} {}\n", .{ i, total_nums });
    }

    std.debug.print("n_nums {}\n", .{total_nums});
}

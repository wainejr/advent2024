const std = @import("std");

const LineState = struct {
    res: usize,
    nums: []usize,
};

fn concat(n1: usize, n2: usize) usize {
    var n: usize = n2;
    var n1_mul = n1;
    while (n > 0) {
        n = @divFloor(n, 10);
        n1_mul *= 10;
    }
    // std.debug.print("concat {} {} = {}\n", .{ n1, n2, n1_mul + n2 });
    return n1_mul + n2;
}

fn check_valid(res: usize, prev: usize, nums: []usize) bool {
    if (prev > res) {
        return false;
    }
    const n = nums[0];
    if (nums.len == 1) {
        if (n + prev == res) {
            return true;
        } else if (n * prev == res) {
            return true;
        } else {
            return concat(prev, n) == res;
        }
    } else {
        return check_valid(
            res,
            prev * n,
            nums[1..],
        ) or check_valid(
            res,
            prev + n,
            nums[1..],
        ) or check_valid(
            res,
            concat(prev, n),
            nums[1..],
        );
    }
    return false;
}

fn read_line(file: std.fs.File, nums: *[100]usize) !LineState {
    const reader = file.reader();
    var buff: [512]u8 = undefined;

    const res_str = try reader.readUntilDelimiter(&buff, ':');
    const res = try std.fmt.parseInt(usize, res_str, 10);

    const rest_line = try reader.readUntilDelimiter(&buff, '\n');
    var char_num: [64]u8 = undefined;
    var curr_idx: usize = 0;
    var n_nums: usize = 0;
    for (rest_line) |r| {
        if (r == ' ') {
            if (curr_idx > 0) {
                const num = try std.fmt.parseInt(usize, char_num[0..curr_idx], 10);
                nums[n_nums] = num;
                n_nums += 1;
            }
            curr_idx = 0;
        } else {
            char_num[curr_idx] = r;
            curr_idx += 1;
        }
    }
    if (curr_idx > 0) {
        const num = try std.fmt.parseInt(usize, char_num[0..curr_idx], 10);
        nums[n_nums] = num;
        n_nums += 1;
    }

    return LineState{ .nums = nums.*[0..n_nums], .res = res };
}

pub fn main() !void {
    const filename = "src/input/07.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    var rules_sum: usize = 0;
    var n_line: usize = 0;

    while (true) {
        var n_nums: [100]usize = undefined;
        const line_state = read_line(file, &n_nums) catch {
            break;
        };
        const is_valid = check_valid(line_state.res, line_state.nums[0], line_state.nums[1..]);
        n_line += 1;
        if (is_valid) {
            rules_sum += line_state.res;
        }
    }

    std.debug.print("n_line {}\n", .{n_line});
    std.debug.print("rules_sum {}\n", .{rules_sum});
}

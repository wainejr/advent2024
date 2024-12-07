const std = @import("std");

const State = enum { None, MUL, op, check_do };
const StateDo = enum { Doing, NotDoing };
const RetType = struct {
    char: u8,
    val: i32,
};

const Rule = struct {
    left: u32,
    right: u32,
};

const LineError = error{FinishedLine};

fn read_line_rule(file: std.fs.File) !Rule {
    const reader = file.reader();
    var buff: [6]u8 = undefined;

    const arr = try reader.readUntilDelimiter(&buff, '\n');
    if (arr.len < 5) {
        return LineError.FinishedLine;
    }

    const left = try std.fmt.parseInt(u32, buff[0..2], 10);
    const right = try std.fmt.parseInt(u32, buff[3..5], 10);
    return .{ .left = left, .right = right };
}

fn read_line_plan(file: std.fs.File, plan: *[100]u32) !usize {
    const reader = file.reader();
    var buff: [256]u8 = undefined;

    const delimited = try reader.readUntilDelimiter(&buff, '\n');

    var idx: usize = 0;
    // std.debug.print("delimited {s}\n", .{delimited});
    while (idx * 3 < delimited.len) {
        const str_fmt = delimited[idx * 3 .. idx * 3 + 2];
        const val = try std.fmt.parseInt(u32, str_fmt, 10);
        plan.*[idx] = val;
        idx += 1;
    }
    return idx;
}

fn is_plan_valid(plan: []u32, rules: []Rule) bool {
    for (plan[1..], 1..) |p_right, idx_ref| {
        for (plan[0..idx_ref]) |p_left| {
            for (rules) |r| {
                if (p_right == r.left and p_left == r.right) {
                    return false;
                }
            }
        }
    }
    return true;
}

pub fn main() !void {
    const filename = "src/input/05.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    var rules_buff: [2048]Rule = undefined;
    var n_rules: usize = 0;
    for (0..2048) |idx| {
        const r = read_line_rule(file) catch {
            n_rules = idx;
            break;
        };
        rules_buff[idx] = r;
    }
    std.debug.print("n rules {}\n", .{n_rules});

    // const reader = file.reader();
    // var char = try reader.readByte();
    // while (char != '\n') {
    //     char = try reader.readByte();
    // }

    const rules = rules_buff[0..n_rules];
    var rules_sum: usize = 0;
    var n_line: usize = 0;

    while (true) {
        var plan_buff: [100]u32 = undefined;
        const plan_size = read_line_plan(file, &plan_buff) catch {
            break;
        };
        if (plan_size == 0) {
            break;
        }
        n_line += 1;
        const plan = plan_buff[0..plan_size];
        if (!is_plan_valid(plan, rules)) {
            continue;
        }

        const middle_number = plan[@divFloor(plan_size, 2)];
        rules_sum += middle_number;
        std.debug.print("plan {any} is valid (line {} middle {} sum {})\n", .{ plan, n_line, middle_number, rules_sum });
    }

    std.debug.print("rules_sum {}\n", .{rules_sum});
}

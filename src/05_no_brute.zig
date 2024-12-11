const std = @import("std");

const State = enum { None, MUL, op, check_do };
const StateDo = enum { Doing, NotDoing };
const RetType = struct {
    char: u8,
    val: i32,
};

var Rules: [100 * 100]bool = .{false} ** (100 * 100);

const LineError = error{FinishedLine};

fn pos2idx(dest: u32, origin: u32) usize {
    return @intCast(dest + origin * 100);
}

fn idx2pos(idx: usize) [2]i32 {
    return .{ @mod(@as(i32, @intCast(idx)), 100), @divFloor(@as(i32, @intCast(idx)), 100) };
}

fn read_line_rule(file: std.fs.File) !void {
    const reader = file.reader();
    var buff: [6]u8 = undefined;

    const arr = try reader.readUntilDelimiter(&buff, '\n');
    if (arr.len < 5) {
        return LineError.FinishedLine;
    }

    const left = try std.fmt.parseInt(u32, buff[0..2], 10);
    const right = try std.fmt.parseInt(u32, buff[3..5], 10);

    Rules[pos2idx(left, right)] = true;
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

fn is_plan_valid(plan: []u32) bool {
    var rules_local: [100 * 100]bool = undefined;
    std.mem.copyForwards(bool, &rules_local, &Rules);
    for (plan[0 .. plan.len - 1], 0..) |p, idx| {
        const idx_right = idx + 1;

        const p_left = p;
        const p_right = plan[idx_right];
        const idx_check = pos2idx(p_right, p_left);
        if (rules_local[idx_check]) {
            return false;
        }
        for (0..100) |uy| {
            const y: u32 = @intCast(uy);
            if (y == p_left or rules_local[pos2idx(p_left, y)]) {
                rules_local[pos2idx(p_right, y)] = true;
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

    var n_rules: usize = 0;
    for (0..2048) |idx| {
        read_line_rule(file) catch {
            n_rules = idx;
            break;
        };
    }
    std.debug.print("n rules {}\n", .{n_rules});

    // const reader = file.reader();
    // var char = try reader.readByte();
    // while (char != '\n') {
    //     char = try reader.readByte();
    // }

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
        if (!is_plan_valid(plan)) {
            continue;
        }

        const middle_number = plan[@divFloor(plan_size, 2)];
        rules_sum += middle_number;
        std.debug.print("plan {any} is valid (line {} middle {} sum {})\n", .{ plan, n_line, middle_number, rules_sum });
    }

    std.debug.print("rules_sum {}\n", .{rules_sum});
}

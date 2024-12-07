const std = @import("std");

const State = enum { None, MUL, op, check_do };
const StateDo = enum { Doing, NotDoing };
const RetType = struct {
    char: u8,
    val: i32,
};

var Rules: [100 * 100]bool = .{false} ** (100 * 100);

const LineError = error{FinishedLine};

fn read_line_rule(file: std.fs.File) !void {
    const reader = file.reader();
    var buff: [6]u8 = undefined;

    const arr = try reader.readUntilDelimiter(&buff, '\n');
    if (arr.len < 5) {
        return LineError.FinishedLine;
    }

    const left = try std.fmt.parseInt(u32, buff[0..2], 10);
    const right = try std.fmt.parseInt(u32, buff[3..5], 10);

    Rules[left + right * 100] = true;
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
    for (plan[1..], 1..) |p_right, idx_ref| {
        for (plan[0..idx_ref]) |p_left| {
            if (Rules[p_right + p_left * 100]) {
                return false;
            }
        }
    }
    return true;
}

fn is_plan_idx_valid(plan: []u32, idx: usize) bool {
    const p_left = plan[idx];
    for (plan[idx + 1 ..]) |p_right| {
        if (Rules[p_right + p_left * 100]) {
            return false;
        }
    }
    return true;
}
fn validate_plan(ptr_plan: *[]u32) void {
    var plan = ptr_plan.*;
    // Joga o numero o mais pra frente possível
    for (plan[0 .. plan.len - 1], 0..) |_, idx_left| {
        if (is_plan_idx_valid(plan, idx_left)) {
            continue;
        }

        var idx_right: usize = idx_left + 1;
        // enquanto for válida a troca
        while (idx_right < plan.len and !is_plan_idx_valid(plan, idx_left)) {
            const v = plan[idx_left];
            plan[idx_left] = plan[idx_right];
            plan[idx_right] = v;
            if (is_plan_idx_valid(plan, idx_right)) {
                break;
            }
            idx_right += 1;
        }
    }
}

pub fn main() !void {
    const filename = "src/input/05.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var n_rules: usize = 0;
    for (0..2048) |idx| {
        read_line_rule(file) catch {
            n_rules = idx;
            break;
        };
    }
    std.debug.print("n rules {}\n", .{n_rules});

    var rules_sum: usize = 0;
    var n_line: usize = 0;

    while (true) {
        var plan_buff: [100]u32 = undefined;
        const plan_size = read_line_plan(file, &plan_buff) catch {
            break;
        };
        n_line += 1;
        var plan = plan_buff[0..plan_size];
        if (is_plan_valid(plan)) {
            continue;
        }
        validate_plan(&plan);

        if (!is_plan_valid(plan)) {
            std.debug.print("IM WRONG:\n{any}\n\n", .{plan});
            continue;
        }
        const middle_number = plan[@divFloor(plan_size, 2)];
        rules_sum += middle_number;
        // std.debug.print("plan {any} is corrected and valid (line {} middle {} sum {})\n", .{ plan, n_line, middle_number, rules_sum });
    }
    std.debug.print("n_lines {}\n", .{n_line});

    std.debug.print("rules_sum {}\n", .{rules_sum});
}

const std = @import("std");

const ReportMode = enum { Descending, Ascending, Unknown };

pub fn main() !void {
    const filename = "src/input/02.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // Create a buffer to store file contents
    var buffer: [1024]u8 = undefined;
    const reader = file.reader();

    var line = try reader.readUntilDelimiter(&buffer, '\n');
    var n_valid_reports: usize = 0;
    while (true) {
        var curr_idx: usize = 0;
        var ini_idx: usize = 0;
        var is_valid: bool = true;
        var n_number: usize = 0;
        var arr_numbers: [100]i32 = .{-1} ** 100;

        while (curr_idx < line.len) {
            while (curr_idx < line.len and line[curr_idx] != ' ') {
                curr_idx += 1;
            }
            if (curr_idx >= line.len and ini_idx == curr_idx) {
                break;
            }
            const n1 = try std.fmt.parseInt(i32, line[ini_idx..curr_idx], 10);
            arr_numbers[n_number] = n1;
            n_number += 1;
            curr_idx += 1;
            ini_idx = curr_idx;
        }
        if (n_number == 0) {
            break;
        }

        var is_ascending: bool = true;
        var idx_cmp: usize = 0;

        for (0..n_number + 1) |idx_remove| {
            var anr: [100]i32 = .{-1} ** 100;
            const n_use: usize = if (idx_remove == n_number) n_number else n_number - 1;
            for (0..n_number) |idx| {
                if (idx > idx_remove) {
                    anr[idx - 1] = arr_numbers[idx];
                } else if (idx < idx_remove) {
                    anr[idx] = arr_numbers[idx];
                }
            }
            const anr_use = anr[0..n_use];
            is_ascending = true;
            idx_cmp = 0;
            for (anr_use[1..], 1..) |n, idx| {
                const prev_number = anr[idx_cmp];
                if (!(n > prev_number and n <= prev_number + 3)) {
                    is_ascending = false;
                    break;
                }
                idx_cmp = idx;
            }
            var is_descending = true;
            idx_cmp = 0;
            for (anr_use[1..], 1..) |n, idx| {
                const prev_number = anr[idx_cmp];
                if (!(n < prev_number and n >= prev_number - 3)) {
                    is_descending = false;
                    break;
                }
                idx_cmp = idx;
            }
            is_valid = is_ascending or is_descending;
            if (is_valid) {
                break;
            }
        }

        if (is_valid) {
            n_valid_reports += 1;
        }

        if (!is_valid) {
            std.debug.print("is valid {} line {s}\n", .{ is_valid, line });
        }
        line = reader.readUntilDelimiter(&buffer, '\n') catch {
            std.debug.print("file terminated. Lines\n", .{});
            break;
        };
    }
    std.debug.print("n valid reports {}\n", .{n_valid_reports});
}

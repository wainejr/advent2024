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

        const anr = arr_numbers[0..n_number];
        var is_ascending = true;
        var idx_cmp_asc: usize = 0;
        var error_asc = false;

        var is_descending = true;
        var idx_cmp_desc: usize = 0;
        var error_desc = false;
        for (anr[1..], 1..) |n, idx| {
            const prev_number_asc = anr[idx_cmp_asc];
            if (!(n > prev_number_asc and n <= prev_number_asc + 3)) {
                if (error_asc) {
                    is_ascending = false;
                }
                error_asc = true;
            } else {
                idx_cmp_asc = idx;
            }
            const prev_number_desc = anr[idx_cmp_desc];
            if (!(n < prev_number_desc and n >= prev_number_desc - 3)) {
                if (error_desc) {
                    is_descending = false;
                }
                error_desc = true;
            } else {
                idx_cmp_desc = idx;
            }
            if (!is_ascending and !is_descending) {
                break;
            }
        }
        if (!is_ascending and !is_descending) {
            is_ascending = true;
            idx_cmp_asc = 1;
            error_asc = true;

            is_descending = true;
            idx_cmp_desc = 1;
            error_desc = true;
            for (anr[2..], 2..) |n, idx| {
                const prev_number_asc = anr[idx_cmp_asc];
                if (!(n > prev_number_asc and n <= prev_number_asc + 3)) {
                    is_ascending = false;
                }
                idx_cmp_asc = idx;

                const prev_number_desc = anr[idx_cmp_desc];
                if (!(n < prev_number_desc and n >= prev_number_desc - 3)) {
                    is_descending = false;
                }
                idx_cmp_desc = idx;

                if (!is_ascending and !is_descending) {
                    break;
                }
            }
        }
        std.debug.print("here {any} asc {} desc {}\n", .{ arr_numbers, is_ascending, is_descending });
        is_valid = is_ascending or is_descending;

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

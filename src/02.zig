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
        var line_status = ReportMode.Unknown;
        var last_number: i32 = -1;
        var is_valid: bool = true;
        var has_started: bool = false;

        while (curr_idx < line.len) {
            while (curr_idx < line.len and line[curr_idx] != ' ') {
                curr_idx += 1;
            }
            if (curr_idx >= line.len and ini_idx == curr_idx) {
                break;
            }
            has_started = true;
            const n1 = try std.fmt.parseInt(i32, line[ini_idx..curr_idx], 10);
            if (last_number == -1) {
                last_number = n1;
            } else {
                if (line_status == ReportMode.Unknown) {
                    if (n1 > last_number) {
                        line_status = ReportMode.Ascending;
                    } else {
                        line_status = ReportMode.Descending;
                    }
                }
                switch (line_status) {
                    .Ascending => {
                        if (!(n1 > last_number and n1 <= last_number + 3)) {
                            is_valid = false;
                            break;
                        }
                    },
                    .Descending => {
                        if (!(n1 < last_number and n1 >= last_number - 3)) {
                            is_valid = false;
                            break;
                        }
                    },
                    .Unknown => {
                        std.debug.panic("why am i here?\n", .{});
                    },
                }
                last_number = n1;
            }

            curr_idx += 1;
            ini_idx = curr_idx;
        }
        if (is_valid and has_started) {
            n_valid_reports += 1;
        }
        std.debug.print("is valid {} line {s}\n", .{ is_valid, line });
        line = reader.readUntilDelimiter(&buffer, '\n') catch {
            std.debug.print("file terminated. Lines\n", .{});
            break;
        };
    }
    std.debug.print("n valid reports {}\n", .{n_valid_reports});
}

const std = @import("std");

const State = enum { None, MUL, op };
const RetType = struct {
    char: u8,
    val: i32,
};

fn read_number(reader: anytype) !RetType {
    var my_number: [3]u8 = .{ '0', '0', '0' };
    var number_size: usize = 0;
    var char: u8 = '0';
    for (0..4) |idx| {
        char = try reader.readByte();
        if (char < '0' or char > '9' or idx >= 3)
            break;
        my_number[number_size] = char;
        number_size += 1;
    }
    if (number_size == 0) {
        return .{ .val = -1, .char = char };
    }
    const val: i32 = std.fmt.parseInt(i32, my_number[0..number_size], 10) catch {
        return .{ .val = -1, .char = char };
    };

    return .{ .val = val, .char = char };
}

pub fn main() !void {
    const filename = "src/input/03.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    // Create a buffer to store file contents
    // var buffer: [1024]u8 = undefined;
    const reader = file.reader();

    var n_sum_muls: usize = 0;
    var curr_state: State = State.None;
    var char: u8 = 0;
    while (true) {
        // std.debug.print("{c}", .{char});
        switch (curr_state) {
            .None => {
                char = reader.readByte() catch {
                    break;
                };
                if (char == 'm') {
                    curr_state = State.MUL;
                }
            },
            .MUL => {
                char = reader.readByte() catch {
                    break;
                };
                if (char == 'u') {
                    char = reader.readByte() catch {
                        break;
                    };
                    if (char == 'l') {
                        curr_state = State.op;
                    }
                }
                if (curr_state != State.op) {
                    if (char == 'm') {
                        curr_state = State.MUL;
                    } else {
                        curr_state = State.None;
                    }
                }
            },
            .op => {
                // std.debug.print("op {c}\n", .{char});
                char = reader.readByte() catch {
                    break;
                };
                var n1: i32 = -1;
                var n2: i32 = -1;
                var is_correct = false;
                if (char == '(') {
                    const ret1 = read_number(reader) catch {
                        break;
                    };
                    char = ret1.char;
                    n1 = ret1.val;
                    if (n1 >= 0) {
                        if (char == ',') {
                            const ret2 = read_number(reader) catch {
                                break;
                            };
                            char = ret2.char;
                            n2 = ret2.val;
                            if (n2 >= 0) {
                                if (char == ')') {
                                    is_correct = true;
                                }
                            }
                        }
                    }
                }
                if (is_correct) {
                    n_sum_muls += @intCast(n1 * n2);
                }

                if (char == 'm') {
                    curr_state = State.MUL;
                } else {
                    curr_state = State.None;
                }
            },
        }
    }
    std.debug.print("n sum num {}\n", .{n_sum_muls});
}

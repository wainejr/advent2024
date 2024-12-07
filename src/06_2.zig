const std = @import("std");

const MAX_SIZE = 1024;
var Table: [MAX_SIZE * MAX_SIZE]u8 = undefined;
var Visited: [MAX_SIZE * MAX_SIZE]bool = .{false} ** (MAX_SIZE * MAX_SIZE);

var N_COLS: i32 = -1;
var N_ROWS: i32 = -1;

pub fn idx2pos(idx: usize) [2]i32 {
    const x: i32 = @intCast(@mod(@as(i32, @intCast(idx)), N_COLS));
    const y: i32 = @intCast(@divFloor(@as(i32, @intCast(idx)), N_COLS));
    return .{ x, y };
}

pub fn pos2idx(x: i32, y: i32) usize {
    return @intCast(x + y * N_COLS);
}

pub fn is_valid_pos(x: i32, y: i32) bool {
    return x >= 0 and y >= 0 and x < N_COLS and y < N_ROWS;
}

const OutError = error{Exit};

const BLOCK = '#';

const DIRECTIONS: [4][2]i32 = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
    .{ 0, -1 },
};
var VISITED_DIRS: [4][MAX_SIZE * MAX_SIZE]bool = .{
    .{false} ** (MAX_SIZE * MAX_SIZE),
    .{false} ** (MAX_SIZE * MAX_SIZE),
    .{false} ** (MAX_SIZE * MAX_SIZE),
    .{false} ** (MAX_SIZE * MAX_SIZE),
};

const DIR_UP = 3;
const DIR_DOWN = 1;
const DIR_LEFT = 2;
const DIR_RIGHT = 0;

var guard_ini: usize = 0;
var guard_idx: usize = 0;
var guard_direction: usize = undefined;

fn populate_table(file: std.fs.File) !void {
    try file.seekTo(0);

    const reader = file.reader();
    var idx: usize = 0;
    while (true) {
        const char = reader.readByte() catch {
            break;
        };
        // std.debug.print("{c}\n", .{char});
        if (char != '\n') {
            Table[idx] = char;
            switch (char) {
                '^' => {
                    guard_idx = idx;
                    guard_direction = DIR_UP;
                },
                '>' => {
                    guard_idx = idx;
                    guard_direction = DIR_RIGHT;
                },
                'v' => {
                    guard_idx = idx;
                    guard_direction = DIR_DOWN;
                },
                '<' => {
                    guard_idx = idx;
                    guard_direction = DIR_LEFT;
                },
                else => {},
            }
            idx += 1;
        } else if (N_COLS <= 0) {
            N_COLS = @intCast(idx);
        }
    }
    guard_ini = guard_idx;
    N_ROWS = @divExact(@as(i32, @intCast(idx)), N_COLS);
}

fn walk_table() !void {
    const pos = idx2pos(guard_idx);
    Visited[guard_idx] = true;
    VISITED_DIRS[guard_direction][guard_idx] = true;

    const dir = DIRECTIONS[guard_direction];
    const n_pos = .{ pos[0] + dir[0], pos[1] + dir[1] };
    if (!is_valid_pos(n_pos[0], n_pos[1])) {
        return OutError.Exit;
    }
    const n_idx = pos2idx(n_pos[0], n_pos[1]);
    if (Table[n_idx] == BLOCK) {
        guard_direction = @mod(guard_direction + 1, DIRECTIONS.len);
        return;
    }
    guard_idx = n_idx;
}

fn is_cycle(block_idx: usize) bool {
    if (Table[block_idx] == BLOCK) {
        return false;
    }
    const bpos = idx2pos(block_idx);

    for (DIRECTIONS, 0..) |dir, dir_idx| {
        const pos_orig: [2]i32 = .{ bpos[0] - dir[0], bpos[1] - dir[1] };
        if (!is_valid_pos(pos_orig[0], pos_orig[1])) {
            continue;
        }
        const pos_orig_idx = pos2idx(pos_orig[0], pos_orig[1]);
        if (pos_orig_idx == guard_ini) {
            continue;
        }

        const n_dir_idx = @mod(dir_idx + 1, 4);
        const n_dir = DIRECTIONS[n_dir_idx];
        for (0..@intCast(N_COLS)) |cmul| {
            const mul: i32 = @intCast(cmul);

            const pos_test: [2]i32 = .{
                pos_orig[0] + n_dir[0] * mul,
                pos_orig[1] + n_dir[1] * mul,
            };
            if (!is_valid_pos(pos_test[0], pos_test[1])) {
                break;
            }
            const pos_test_idx = pos2idx(pos_test[0], pos_test[1]);
            if (Table[pos_test_idx] == BLOCK) {
                break;
            }
            if (VISITED_DIRS[dir_idx][pos_orig_idx] and VISITED_DIRS[n_dir_idx][pos_test_idx]) {
                return true;
            }

            if (VISITED_DIRS[dir_idx][pos_orig_idx] and VISITED_DIRS[n_dir_idx][pos_test_idx]) {
                return true;
            }
        }
    }
    return false;
}

pub fn main() !void {
    const filename = "src/input/06_test.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try populate_table(file);
    std.debug.print(
        "n rows {} n cols {} curr pos {} curr_dir {}\n",
        .{
            N_ROWS,
            N_COLS,
            guard_idx,
            guard_direction,
        },
    );

    var n_walks: usize = 0;
    while (true) {
        walk_table() catch {
            break;
        };
        n_walks += 1;
    }

    var n_cycles: usize = 0;
    for (0..@as(usize, @intCast(N_COLS * N_ROWS))) |idx| {
        if (is_cycle(idx)) {
            n_cycles += 1;
            std.debug.print("pos cycle {any}\n", .{idx2pos(idx)});
        }
    }
    std.debug.print("n cycles {}\n", .{n_cycles});

    // std.debug.print("n_visited {}\n", .{n_visited});

    std.debug.print("n_walks {}\n", .{n_walks});
}

const std = @import("std");

const MAX_SIZE = 1024;
var Table: [MAX_SIZE * MAX_SIZE]u8 = undefined;
var AntiNode: [MAX_SIZE * MAX_SIZE]bool = .{false} ** (MAX_SIZE * MAX_SIZE);
var N_COLS: i32 = -1;
var N_ROWS: i32 = -1;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

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
            idx += 1;
        } else if (N_COLS <= 0) {
            N_COLS = @intCast(idx);
        }
    }
    N_ROWS = @divExact(@as(i32, @intCast(idx)), N_COLS);
}

fn walk(idx: usize, path: []usize, hike_final: []bool) !void {
    const height = Table[idx];
    const pos = idx2pos(idx);

    var new_path = try allocator.alloc(usize, path.len + 1);
    std.mem.copyForwards(usize, new_path, path);

    const possible_dirs: [4][2]i32 = .{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, 1 }, .{ 0, -1 } };
    for (possible_dirs) |dir| {
        const pos_dir: [2]i32 = .{ pos[0] + dir[0], pos[1] + dir[1] };
        if (!is_valid_pos(pos_dir[0], pos_dir[1])) {
            continue;
        }
        const pos_idx = pos2idx(pos_dir[0], pos_dir[1]);
        var is_in_path = false;
        for (path) |p| {
            if (p == pos_idx) {
                is_in_path = true;
                break;
            }
        }
        if (is_in_path) {
            continue;
        }
        const dir_height = Table[pos_idx];
        if (dir_height != height + 1) {
            continue;
        }
        if (dir_height == '9') {
            hike_final[pos_idx] = true;
            continue;
        }
        new_path[new_path.len - 1] = pos_idx;
        try walk(pos_idx, new_path, hike_final);
    }
}

fn check_node_hike(idx: usize) !usize {
    var hike_final: [MAX_SIZE * MAX_SIZE]bool = .{false} ** (MAX_SIZE * MAX_SIZE);

    const ini_path: [1]usize = .{idx};
    try walk(idx, @constCast(@ptrCast(&ini_path)), @ptrCast(&hike_final));

    var hikes: usize = 0;
    for (hike_final) |h| {
        if (h) {
            hikes += 1;
        }
    }
    // std.debug.print("hike at {any} pts {}\n", .{ idx2pos(idx), hikes });
    return hikes;
}

pub fn main() !void {
    defer arena.deinit();

    const filename = "src/input/10.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    try populate_table(file);
    std.debug.print(
        "n rows {} n cols {} \n",
        .{
            N_ROWS,
            N_COLS,
        },
    );

    var hike_pts: usize = 0;
    for (Table, 0..) |char, idx| {
        if (char == '0') {
            hike_pts += try check_node_hike(idx);
        }
    }

    std.debug.print("hike pts {}\n", .{hike_pts});
}

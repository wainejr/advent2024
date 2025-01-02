const std = @import("std");

const MAX_SIZE = 1024;
var Terrain: [MAX_SIZE * MAX_SIZE]u8 = undefined;
var Visited: [MAX_SIZE * MAX_SIZE]bool = .{false} ** (MAX_SIZE * MAX_SIZE);
var N_COLS: i32 = -1;
var N_ROWS: i32 = -1;

pub fn idx2pos(idx: usize) [2]i32 {
    const x: i32 = @intCast(@mod(@as(i32, @intCast(idx)), N_COLS));
    const y: i32 = @intCast(@divFloor(@as(i32, @intCast(idx)), N_COLS));
    return .{ x, y };
}

pub fn pos2idx(pos: [2]i32) usize {
    return @intCast(pos[0] + pos[1] * N_COLS);
}

pub fn is_valid_pos(pos: [2]i32) bool {
    return pos[0] >= 0 and pos[1] >= 0 and pos[0] < N_COLS and pos[1] < N_ROWS;
}

const OutError = error{Exit};

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
            Terrain[idx] = char;
            idx += 1;
        } else if (N_COLS <= 0) {
            N_COLS = @intCast(idx);
        }
    }
    N_ROWS = @divExact(@as(i32, @intCast(idx)), N_COLS);
}

fn visit_nodes(idx_start: usize) usize {
    const letter = Terrain[idx_start];
    var area: usize = 0;
    var perimiter: usize = 0;

    const directions: [4][2]i32 = .{
        .{ 0, 1 },
        .{ 0, -1 },
        .{ 1, 0 },
        .{ -1, 0 },
    };
    var idxs_visit: [100]usize = undefined;
    idxs_visit[0] = idx_start;
    var n_visits: usize = 1;
    var idxs_view = idxs_visit[0..n_visits];

    while (n_visits > 0) {
        idxs_view = idxs_visit[0..n_visits];
        const idx = idxs_view[0];
        const pos = idx2pos(idx);

        if (!Visited[idx]) {
            area += 1;
            for (directions) |d| {
                const pos_d: [2]i32 = .{ pos[0] + d[0], pos[1] + d[1] };
                if (!is_valid_pos(pos_d)) {
                    perimiter += 1;
                    continue;
                }
                const idx_d = pos2idx(pos_d);
                const letter_d = Terrain[idx_d];
                if (letter_d != letter) {
                    perimiter += 1;
                    continue;
                } else {
                    idxs_visit[n_visits] = idx_d;
                    n_visits += 1;
                }
            }
        }
        Visited[idx] = true;

        std.mem.copyForwards(usize, idxs_visit[0 .. n_visits - 1], idxs_visit[1..n_visits]);
        n_visits -= 1;
    }

    return area * perimiter;
}

pub fn main() !void {
    const filename = "src/input/12.txt";

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

    const n_nodes: usize = @intCast(N_ROWS * N_COLS);
    var total_price: usize = 0;
    for (0..n_nodes) |idx| {
        if (!Visited[idx]) {
            total_price += visit_nodes(idx);
        }
    }

    std.debug.print("total price {}\n", .{total_price});
}

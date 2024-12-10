const std = @import("std");

const MAX_SIZE = 1024;
var Table: [MAX_SIZE * MAX_SIZE]u8 = undefined;
var AntiNode: [MAX_SIZE * MAX_SIZE]bool = .{false} ** (MAX_SIZE * MAX_SIZE);
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

fn populate_idxs_char(char: u8, idx_buff: []usize) []usize {
    var curr_idx: usize = 0;

    for (0..@intCast(N_COLS * N_ROWS)) |idx| {
        if (Table[idx] == char) {
            idx_buff[curr_idx] = idx;
            curr_idx += 1;
        }
    }
    return idx_buff[0..curr_idx];
}

fn check_antinodes(char: u8) void {
    var idx_buff: [2048]usize = undefined;
    const idxs_char = populate_idxs_char(char, @ptrCast(&idx_buff));
    if (idxs_char.len == 0) {
        return;
    }
    std.debug.print("char {c} idxs char {any}\n", .{ char, idxs_char });
    for (idxs_char, 0..) |i, idx| {
        const posi = idx2pos(i);
        for (idxs_char[idx + 1 ..]) |j| {
            const posj = idx2pos(j);
            const dist: [2]i32 = .{ posi[0] - posj[0], posi[1] - posj[1] };
            const anti1: [2]i32 = .{ posj[0] - dist[0], posj[1] - dist[1] };
            if (is_valid_pos(anti1[0], anti1[1])) {
                const idx_anti1 = pos2idx(anti1[0], anti1[1]);
                // std.debug.print(
                //     "ANTI1 {any} {any} {any}\n",
                //     .{ idx_anti1, idx2pos(idx_anti1), anti1 },
                // );
                AntiNode[idx_anti1] = true;
            }
            const anti2: [2]i32 = .{ posi[0] + dist[0], posi[1] + dist[1] };
            if (is_valid_pos(anti2[0], anti2[1])) {
                const idx_anti2 = pos2idx(anti2[0], anti2[1]);
                // std.debug.print(
                //     "ANTI2 {any} {any}\n",
                //     .{ idx_anti2, idx2pos(idx_anti2) },
                // );
                AntiNode[idx_anti2] = true;
            }
            std.debug.print(
                "pi {any} pj {any} dist {any} pa1 {any} pa2 {any}\n",
                .{ posi, posj, dist, anti1, anti2 },
            );
        }
    }
}

pub fn main() !void {
    const filename = "src/input/08.txt";

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

    for ('0'..'9' + 1) |char| {
        check_antinodes(@as(u8, @intCast(char)));
    }
    for ('a'..'z' + 1) |char| {
        check_antinodes(@as(u8, @intCast(char)));
    }
    for ('A'..'Z' + 1) |char| {
        check_antinodes(@as(u8, @intCast(char)));
    }

    var n_anti_nodes: usize = 0;
    for (AntiNode[0..@intCast(N_COLS * N_ROWS)], 0..) |anti, idx| {
        if (anti) {
            const pos = idx2pos(idx);
            std.debug.print("anti node at {any}\n", .{pos});
            n_anti_nodes += 1;
        }
    }

    std.debug.print("n_anti_nodes {}\n", .{n_anti_nodes});
}
